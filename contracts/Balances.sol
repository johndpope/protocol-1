pragma solidity ^0.4.15;
import './BNK.sol';
import './KnownTokens.sol';
import './SafeMath.sol';

import './bancor_contracts/interfaces/IERC20Token.sol';
import './interfaces/IBalances.sol';

/**
 * Balances of user funds, alternatively known as the Savings Contract
 */
contract Balances is IBalances {
    using SafeMath for uint;

    BNK bnkToken;                        // Address of the BNK Token
    IRewardDAO rewardDAO;                // Address of the Reward DAO
    KnownTokens knownTokens;
    address user;                        // Address of the user who owns funds in this contract

    /// Deposit Event for when a user sends funds
    event Deposit(uint indexed amount, address token);
    /// Withdrawal Event for when a user pays withdrawal fee and pulls funds
    event Withdraw();

    /**
        @dev constructor

        @param _rewardDAO Address of the Reward DAO
        @param _bnkToken  Address of BNK Token
        @param _user      The user whose funds are stored in the contract
    */
    function Balances(address _rewardDAO,
                      address _bnkToken,
                      address _user) {
        rewardDAO = IRewardDAO(_rewardDAO);
        bnkToken = BNK(_bnkToken);                    
        user = _user;
        knownTokens = _knownTokens;
    }

    modifier onlyRewardDAO() {
        require(msg.sender == address(rewardDAO));
        require(isContract(rewardDAO));
        _;
    }

    /**
        @dev Deposits a token into the user funds contract

         @param _user     Address of the user whose savings contract is being added to
         @param _token    Address of the ERC20 token being deposited, 0x0 for ether
         @param _amount   Amount of said token being deposited into savings contract
    */
    function deposit(address _user, address _token, uint _amount)
        onlyRewardDAO
    {
        IERC20Token token = IERC20Token(_token);
        token.transferFrom(_user, address(this), _amount);

        require(rewardDAO.onDeposit(_amount)); // TODO: Implement this? 
        Deposit(_amount, _token);
    }

    /**
        @dev Withdraws said token from the balance to the original token holder account.
             Must be called from the known RewardDAO contract.

         @param _user     Address of the user whose savings contract is being drawn from
                          Must be the same as the owner of the safe/balance
         @param _token    Address of the ERC20 token being deposited, or the ether wrapper
    */
    function withdraw(address _user)
        onlyRewardDAO
    {
        // TODO: Similar concerns as above. I believe this would be the right
        //       way to go about it but it needs more thought behind it. We could 
        //       do the verification checks in the RewardDAO function that calls this
        //       one. And then in here do something like:
        assert(_user == user);
        // TODO: Right now it would be most straight forward to do a complete
        //       withdrawal, but we should keep thinking about ways to eventually
        //       implement incrementally withdrawals. Anyway, I digress the main point
        //       is that we might need to store the tokens in RewardDAO and the balances,
        //       and then verify that the address array store of both RewardDAO and Balances
        //       is the same... Maybe we should extract out another contract for this,
        //       something like "VerifiedTokens.sol" or "SupportedTokens.sol" so that
        //       we can share this information across the two contracts as well as shortening
        //       the current implementation of RewardDAO.

        address[] memory tokens;
        tokens = knownTokens.allTokens();
        for (uint i = 0; i < tokens.length; ++i) {
            IERC20Token token = IERC20Token(tokens[i]);
            if (token.balanceOf(this) > 0) {
                token.transfer(user, token.balanceOf(this));
            }
        }

    }

    ///TODO add a function to switch out the known tokens contract.

    /**
        @dev Returns the balance (in BNK) of the Savings Contract associated with user

        @param _account User for which Balance amount to be read.
    */
    function queryBalance(address _account)
        public constant returns (uint)
    {
        return bnkToken.balanceOf(_account);
    }

    /** ----------------------------------------------------------------------------
        *                       Private helper functions                             *
        ---------------------------------------------------------------------------- */

    /**
        @dev determines whether or not the address pointed to corresponds to a valid contract address

        @param  _addr             Address being investigated
        @return boolean of whether or not we are looking at valid contract
    */
    function isContract(address _addr) 
        constant internal returns(bool)
    {
        uint size;
        if (_addr == 0) {
            return false;
        }
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }

    /**
        @dev sets a new official address of the BNK

        @param  _newbnkToken New address associated with the RewardDAO.
    */
    function setbnkToken(address _newbnkToken) {
        require(bnkToken != _newbnkToken);
        assert(_newbnkToken != 0x0);

        delete bnkToken;
        bnkToken = BNK(_newbnkToken);
    }
}