pragma solidity ^0.4.11;


import '../token/ERC20.sol';
import './ReceiveAdapter.sol';

/**
 * @dev Helps to receive ERC20-complaint tokens when token contract notifies receiver with receiveApproval.
 *      see https://github.com/ConsenSys/Tokens/blob/master/contracts/HumanStandardToken.sol
 */
contract ReceiveApprovalAdapter is ReceiveAdapter {
    function receiveApproval(address _from, uint256 _value, bytes _data) {
        receiveApproval(_from, _value, msg.sender, _data);
    }

    function receiveApproval(address _from, uint256 _value, address _token, bytes _data) {
        ERC20 token = ERC20(_token);
        token.transferFrom(_from, this, _value);
        onReceive(_token, _from, _value, _data);
    }
}