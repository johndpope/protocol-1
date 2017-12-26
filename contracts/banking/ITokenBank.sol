pragma solidity ^0.4.11;

contract ITokenBank {
  function deposits() public constant returns([object Object]);
  function tokenBalances() public constant returns(uint);
  function tokens() public constant returns(address);
  function nonce() public constant returns(uint);
  function depositEther(bytes _data) payable;
  function depositToken(address _token, bytes _data);
  function deposit(address _from, uint256 _amount, address _token, bytes _data);
  function watch(address _tokenAddr);
  function refund(address _token) returns (bool);
  function tokenFallback(address _from, uint _amount, bytes _data);
  function receiveApproval(address _from, uint256 _amount, address _token, bytes _data);
}
