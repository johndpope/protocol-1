pragma solidity ^0.4.11;


import '../token/ERC20.sol';
import './ReceiveAdapter.sol';

/**
 * @dev Helps to receive ERC667-complaint tokens. ERC223 Token contract should notify receiver.
 */
contract ERC667ReceiveAdapter is ReceiveAdapter {
    function tokenFallback(address _from, uint256 _value, bytes _data) {
        onReceive(msg.sender, _from, _value, _data);
    }

    function onTokenTransfer(address _from, uint256 _value, bytes _data) {
        onReceive(msg.sender, _from, _value, _data);
    }
}