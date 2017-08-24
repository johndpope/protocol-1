pragma solidity ^0.4.15;
import './SafeInterface.sol';
import './Balances.sol';

contract Safe is SafeInterface, Balances {
    address constant SAFEDAO = 0x0;

    address holder;         // address of the holder

    function Safe(address _holder) {
        require(_holder != 0x0);
        require(msg.sender == SAFEDAO);

        holder = _holder;
    }

    function deposit()
        requireSender(SAFEDAO)
        payable
    {
        DepositReceived(msg.value);
    }

    function ()
        payable
    {
        revert();
    }

    function weiHeld()
        constant returns (uint256)
    {
        return this.balance;
    }

    event DepositReceived(uint indexed value);

    // function withdrawComplete()
    //     requireSender(SAFEDAO)
    // {

    //     selfdestruct(holder);
    // }

    modifier requireSender(address _who)
    {
        assert(msg.sender == _who);
        _;
    }

}