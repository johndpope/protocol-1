pragma solidity ^0.4.13;
import './AO.sol';
import './bancor_contracts/BancorChanger.sol';
import './Balances.sol';
import './SafeMath.sol';

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


contract SafeController {
    using SafeMath for uint;

    struct Vault {
        address balances;
        uint safeTokenReserves;
        uint wFee;
    }

    uint constant FEEMULTIPLIER = 100;
    uint constant MAX_USERS = 1000;

    AO safeToken;
    BancorChanger bancorChanger;
    address etherReserve;
    mapping(address => Vault) addressToVaultMap;
    address[] users;

    event Deposit(uint indexed amount); // TODO: This is repeated in the Balances contract: Choose one

    // TODO: Why are there separate addresses for the vault and the owner: isn't the valut created at the owner's addr?
    event VaultCreated(address indexed vaultAddress); // , address indexed owner);
    event TokensClaimed();
    
    function SafeController( address _safeToken,
                             address _bancorChanger) {
        // TODO: Actually implement the logic for the controller here
    }

    // TODO: isn't the addressToVaultMap fully populated when it's instantiated? not sure if this function is necessary
    function deployVault() 
        public
    {
        assert(users.length < MAX_USERS);
        assert(!searchUsers(msg.sender));
        users.push(msg.sender);

        // Creates the vault.

        // TODO: Point the safe token to the address that we want to have in the Balances constructor
        // TODO: This is ONLY here because we wanted the contract to successfully compile

        address _safeToken = msg.sender;
        Balances b = new Balances(msg.sender, safeToken);
        // Vault v = Vault({
        //     balances: address(b),
        //     safeTokenReserves: 0,
        //     wFee: 0
        // });

        // addressToVaultMap[msg.sender] = v;

        addressToVaultMap[msg.sender].balances = b;
        VaultCreated(msg.sender); //, address(addressToVaultMap[msg.sender]));
    }

    /// Claim your AO held by the safecontroller
    function claim() 
        public
    {
        require(searchUsers(msg.sender));

        var v = addressToVaultMap[msg.sender];
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
        var v = addressToVaultMap[msg.sender];

        // TODO: This will be a separate refactor, since we can't pass around dynamic objects in the EVM (I think)
        // TODO: This is why people use byte32 instead of strings -- we may have to serialize/deserialize the Balances
        // TODO: object or do something along those lines

        // Balances b = v.balances;
        // var oldBalance = b.queryBalance();
        // var newBalance = oldBalance.add(msg.value);
        // b.transfer(msg.value);

        // TODO: Not sure what these wFees are supposed to be referring to, so I've just commented this out
        // TODO: for now. Remove these commented lines and either integrate wFee into Balances or point elsewhere

        // var oldFee = b.wFee;
        // var newFee = calcFee(newBalance);

        // if (newFee < oldFee) {
        //     b.wFee = oldFee;
        // } else {
        //     b.wFee = newFee;
        // }

        Deposit(msg.value);
    }

    function withdraw()
        public
    {
        require(searchUsers(msg.sender));
        var v = addressToVaultMap[msg.sender];

        // TODO: Same as the prevent function comments

        // assert(v.balances.queryBalance() > 0);
        // assert(v.safeTokenReserves == 0);
        // assert(v.wFee != 0);

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