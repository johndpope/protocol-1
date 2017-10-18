pragma solidity ^0.4.17;

import './interfaces/IRewardDAO.sol';
import './interfaces/IKnownTokens.sol';

import './Balances.sol';
import './KnownTokens.sol';
import './SafeMath.sol';
import './TBK.sol';

import './bancor_contracts/BancorChanger.sol';
import './bancor_contracts/BancorFormula.sol';
import './bancor_contracts/EtherToken.sol';
import './bancor_contracts/interfaces/IERC20Token.sol';
import './minime/TokenController.sol';

/**
 * @title RewardDAO
 * The central agent that oversees the distribution of rewards inside of the network.
 */
contract RewardDAO is IRewardDAO {
    using SafeMath for uint;

    /// SavingsContract holds information about a single user in the network.
    struct SavingsContract {
        address balances;
        uint unclaimedTBK;
        uint valueOf;
        uint withdrawalFee;
    }

    /// A table that maps an address to respective SavingsContract.
    mapping(address => SavingsContract) savingsContracts;

    /// An array which holds a list of registered users.
    address[] users;

    /// The total network value (TNV) denominated in ether held inside of this RewardDAO network.
    uint public totalNetworkValue;

    /// The shared data store of known tokens in the network.
    // TODO: Make this into an interface once the interface is finished.
    KnownTokens knownTokens;

    /**
     * @dev Constructor
     * @param _tokenChanger Address of the default TokenChanger contract from TBK -> Eth.
     * @param _TBKToken Address of the TBK token.
     * @param _etherToken Address of the ether token wrapper.
     * @param _knownTokens Address of the canonical list of supported tokens.
     */
    function RewardDAO(address _weth,
                       address _tbk, 
                       address _tokenChanger) {
        knownTokens = new KnownTokens();

        knownTokens.addTokenPair(_weth, _tbk, _tokenChanger);
    }

    /**
     * @dev Generally, the first function to be called by a new user in the network. It
     * will deploy a new instance of Balances and create a storage pointer to a SavingsContract.
     * @return _balances Address of the user's newly created balances contract.
     */
    function deploySavingsContract()
        public returns (address _balances)
    {
        require(users.length < MAX_USERS);
        require(!search(msg.sender, users));
        users.push(msg.sender);

        /// Create the SavingsContract
        Balances bal = new Balances(address(this), address(knownTokens), msg.sender);
        savingsContract[msg.sender].balances = address(bal);
        savingsContract[msg.sender].unclaimedTBK = 0;
        savingsContract[msg.sender].withdrawalFee = 0;

        SavingsContractCreated(msg.sender);
    }

    /**
     * @dev The function users will call to deposit a token.
     * @param _token Address of the token to be deposited.
     * @param _amount Amount to be deposited.
     */
    function deposit(address _token, uint _amount)
        public
    {
        require(_amount > 0);
        require(knownTokens.containsToken(_token));
        require(search(msg.sender, users));

        IERC20Token token = IERC20Token(_token);
        require(token.balanceOf(msg.sender) > _amount);

        SavingsContract storage sC = savingsContract[msg.sender];

        uint valueOfHoldings = sC.valueOf;
        uint tokenValueInEther = knownTokens.recoverPrice(_token, address(wrappedEther)).mul(_amount);
        uint newValue = valueOfHoldings.add(tokenValueInEther);
        sC.valueOf = newValue;

        sC.withdrawalFee = calcFee(sC, newValue);
        /// TODO: Check that the value.balances is approved for the token amount from user first
        assert(vault.balances.call(bytes4(keccak256("pullDeposit(address,address,uint256")), msg.sender, _token, _amount));
        Log("Deposit successful!");
    }


    /**
     * @dev Deposits the unclaimed tokens into user's Balances and updates network.
    */
    function claim()
        public
    {
        require(search(msg.sender, users));
        claimForUser(msg.sender);

        // Vault storage vault = savingsContract[msg.sender];
        // if (vault.unclaimedTBK == 0) {
        //     Log("You don't have any TBK to claim.");
        //     return;
        // }

        // uint claimAmount = vault.unclaimedTBK;
        // delete vault.unclaimedTBK;

        // // uint oldTotalTBK = vault.totalTBK;
        // // vault.totalTBK = oldTotalTBK.add(claimAmount);

        // TBKToken.transfer(vault.balances, claimAmount);

        // Log("TBK Tokens claimed.");
    }

    function claimForUser(address _user) {
        // TODO: Require either _user == msg.sender or msg.sender == administrator
          
    }

    /**
        @dev withdraws entirety of the vault into user's balance and destroys the vault
        TODO: Implement snapshots on every block so we can keep track of people's overall stake in the system.
    */
    function withdraw()
        public
        returns (bool)
    {
        require(search(msg.sender, users));
        require(vault.withdrawalFee > 0);

        Vault memory vault = savingsContract[msg.sender];

        if (vault.unclaimedTBK != 0) {
            Log("Claim all of your TBK first!");
            return false;
        }

        /// Make sure approve function is called first.
        TBKToken.transferFrom(msg.sender, address(this), vault.withdrawalFee);

        // Transfers all the tokens
        assert(vault.balances.call(bytes4(keccak256("withdraw(address)")), msg.sender));

        delete savingsContract[msg.sender];
        Log("Withdraw successful!");
        return true;
    }

    function distributeTBKRewards() {

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
    //     return bancorChanger.getReturn(TBKToken, etherToken, vault.unclaimeDAO);
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




    uint constant FEE_MULTIPLIER = 1500;
    uint constant MAX_USERS = 200;


    event SavingsContractCreated(address indexed savingsContractAddress);
}
