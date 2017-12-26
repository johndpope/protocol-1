pragma solidity ^0.4.13;

import "github.com/DecentralizedDerivatives/OraclizeBaseContract/Swap.sol";

contract Factory {
    address[] public newContracts;
    address creator;
    uint public fee; //Cost of contract in Wei
    modifier onlyOwner{require(msg.sender == creator); _;}
    event Print(address _name, address _value);
    event FeeChange(uint _newValue);

    function Factory (){
        creator = msg.sender; 
        fee = 10e15; 
    }

    function createContract () payable returns (address){
        require(msg.value == fee);
        address newContract = new Swap(msg.sender);
        newContracts.push(newContract);
        Print(msg.sender,newContract); //This is an event and allows DDA/ participants to see when new contracts are pushed.
        return newContract;
    } 
    function withdrawFee() onlyOwner {
        creator.transfer(this.balance);
    }
}
