pragma solidity ^0.4.15;
import './Backdoor.sol';
import './interfaces/IRewardDAO.sol';
import './bancor_contracts/SmartToken.sol';

/**
 * The TBK_Token (TBK) is an implementation of the Smart Token.
 */
contract TBK is SmartToken, Backdoor {
    IRewardDAO rewardDAO;

    function TBK()
        SmartToken("TBK_Token", "TBK", 18)
    {}
}