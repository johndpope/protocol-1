pragma solidity ^0.4.15;

import './BNK.sol';
import './SafeMath.sol';

import './bancor_contracts/interfaces/IERC20Token.sol';
import './interfaces/IBalances.sol';
import './interfaces/IKnownTokens.sol';

/**
 * @title Balances of user funds, alternatively known as the Savings Contract
 */
contract Balances is IBalances {
    using SafeMath for uint;

    BNK bnkToken;                        // Address of the BNK Token
    IRewardDAO rewardDAO;                // Address of the Reward DAO
    IKnownTokens knownTokens;

    address user;                        // Address of the user who owns funds in this contract
    bool withdrawn = false;

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
                      address _user,
                      address _knownTokens) {
        rewardDAO = IRewardDAO(_rewardDAO);
        bnkToken = BNK(_bnkToken); 
        knownTokens = IKnownTokens(_knownTokens);                   
        user = _user;
    }

    modifier onlyRewardDAO() {
        require(msg.sender == address(rewardDAO));
        require(isContract(rewardDAO));
        _;
    }

    modifier onlyNotWithdrawn() {
        require(!withdrawn);
        _;
    }

    /**
        @dev Deposits a token into the user funds contract

         @param _user     Address of the user whose savings contract is being added to
         @param _token    Address of the ERC20 token being deposited, 0x0 for ether
         @param _amount   Amount of said token being deposited into savings contract
    */
    function pullDeposit(address _user, address _token, uint _amount)
        external
        onlyRewardDAO
        onlyNotWithdrawn
        returns (bool)
    {
        require(knownTokens.containsToken(_token));
        
        IERC20Token token = IERC20Token(_token);
        token.transferFrom(_user, address(this), _amount);

        return true;
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
        onlyNotWithdrawn
    {
        require(_user == user);

        address[] memory tokens;
        tokens = knownTokens.allTokens();
        for (uint i = 0; i < tokens.length; ++i) {
            if (tokens[i] != 0x0) {
                IERC20Token token = IERC20Token(tokens[i]);
                if (token.balanceOf(this) > 0) {
                    token.transfer(user, token.balanceOf(this));
                }
            }
        }
        withdrawn = true;
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
        @dev Sets the new KnownTokens address
    */
    function setKnownTokens(address _newKnownTokens) 
        onlyRewardDAO
    {
        require(knownTokens != _newKnownTokens);
        require(_newKnownTokens != 0x0);
        require(isContract(_newKnownTokens));

        delete knownTokens;
        knownTokens = BNK(_newbnkToken);
    }
}