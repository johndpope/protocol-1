pragma solidity ^0.4.15;
import './Backdoor.sol';        // temporary

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
    address connectedContract;      // The Safe contract addresss.
    address user;                   // The user address.

    function Balances(address _contract,
                      address _user) {
        connectedContract = _contract;
        user = _user;                      
    }

    function query()
        public constant returns (uint)
    {
        return this.balance;        // returns balance of ether
    }

    function deposit()
        public payable
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