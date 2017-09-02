pragma solidity ^0.4.13;

contract IRewardDAO {
    // Arbitrates the deposits into Balances.sol
    function onDeposit(uint _amount) public returns (bool);
    function getEthBalance() public returns (uint);
}