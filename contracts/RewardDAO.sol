pragma solidity ^0.4.13;
import './interfaces/IRewardDAO.sol';

import './AO.sol';
import './Balances.sol';
import './SafeMath.sol';

import './bancor_contracts/BancorChanger.sol';
import './bancor_contracts/BancorFormula.sol';
import './bancor_contracts/EtherToken.sol';

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
        uint safeTokenReserves;
        uint withdrawalFee;
    }

    uint constant FEE_MULTIPLIER = 100;
    uint constant MAX_USERS = 1000;

    uint32 constant CHANGE_FEE = 10000; // 1%  : Bancor change fee for token conversion
    uint32 constant CRR = 250000;       // 25% : reserve ratio of ETH to AO for Bancor in PPM

    AO safeToken;
    BancorChanger bancorChanger;
    address etherReserve;
    mapping(address => Vault) addressToVaultMap;
    address[] users;

    event Deposit(uint indexed amount);  // TODO: This is repeated in the Balances contract: Choose one
    event VaultCreated(address indexed vaultAddress);
    event TokensClaimed();
    event Log(uint amount);
    
    function RewardDAO(address _safeToken) {
        safeToken = AO(_safeToken);
        bancorChanger = new BancorChanger(  safeToken,           // smartToken wrapper of AO token governed by contract
                                            new BancorFormula(),     // conversion formula for exchange rate
                                            CHANGE_FEE,          // change fee used to liquidate from AO to ETH
                                            new EtherToken(),        // marking ETH as our reserve coin
                                            CRR);                // ETH reserve ratio
    }

    function onDeposit(uint _amount) public
        returns (bool)
    {
        assert(true); // TODO
        Log(_amount);
        return true;
    }

    function deployVault() 
        public
    {
        assert(users.length < MAX_USERS);
        assert(!searchUsers(msg.sender));
        users.push(msg.sender);

        // Creates the vault.
        Balances b = new Balances(address(this), address(safeToken), msg.sender);
        addressToVaultMap[msg.sender].balances = address(b);
        addressToVaultMap[msg.sender].safeTokenReserves = 0;
        addressToVaultMap[msg.sender].withdrawalFee = 0;

        VaultCreated(msg.sender);
    }

    /**
        @dev Returns the amount of money in the safe associated with the message sender in ETH

        @return Supply of ETH in the message sender's vault
    */
    function getEthBalance() public
        returns (uint)
    {
        require(searchUsers(msg.sender));
        var v = addressToVaultMap[msg.sender];
        return bancorChanger.getReturn(safeToken, new EtherToken(), v.safeTokenReserves);
    }

    /// @dev Claim your AO held by the RewardDAO
    function claim()
        public
    {
        require(searchUsers(msg.sender));

        var v = addressToVaultMap[msg.sender];
        assert(v.safeTokenReserves > 0);

        safeToken.transfer(v.balances, v.safeTokenReserves);
        TokensClaimed();
    }

    /// @dev User facing deposit function. MUST UPDATE THE WITHDRAWAL FEE.
    function deposit()
        public
        payable
    {
        require(msg.value > 0);
        require(searchUsers(msg.sender));
        var v = addressToVaultMap[msg.sender];

        Balances b = Balances(v.balances);
        // var oldBalance = b.queryBalance();
        // var newBalance = oldBalance.add(msg.value);
        b.transfer(msg.value);

        // var oldFee = b.withdrawalFee;
        // var newFee = calcFee(newBalance);

        // if (newFee < oldFee) {
        //     b.wFee = oldFee;
        // } else {
        //     b.wFee = newFee;
        // }

        Deposit(msg.value);
    }

    // TODO: Implement snapshots on every block so we can keep track of people's
    // overall stake in the system.
    function withdraw()
        public
    {
        require(searchUsers(msg.sender));
        var v = addressToVaultMap[msg.sender];

        assert(Balances(v.balances).queryBalance() > 0);
        assert(v.safeTokenReserves == 0);
        assert(v.withdrawalFee != 0);

        // safeToken.transferFrom(msg.sender, address(this), v.wFee);

        // v.balances.transferAll(msg.sender);
        
        // v.balances.destroy();
        // delete v.balances;
        delete addressToVaultMap[msg.sender];
    }

    function calcFee()
        public constant returns (uint)
    {
        
    }

    function searchUsers(address _user)
        public constant returns (bool)
    {
        for (uint i = 0; i < users.length; ++i) {
            if (_user == users[i]) {return true;}
        }
        return false;
    }
}