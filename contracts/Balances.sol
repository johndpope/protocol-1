pragma solidity ^0.4.15;
import './AO.sol';
import './Backdoor.sol';            // temporary

/**
    The idea of this contract is that it will hold the business
    logic of user funds held in a Safe denominated in ether. 
    (Eventually supported ERC20 tokens as well.) We do this in
    order to isolate user funds from the higher level interface
    of the Safe in case we need to upgrade the Safe contract in
    the future we can do so with minimal impact (ideally, no impact)
    on the user.

 */
contract Balances is Backdoor {
    AO safeToken;                   // Address of the official SafeToken
    address connectedContract;      // The Safe contract addresss.

    function Balances(address _contract,
                      address _safeToken) {
        connectedContract = _contract;
        safeToken = AO(_safeToken);                    
    }

    function query()
        public constant returns (uint)
    {
        return this.balance;        // returns balance of ether
    }

    function deposit()
        public payable returns (bool)
    {
        assert(msg.sender == connectedContract);
        assert(msg.value > 0);

        Deposit(msg.value);
    }

    function ()
        payable
    {
        deposit();
    }

    event Deposit(uint indexed amount);
}