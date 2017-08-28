pragma solidity ^0.4.13;
import './AO.sol';
import './bancor/solidity/contracts/BancorChanger.sol';
import './Balances.sol';
import './Safe.sol';
import './SafeMath.sol';

/**

                                    [USER]
                                    /     \
                                   /       \
                                  /         \
                                 v           v
    --------------       -----------         -----------------
    | Data Store | ----> | SafeDao | <-----> | BancorChanger | 
    --------------       -----------         -----------------
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


contract Safecontroller {
    using SafeMath for uint;

    AO safeToken;
    BancorChanger bancorChanger;

    address etherReserve;

    uint constant FEEMULTIPLIER = 100;
    uint constant MAX_USERS = 1000;
    
    struct Vault {
        address balances;
        uint safeTokenReserves;
        uint wFee;
    }

    mapping(address => Vault) vaultAddress;
    address[] users;
    
    function Safecontroller(address _safeToken,
                             address _bancorChanger) {
        _;
    }

    function deployVault() 
        public
    {
        assert(users.length < MAX_USERS);
        assert(!searchUsers(msg.sender));
        users.push(msg.sender);

        // Creates the vault.
        Balances b = new Balances(msg.sender);
        Vault v = new Vault;
        v.balances = address(b);
        v.safeTokenReserves = 0;
        v.wFee = 0;

        vaultAddress[msg.sender] = v;

        VaultCreated(msg.sender);
    }

    /// Claim your AO held by the safecontroller
    function claim() 
        public
    {
        require(searchUsers(msg.sender));

        var v = vaultAddress[msg.sender];
        assert(v.safeTokenReserves > 0);

        safeToken.transfer(v.balances, v.safeTokenReserves);
        TokensClaimed();
    }

    /// User facing deposit function. MUST UPDATE THE WITHDRAWAL FEE.
    function deposit()
        public
        payable
    {
        require(msg.value > 0);
        require(searchUsers(msg.sender));
        var v = vaultAddress[msg.sender];

        Balances b = v.balances;
        var oldBalance = b.queryBalance();
        var newBalance = oldBalance.add(msg.value);
        b.transfer(msg.value);

        var oldFee = b.wFee;
        var newFee = calcFee(newBalance);

        if (newFee < oldFee) {
            b.wFee = oldFee;
        } else {
            b.wFee = newFee;
        }

        Deposit();
    }

    function withdraw()
        public
        payable
    {
        require(searchUsers(msg.sender));
        var v = vaultAddress[msg.sender];

        assert(v.balances.queryBalance() > 0);
        assert(v.safeTokenReserves == 0);
        assert(v.wFee != 0);

        safeToken.transferFrom(msg.sender, address(this), v.wFee);

        v.balances.transferAll(msg.sender);
        
        v.balances.destroy();
        delete v.balances;
        delete vaultAddress[msg.sender];
    }

    function calcFee()
        public constant returns (uint)
    {

    }

    function searchUsers(address _user)
        public constant returns (bool)
    {
        for (var i = 0; i < users.length; ++i) {
            if (_user == users[i]) {return true;}
        }
        return false;
    }

    event VaultCreated(address indexed vaultAddress, address indexed owner);
    event TokensClaimed();
}