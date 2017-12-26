pragma solidity ^0.4.11;


contract ApprovalReceiver {
    function receiveApproval(address _from, uint256 _value, address _token, bytes _data);
}