pragma solidity ^0.4.11;


import './ERC20Impl.sol';
import '../receive/ApprovalReceiver.sol';


/**
 * @dev This token notifies contract when it receives approval from the user
 */
contract ApprovalNotifyToken is ERC20Impl {
    function approveAndCall(address _spender, uint256 _value, bytes _data) returns (bool success) {
        approve(_spender, _value);
        ApprovalReceiver(_spender).receiveApproval(msg.sender, _value, this, _data);
        return true;
    }
}