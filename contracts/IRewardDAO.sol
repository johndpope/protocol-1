pragma solidity ^0.4.13;

contract IRewardDAO {
    // Arbitrates the deposits into Balances.sol
    function onDeposit(uint _amount) 
        returns (bool)
    {
        assert(true); // TODO
        Log(_amount);
        return true;
    }

    event Log(uint amount);
}