pragma solidity ^0.4.13;
import './bancor_contracts/SmartToken.sol';
import './Backdoor.sol';

contract AO is SmartToken, Backdoor {

    function AO() 
        SmartToken("SafeToken", "AO", 18)
    {}
}