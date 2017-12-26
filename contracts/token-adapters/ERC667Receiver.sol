pragma solidity ^0.4.11;


contract ERC667Receiver {
    function onTokenTransfer(address _from, uint256 _value, bytes _data);
}