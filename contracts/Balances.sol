pragma solidity ^0.4.17;

import './KnownTokens.sol';
import './TBK.sol';
import './SafeMath.sol';

import './bancor_contracts/interfaces/IERC20Token.sol';
import './interfaces/IBalances.sol';
import './interfaces/IKnownTokens.sol';

/**
 * @title Balances
 * A contract that holds users funds securely.
 */
contract Balances {
    using SafeMath for uint;

    /// Address of the RewardDAO that deployed this contract.
    IRewardDAO rewardDAO;

    /// Address of the shared data store of known tokens in the network.
    KnownTokens knownTokens;

    /// Address of the user whose funds are kept in this contract.
    address user;

    /// A flag to determine if this contract has been withdrawn from.
    bool withdrawn = false;

    /// Wrapped ether token.
    address weth;

    /// Canonical TBK token.
    address tbk;

    /**
     * @dev Constructor
     * @param _rewardDAO Address of the RewardDAO that deployed this contract.
     * @param _knownTokens Address of the shared data store.
     * @param _user Address of the user whose funds are stored in this contract.
     */
    function Balances(address _rewardDAO,
                      address _knownTokens,
                      address _user,
                      address _weth,
                      address _tbk) {
        rewardDAO = IRewardDAO(_rewardDAO);
        knownTokens = KnownTokens(_knownTokens); 
        weth = _weth;
        tbk = _tbk;                  
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
     * @dev Pulls the tokens into the contract.
     * @param _user Address of the user whose savings contract is being added to
     * @param _token Address of the ERC20 token being deposited.
     * @param _amount Amount of said token being deposited into savings contract.
     */
    function pullDeposit(address _user, address _token, uint _amount)
        external
        onlyRewardDAO
        onlyNotWithdrawn
        returns (bool)
    {
        // require(knownTokens.containsToken(_token));
        
        IERC20Token token = IERC20Token(_token);
        token.transferFrom(_user, address(this), _amount);

        return true;
    }

    /**
     * @dev Withdraws said token from the balance to the original token holder account.
     * Must be called from the known RewardDAO contract.
     * @param _user Address of the user whose savings contract is being drawn from. 
     *              Must be the same as the owner of the safe/balance
     */
    function withdraw(address _user)
        onlyRewardDAO
        onlyNotWithdrawn
        returns (bool)
    {
        require(_user == user);

        address[20] memory tokens;
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
        return true;
    }

    /**
     * @dev Returns the TBK of this Savings Contract.
     */
    function queryTBKBalance()
        public constant returns (uint)
    {
        return IERC20Token(tbk).balanceOf(this);
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
     * @dev Sets the new KnownTokens address
     */
    function setKnownTokens(address _newKnownTokens) 
        onlyRewardDAO
    {
        require(knownTokens != _newKnownTokens);
        require(_newKnownTokens != 0x0);
        require(isContract(_newKnownTokens));

        delete knownTokens;
        knownTokens = KnownTokens(_newKnownTokens);
    }

    /// Deposit Event for when a user sends funds
    event Deposit(uint indexed amount, address token);

    /// Withdrawal Event for when a user pays withdrawal fee and pulls funds
    event Withdraw();
}