pragma solidity ^0.4.11;


import './ReceiveAdapter.sol';


contract ReceiveAdapterMock is ReceiveAdapter {
    event Receive(address token, address from, uint256 value, bytes data);

    function onReceive(address _token, address _from, uint256 _value, bytes _data) internal {
        Receive(_token, _from, _value, _data);
    }
}