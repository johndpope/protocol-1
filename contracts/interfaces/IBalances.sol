pragma solidity ^0.4.13;

contract IBalances {
    function queryBalance() public constant returns (uint);
    function transfer() public payable;
}