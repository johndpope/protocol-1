pragma solidity ^0.4.13;
import './bancor/solidity/contracts/SmartToken.sol';
import './Backdoor.sol';

contract AO is SmartToken, Backdoor {

    function AO() 
        SmartToken("SafeToken",
                   "AO",
                   18) {
        _;
    }
    
}