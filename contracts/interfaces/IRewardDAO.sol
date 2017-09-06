pragma solidity ^0.4.15;

contract IRewardDAO {
    // function getEthBalance() public returns (uint);

    function onDeposit(uint _amount) public returns (bool);

    function claim() public payable;
    function deposit(address _token, uint _amount) public payable;
    function withdraw() public payable;
}