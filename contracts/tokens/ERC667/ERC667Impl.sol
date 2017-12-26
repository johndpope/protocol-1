pragma solidity ^0.4.11;


import './ERC20Impl.sol';
import './ERC667.sol';
import '../receive/ERC667Receiver.sol';


contract ERC667Impl is ERC20Impl, ERC667 {
    function transfer(address _to, uint256 _value, bytes _data) whenNotPaused public returns (bool) {
        return transferAndCall(_to, _value, _data);
    }

    function transferAndCall(address _to, uint256 _value, bytes _data) whenNotPaused public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emitTransferWithData(msg.sender, _to, _value, _data);
        ERC667Receiver(_to).onTokenTransfer(msg.sender, _value, _data);
        return true;
    }

    function emitTransfer(address _from, address _to, uint256 _value) internal {
        emitTransferWithData(_from, _to, _value, "");
    }

    function emitTransferWithData(address _from, address _to, uint256 _value, bytes _data) internal {
        Transfer(_from, _to, _value, _data);
        Transfer(_from, _to, _value);
    }
}
