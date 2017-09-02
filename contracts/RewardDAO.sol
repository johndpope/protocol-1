pragma solidity ^0.4.13;
import './interfaces/IRewardDAO.sol';

import './AO.sol';
import './Balances.sol';
import './SafeMath.sol';

import './bancor_contracts/BancorChanger.sol';
import './bancor_contracts/BancorFormula.sol';
import './bancor_contracts/EtherToken.sol';
import './bancor_contracts/IERC20Token.sol';

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

    AO safeToken;
    BancorChanger bancorChanger;
    EtherToken etherToken;              // ERC20 wrapper of the ETH token to allow interactions with Bancor

    address etherReserve;
    mapping(address => Vault) addressToVaultMap;
    address[] users;
    address[] knownTokens;

    event Deposit(uint indexed amount);  // TODO: This is repeated in the Balances contract: Choose one
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
        knownTokens.push(address(safeToken));
        knownTokens.push(address(etherToken));

        bancorChanger = new BancorChanger(  safeToken,           // smartToken wrapper of AO token governed by contract
                                            new BancorFormula(), // conversion formula for exchange rate
                                            CHANGE_FEE,          // change fee used to liquidate from AO to ETH
                                            etherToken,          // marking ETH as our reserve coin
                                            CRR);                // ETH reserve ratio
    }

    /**
        @dev deploys vault onto blockchain, creating associated balance for vault
    */
    function deployVault() 
        public
    {
        assert(users.length < MAX_USERS);
        assert(!searchUsers(msg.sender));
        users.push(msg.sender);

        // Creates the vault.
        Balances b = new Balances(address(this), address(safeToken), msg.sender);
        addressToVaultMap[msg.sender].balances = address(b);
        addressToVaultMap[msg.sender].unclaimedAO = 0;
        addressToVaultMap[msg.sender].withdrawalFee = 0;

        VaultCreated(msg.sender);
    }

    /**
        @dev Returns the amount of money in the safe associated with the message sender in ETH

        @return Supply of ETH in the message sender's vault
    */
    function getEthBalance()
        public
        returns (uint)
    {
        require(searchUsers(msg.sender));
        var v = addressToVaultMap[msg.sender];
        return bancorChanger.getReturn(safeToken, etherToken, v.unclaimedAO);
    }

    /**
        @dev claim your AO held by the RewardDAO by transferring funds in the the safe to balance
    */
    function claim()
        public
    {
        require(searchUsers(msg.sender));

        var v = addressToVaultMap[msg.sender];
        assert(v.unclaimedAO > 0);

        var claimAmount = v.unclaimedAO;
        delete v.unclaimedAO;

        v.totalAO = claimAmount;
        safeToken.transfer(v.balances, claimAmount);
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
        token = IERC20Token(_token);

        // Require that the user is registered with the RewardDAO.
        require(search(msg.sender, users));
        var v = addressToVaultMap[msg.sender];

        require(_amount > 0);
        require(token.balanceOf(msg.sender) > _amount);

        Balances bal = Balances(v.balances);
        var oldBalance = bal.balanceOf(msg.sender);
        var newBalance = oldBalance.add(_amount);

        var oldFee = v.withdrawalFee;
        var newFee = calcFee(newBalance);

        // set the vault fee to be maximum of the previous and updated fee
        if (newFee < oldFee) { v.withdrawalFee = oldFee; }
        else                 { v.withdrawalFee = newFee; }

        token.transfer(_amount);
        Deposit(_token, _amount, msg.sender);
    }

    /**
        @dev withdraws entirety of the vault into user's balance and destroys the vault
        TODO: Implement snapshots on every block so we can keep track of people's overall stake in the system.
    */
    function withdraw()
        public
    {
        require(searchUsers(msg.sender));
        var v = addressToVaultMap[msg.sender];

        assert(Balances(v.balances).queryBalance() > 0);
        assert(v.unclaimedAO == 0);
        assert(v.withdrawalFee != 0);

        // require the withdrawer to pay some amount of money before transferring money to account
        safeToken.transferFrom(msg.sender, address(this), v.withdrawalFee);
        safeToken.transferFrom(v.balances, msg.sender, v.unclaimedAO);

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
        @dev calculates the withdrawal fee, as outlined in the whitepaper
        TODO: Add actual logic to determine the withdrawal fee

        @param _balance     Balance in the vault for which a fee is being calculated
    */
    function calcFee(uint _balance) constant returns (uint) {
        return 1;
    }

    /**
        @dev returns whether or not the specified user exists in the list of registered users

        @param  _user      Address of the user being investigated
        @return  boolean indicating if the user was found (true) or not (false)
    */
    function searchUsers(address _user) constant returns (bool) {
        for (uint i = 0; i < users.length; ++i) {
            if (_user == users[i]) {return true;}
        }
        return false;
    }

    /**
        @dev Returns boolean of whether the token is known
        
        @param _token   Address of the token.
        @return boolean (true) if token is known and (false) if not
    */
    function searchTokens(address _token)
        constant returns (bool)
    {
        for (uint i = 0; i < knownTokens.length; ++i) {
            if (_token == knownTokens[i]) {return true;}
        }
        return false;
    }

    function search(address _query, address[] _pool)
        constant returns (bool)
    {
        for (uint i = 0; i < _pool.length; ++i) {
            if (_query == _pool[i]) {return true;}
        }
        return false;
    }
}