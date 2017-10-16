pragma solidity ^0.4.17;

contract Admin {
    address public admin;

    function Admin() {
        admin = msg.sender; 
    }
}