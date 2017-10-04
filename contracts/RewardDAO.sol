pragma solidity ^0.4.15;

import './interfaces/IRewardDAO.sol';
import './interfaces/IKnownTokens.sol';

import './BNK.sol';
import './Balances.sol';
import './SafeMath.sol';
import './KnownTokens.sol';

import './bancor_contracts/BancorChanger.sol';
import './bancor_contracts/BancorFormula.sol';
import './bancor_contracts/EtherToken.sol';
import './bancor_contracts/interfaces/IERC20Token.sol';

/**
 * @title Reward DAO
 */
contract RewardDAO is IRewardDAO {
    using SafeMath for uint;

    struct Vault {
        address balances;
        uint unclaimedBNK;
        uint totalBNK;
        uint withdrawalFee;
    }

    uint constant FEE_MULTIPLIER = 1500;
    uint constant MAX_USERS = 200;

    BNK bnkToken;                // TODO: Remove this, since all the transfers will be within the Balances
    EtherToken wrappedEther;
    ITokenChanger tokenChanger;  // TODO make this of type IBancorChanger to facilitate future upgrades
    KnownTokens knownTokens;

    mapping(address => Vault) savingsContract;
    address[] users;

    event SavingsContractCreated(address indexed savingsContractAddress);
    event TokensClaimed();
    event Log(string);

    /**
        @dev constructor

        @param _tokenChanger    Address of a deployed TokenChanger contract (i.e. BancorChanger)
        @param _bnkToken       Address of the account from where bnkTokens are being issued.
    */
    function RewardDAO(address _tokenChanger,
                       address _bnkToken, 
                       address _etherToken,
                       address _knownTokens) {
 
        knownTokens = KnownTokens(_knownTokens);

        knownTokens.addToken(_etherToken);
        knownTokens.addToken(_bnkToken);
        knownTokens.addTokenChanger(_tokenChanger);
    }

    /**
        @dev Creates a new Savings Contract
    */
    function deploySavingsContract()
        public
    {
        require(users.length < MAX_USERS);
        require(!search(msg.sender, users));
        users.push(msg.sender);

        // Creates the SavingsContract.
        Balances bal = new Balances(address(this), address(bnkToken), msg.sender);
        savingsContract[msg.sender].balances = address(bal);
        savingsContract[msg.sender].unclaimedBNK = 0;
        savingsContract[msg.sender].totalBNK = 0;
        savingsContract[msg.sender].withdrawalFee = 0;

        SavingsContractCreated(msg.sender);
    }

    /**
        @dev claim your BNK held by the RewardDAO by transferring funds in the the save to balance
    */
    function claim()
        public
    {
        require(search(msg.sender, users));

        Vault vault = savingsContract[msg.sender];
        if (!vault.unclaimeDAO > 0) {
            Log("You don't have any BNK to claim.");
            return;
        }

        uint claimAmount = vault.unclaimedBNK;
        delete vault.unclaimedBnk;

        uint oldTotalBNK = vault.totalBNK;
        vault.totalBNK = oldTotalBNK.add(claimAmount);

        bnkToken.transfer(vault.balances, claimAmount);

        Log("BNK Tokens claimed.");
    }

    /**
        @dev user facing deposit function
        TODO: UPDATE THE WITHDRAWAL FEE.

         @param _token    Address of the ERC20 token being deposited, or the ether wrapper
         @param _amount   Amount of said token being deposited into save
    */
    function deposit(address _token, uint _amount)
        public
    {
        require(_amount > 0);
        require(knownTokens.containsToken(_token));
        require(search(msg.sender, users));

        IERC20Token token = IERC20Token(_token);
        require(token.balanceOf(msg.sender) > _amount);

        Vault vault = savingsContract[msg.sender];

        uint valueOfHoldings = vault.balances.valueOf();
        uint tokenValueInEther = knownTokens.priceOf(_token).mul(_amount);
        uint newValue = valueOfHoldings.add(tokenValueInEther);

        vault.withdrawalFee = calcFee(vault, newValue);
        /// TODO: Check that the value.balances is approved for the token amount from user first
        assert(vault.balances.call(bytes4(keccak256("pullDeposit(address,address,uint256")), msg.sender, _token, _amount));
        Log("Deposit successful!");
    }

    /**
        @dev withdraws entirety of the vault into user's balance and destroys the vault
        TODO: Implement snapshots on every block so we can keep track of people's overall stake in the system.
    */
    function withdraw()
        public
    {
        require(search(msg.sender, users));

        var sc = savingsContract[msg.sender];
        var bal = Balances(sc.balances);

        // require the withdrawer to pay some amount of money before transferring money to account
        assert(sc.unclaimeDAO == 0);
        assert(sc.withdrawalFee != 0);
        bnkToken.transferFrom(msg.sender, address(this), sc.withdrawalFee);

        // transfer all the tokens associated with the balance to the user account

        // TODO: Put the below back in
        /* address[] knownTokensList = knownTokens.getKnownTokensList();
        for (uint i = 0; i < knownTokensList.length; ++i) {
            bal.withdraw(msg.sender, knownTokensList[i]);
        } */

        // resets all the defaults in case anything goes wrong in deletion
        savingsContract[msg.sender].balances      = 0x0;
        savingsContract[msg.sender].unclaimeDAO   = 0;
        savingsContract[msg.sender].withdrawalFee = 0;
        delete savingsContract[msg.sender];
    }

/////
// Private Helper Functions
/////

    function calcFee(Vault _vault, uint _newValue)
        private constant returns (uint)
    {
        uint oldFee = _vault.withdrawalFee;
        uint newFee = _newValue.mul(FEE_MULTIPLIER); 

        // The withdrawal fee can never be lower, thereby resisting gaming the system
        if (newFee < oldFee) { 
            return oldFee;
        } else {
            return newFee;
        }
    }

    /**
        @dev Returns the amount of money in the save associated with the message sender in ETH

        @return Supply of ETH in the message sender's vault
    */
    // function getEthBalance()
    //     internal
    //     returns (uint)
    // {
    //     require(search(msg.sender, users));
    //     var v = addressToVaultMap[msg.sender];
    //     return bancorChanger.getReturn(bnkToken, etherToken, vault.unclaimeDAO);
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
