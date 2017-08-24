pragma solidity ^0.4.13;
import './AO.sol';
import './bancor/solidity/contracts/BancorChanger.sol';
import './Safe.sol';

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
    AO safeToken;
    BancorChanger bancorChanger;

    address etherReserve;

    uint256 constant FEEMULTIPLIER = 100;

    mapping(address => address) vaultAddress;
    mapping(address => uint256) weiHeld;
    
    function Safecontroller(address _safeToken,
                             address _bancorChanger) {
        _;
    }

    function deployVault() 
        public
    {
        require(vaultAddress[msg.sender] == 0x0);

        Vault v = new Vault(msg.sender);
        vaultAddress[msg.sender] = address(v);

        VaultCreated(address(v), msg.sender);
    }

    function deposit()
        public
        payable
    {
        require(vaultAddress[msg.sender] != 0x0);
        require(msg.value > 0);

        Vault vault = Vault(vaultAddress[msg.sender]);

        // Update state
        weiHeld[vault] = weiHeld[vault].add(msg.value);

        assert(
            vault.value(msg.value).call(bytes4(keccak256("deposit()")))
        );
    }

    function withdraw()
        public
        payable
    {
        require(vaultAddress[msg.sender] != 0x0);

        require(msg.value == getWithdrawalFee());
        

    }

    function getWithdrawalFee()
        public constant returns (uint256)
    {
        if (vaultAddress[msg.sender] == 0x0) {
            revert();
        }

        Vault vault = Vault(vaultAddress[msg.sender]);

        // Check everything matches
        assert(
            vault.balance == weiHeld[vault]
        );

        uint256 safeTokenBalance = safeToken.balanceOf(vault);  

        // Query the bancor changer
        // Returns amount of ether expected return for AO
        uint256 etherAmount = bancorChanger.getSaleReturn(etherReserve, safeTokenBalance);

        uint256 totalHeld = vault.balance.add(etherAmount);

        uint256 wFee = totalHeld.mul(FEEMULTIPLIER);

        return wFee;
    }

    event VaultCreated(address indexed vaultAddress, address indexed owner);
}