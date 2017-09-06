pragma solidity ^0.4.15;
import './AO.sol';
import './Backdoor.sol';            // temporary
import './SafeMath.sol';

import './interfaces/IBalances.sol';

/**
    Balances.sol is in charge of holding user funds. It is alternatively
    known as the "Savings Contract."
 */
contract Balances is Backdoor, IBalances {
    using SafeMath for uint;

    AO saveToken;                       // Address of the official Save Token
    IRewardDAO rewardDAO;               // The RewardDAO addresss.
    address user;

    event Deposit(uint indexed amount); // Event of successful deposit.

    /**
        @dev constructor

        @param _rewardDAO The RewardDAO address.
        @param _safeToken The Save Token address.
        @param _user      The user address, whose balances these are.
    */
    function Balances(address _rewardDAO,
                      address _saveToken,
                      address _user) {
        rewardDAO = IRewardDAO(_rewardDAO);
        saveToken = AO(_saveToken);                    
        user = _user;
    }

    modifier onlyRewardDAO() {
        assert(msg.sender == address(rewardDAO));
        _;
    }

    /**
        @dev Deposits said token into the balance.
             Must be called from the known RewardDAO contract.

         @param _user     Address of the user whose savings contract is being added to
         @param _token    Address of the ERC20 token being deposited, or the ether wrapper
         @param _amount   Amount of said token being deposited into savings contract
    */
    function deposit(address _user, address _token, uint _amount)
        onlyRewardDAO
    {
        require(isContract(rewardDAO));
        require(msg.sender == address(rewardDAO));

        IERC20Token token = IERC20Token(_token);
        token.transferFrom(_user, address(this), _amount);
        assert(rewardDAO.onDeposit(_amount)); // TODO: Double check if we need this
        Deposit(_amount, _token);             // TODO: Double check if we need this
    }

    // TODO: Implementation
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
    }

    /**
        @dev Returns the balance (in AO) of the Savings Contract associated with user

        @param _user User for which Balance amount to be read.
    */
    function queryBalance(address _account)
        public constant returns (uint)
    {
        return saveToken.balanceOf(_account);
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
        @dev sets a new official address of the AO

        @param  _newSaveToken New address associated with the RewardDAO.
    */
    function setSaveToken(address _newSaveToken) {
        require(saveToken != _newSaveToken);
        assert(_newSaveToken != 0x0);

        delete saveToken;
        saveToken = AO(_newSaveToken);
    }
}