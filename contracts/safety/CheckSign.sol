pragma solidity ^0.4.11;


contract CheckSign {
  function recoverAddr(bytes32 msgHash, uint8 v, bytes32 r, bytes32 s) public pure returns (address) {
    return ecrecover(msgHash, v, r, s);
  }

  function isSigned(address _addr, bytes32 msgHash, uint8 v, bytes32 r, bytes32 s) public pure returns(bool) {
    return ecrecover(msgHash, v, r, s) == _addr;
  }

  function recoverTypedSignAddr(uint value, uint8 v, bytes32 r, bytes32 s) public pure returns (address) {
    return ecrecover(hashTyped(value), v, r, s);
  }

  function isTypedSigned(address _addr, uint value, uint8 v, bytes32 r, bytes32 s) public pure returns (bool) {
    return ecrecover(hashTyped(value), v, r, s) == _addr;
  }

  function recoverTypedSignAddrDb(uint value, string mess, uint8 v, bytes32 r, bytes32 s) public pure returns (address) {
    return ecrecover(hashTypedDb(value, mess), v, r, s);
  }

  function hashTyped(uint value) internal pure returns (bytes32) {
    //var h1 = keccak256("uint message");
    var h2 = keccak256(value);
    //return keccak256(h1, h2);
    return keccak256(0xa0cad2a27d1258dabaed1f22e79f9d5873088cd468085ac27127d7185f9925b1, h2);
  }

  function hashTypedDb(uint value, string mess) internal pure returns (bytes32) {
    //var h1 = keccak256("string Message", "uint Amount");
    // web3.sha3(web3.toHex("string Message").slice(2) + web3.toHex("uint Amount").slice(2), {encoding:"hex"});
    var h2 = keccak256(mess, value);
    //return keccak256(h1, h2);
    return keccak256(0xf00e8d27afc037c5911f30fcfc5774e3a9910b51ca7483071b1bea584c51e4b0, h2);
  }

  function getLit() public pure returns (bytes32) {
    return keccak256("string Message", "uint Amount");
  }
}
