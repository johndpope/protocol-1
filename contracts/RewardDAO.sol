pragma solidity ^0.4.15;
import './interfaces/IRewardDAO.sol';

import './AO.sol';
import './Balances.sol';
import './KnownTokens.sol';
import './SafeMath.sol';

import './bancor_contracts/BancorChanger.sol';
import './bancor_contracts/BancorFormula.sol';
import './bancor_contracts/EtherToken.sol';
import './bancor_contracts/interfaces/IERC20Token.sol';

/**
                [USER]
                /     \
               /       \
              /         \
             v           v
    -----------         -----------------
    | SafeDao | <-----> | BancorChanger | 
    -----------         -----------------
        /  \   
       /    \    etc.
      /      \
    _______  _______   
    |vault|  |vault| 

    The fee for withdrawing is calculated at the time of your most recent deposit.
    The fee is determined by querying the Bancor protocol contract to retrieve the
    most recent exchange rate of AO -> Eth, then calculates the Eth balance in the user
    safe and adds the amount being deposited. Thereafter it sets the withdrawal fee equal
    to the current valuation of the safe in AO and divides it by 100.
    TODO: in the future we will add a 1.25x multiplier to the AO held in the safe, this means 
    that straight up AO will hold a higher weight.
 */

contract RewardDAO is IRewardDAO {
    using SafeMath for uint;

    struct Vault {
        address balances;
        uint unclaimedAO;
        uint totalAO;
        uint withdrawalFee;
    }

    uint constant FEE_MULTIPLIER = 100;
    uint constant MAX_USERS = 1000;

    uint32 constant CHANGE_FEE = 10000; // 1%  : Bancor change fee for token conversion
    uint32 constant CRR = 250000;       // 25% : reserve ratio of ETH to AO for Bancor in PPM

    BancorChanger bancorChanger; // TODO make this of type IBancorChanger to facilitate future upgrades

    address etherReserve;
    mapping(address => Vault) addressToVaultMap;
    address[] users;
    
    address knownTokens;

    // TODO: This is repeated in the Balances contract: Choose one
    event Deposit(address token, uint amount, address sender);
    event VaultCreated(address indexed vaultAddress);
    event TokensClaimed();
    event Log(uint amount);

    /**
        @dev constructor

        @param  _safeToken      Address of the account from where safeTokens are being issued
    */
    function RewardDAO(address _safeToken) {
        safeToken = AO(_safeToken);
        etherToken = new EtherToken();

        bancorChanger = new BancorChanger(  safeToken,           // smartToken wrapper of AO token governed by contract
                                            new BancorFormula(), // conversion formula for exchange rate
                                            CHANGE_FEE,          // change fee used to liquidate from AO to ETH
                                            etherToken,          // marking ETH as our reserve coin
                                            CRR);                // ETH reserve ratio

        knownTokens = new KnownTokens(  etherToken, 
                                        safeToken, 
                                        bancorChanger);
    }

    /**
        @dev deploys vault onto blockchain, creating associated balance for vault
    */
    function deployVault() 
        public
    {
        assert(users.length < MAX_USERS);
        assert(!search(msg.sender, users));
        users.push(msg.sender);

        // Creates the vault.
        Balances b = new Balances(address(this), address(safeToken), msg.sender);
        addressToVaultMap[msg.sender].balances = address(b);
        addressToVaultMap[msg.sender].unclaimedAO = 0;
        addressToVaultMap[msg.sender].withdrawalFee = 0;

        VaultCreated(msg.sender);
    }

    /**
        @dev claim your AO held by the RewardDAO by transferring funds in the the safe to balance
    */
    function claim()
        public
    {
        require(search(msg.sender, users));

        var vault = addressToVaultMap[msg.sender];
        assert(vault.unclaimedAO > 0);

        var claimAmount = vault.unclaimedAO;
        delete vault.unclaimedAO;

        var oldTotalAO = vault.totalAO;
        vault.totalAO = oldTotalAO.add(claimAmount);

        safeToken.transfer(vault.balances, claimAmount);

        TokensClaimed();
    }

    /**
        @dev user facing deposit function
        TODO: UPDATE THE WITHDRAWAL FEE.

        @param _token   Address of the ERC20 token being deposited, or the ether wrapper
    */
    function deposit(address _token, uint _amount)
        public
    {
        // Ensure that the RewardDAO is aware of the token
        // being sent as a deposit.
        require(search(_token, knownTokens));
        IERC20Token token = IERC20Token(_token);

        // Require that the user is registered with the RewardDAO.
        require(search(msg.sender, users));
        var vault = addressToVaultMap[msg.sender];

        require(_amount > 0);
        require(token.balanceOf(msg.sender) > _amount);

        Balances bal = Balances(vault.balances);
        var oldBalance = bal.queryBalance(msg.sender);
        var newBalance = oldBalance.add(_amount);

        var oldFee = vault.withdrawalFee;
        var newFee = calcFee(vault, newBalance, _token);

        // TODO: Double check this
        // set the vault fee to be maximum of the previous and updated fee
        if (newFee < oldFee) { vault.withdrawalFee = oldFee; }
        else                 { vault.withdrawalFee = newFee; }

        token.transferFrom(msg.sender, address(bal), _amount);
        Deposit(_token, _amount, msg.sender);
    }

    /**
        @dev withdraws entirety of the vault into user's balance and destroys the vault
        TODO: Implement snapshots on every block so we can keep track of people's overall stake in the system.
    */
    function withdraw()
        public
    {
        require(search(msg.sender, users));
        
        var vault = addressToVaultMap[msg.sender];
        var bal = Balances(vault.balances); // TODO: Is this the standard way of referring to an initialized balance?
        for (uint i = 0; i < knownTokens.length; ++i) {
            // var tokenBalance = vault.balances.call(bytes4(keccak256("queryBalance(address)")), knownTokens[i]);
            if (bal.queryBalance(knownTokens[i]) > 0) {
                continue; // TODO change this, feels gross
            } else {
                revert();
            }
        }
        assert(vault.unclaimedAO == 0);
        assert(vault.withdrawalFee != 0);

        // require the withdrawer to pay some amount of money before transferring money to account
        safeToken.transferFrom(msg.sender, address(this), vault.withdrawalFee);
        safeToken.transferFrom(vault.balances, msg.sender, vault.unclaimedAO);

        // resets all the defaults in case anything goes wrong in deletion
        addressToVaultMap[msg.sender].balances      = 0x0;
        addressToVaultMap[msg.sender].unclaimedAO   = 0;
        addressToVaultMap[msg.sender].withdrawalFee = 0;
        delete addressToVaultMap[msg.sender];
    }

    /** ----------------------------------------------------------------------------
        *                       Private helper functions                             *
        ---------------------------------------------------------------------------- */

    /**
        @dev arbitrates the deposits into Balances

        @param  _amount      Amount (in safeTokens) being deposited into the vault
        @return boolean success of the deposit
    */
    function onDeposit(uint _amount) returns (bool) {
        assert(true); // TODO
        Log(_amount);
        return true;
    }

    /**
        @dev Calculates the new withdrawal fee everytime a user submits a deposit of token.
             Private function in which all the variable have already been checked for accuracy in the calling
             public-facing function.

        @param _vault The address for the vault to be determined. 
        @param _newBalance The new balance of token to calculate with.
        @param _token The address of the token which was deposited
        @return The new withdrawal fee to be paid. 
    */
    function calcFee(Vault _vault, uint _newBalance, address _token)
        private constant returns (uint)
    {
        uint runningTotal;
        // var vault = addressToVaultMap[_vault];
        var token = IERC20Token(_token); // TODO: Is this the standard way of referring to an initialized contract?

        for (uint i = 0; i < knownTokens.length; ++i) {
            if ((knownTokens[i] == _token) &&
                (token == etherToken))
            {
                runningTotal.add(etherToken.balanceOf(_vault.balances));
            } else if ((knownTokens[i] == _token) &&
                       (token == safeToken))
            {
                // TODO query bancorchanger
                var etherRepresentationOfSafeTokenHeld = 
                        bancorChanger.getReturn(safeToken, etherToken, _newBalance);
                runningTotal.add(
                    etherRepresentationOfSafeTokenHeld
                );
            } else {
                revert();
            }
        }

        return runningTotal;
    }

    /**
        @dev Returns the amount of money in the safe associated with the message sender in ETH

        @return Supply of ETH in the message sender's vault
    */
    // function getEthBalance()
    //     internal
    //     returns (uint)
    // {
    //     require(search(msg.sender, users));
    //     var v = addressToVaultMap[msg.sender];
    //     return bancorChanger.getReturn(safeToken, etherToken, vault.unclaimedAO);
    // }

    /**
        @dev Generic search function for finding an entry in address array.

        @param _query   Address being investigated
        @param _pool    The array we search in
        @return  boolean indicating if the entry was found (true) or not (false)
    */
    function search(address _query, address[] _pool)
        constant returns (bool)
    {
        for (uint i = 0; i < _pool.length; ++i) {
            if (_query == _pool[i]) {return true;}
        }
        return false;
    }
}