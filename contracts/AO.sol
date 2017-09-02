pragma solidity ^0.4.13;
import './Backdoor.sol';
import './interfaces/IRewardDAO.sol';
import './bancor_contracts/SmartToken.sol';

contract AO is SmartToken, Backdoor {
    IRewardDAO rewardDAO;

    function AO() 
        SmartToken("SafeToken", "AO", 18)
    {}
}