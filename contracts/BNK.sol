pragma solidity ^0.4.15;
import './Backdoor.sol';
import './interfaces/IRewardDAO.sol';
import './bancor_contracts/SmartToken.sol';

/**
 * The BNK_Token (BNK) is an implementation of the Smart Token.
 */
contract BNK is SmartToken, Backdoor {
    IRewardDAO rewardDAO;

    function BNK()
        SmartToken("BNK_Token", "BNK", 18)
    {}
}