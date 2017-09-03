pragma solidity ^0.4.15;
import './AO.sol';
import './Backdoor.sol';            // temporary
import './SafeMath.sol';

import './interfaces/IBalances.sol';

/**
    The idea of this contract is that it will hold the business
    logic of user funds held in a Safe denominated in ether. 
    (Eventually supported ERC20 tokens as well.) We do this in
    order to isolate user funds from the higher level interface
    of the Safe in case we need to upgrade the Safe contract in
    the future we can do so with minimal impact (ideally, no impact)
    on the user.

 */
contract Balances is Backdoor, IBalances {
    using SafeMath for uint;

    uint MULTIPLIER = 1.0;              // The bonus for having AO deposits.

    AO safeToken;                       // Address of the official SafeToken
    IRewardDAO rewardDAO;               // The RewardDAO addresss.
    address user;

    event Deposit(uint indexed amount); // event released when deposit to safe successful

    /**
        @dev constructor

        @param _rewardDAO      address of rewardDAO, from which AO are being given (for interest)
        @param _safeToken      address of SafeToken
        @param _user           address of user whose balance this is
    */
    function Balances(address _rewardDAO,
                      address _safeToken,
                      address _user) {
        rewardDAO = IRewardDAO(_rewardDAO);
        safeToken = AO(_safeToken);                    
        user = _user;
    }

    /**
        @dev returns the balance associated with the message sender
    */
    function queryBalance()
        public constant returns (uint)
    {
        var etherValueOfSafeToken = safeToken.balanceOf(msg.sender).mul(MULTIPLIER);

        // TODO add function to AO for safeToken.balanceOfInEther();
        return this.balance.add(etherValueOfSafeToken);
    }

    function transfer()
        public
        payable
    {
        deposit(msg.value);
    }

    /** ----------------------------------------------------------------------------
        *                       Private helper functions                             *
        ---------------------------------------------------------------------------- */

    /**
        @dev fallback function to call the deposit function
    */
    /** function ()
        payable
    {
        deposit(msg.value);
    } */

    /**
        @dev deposits specified amount into

        @param  _amount      Amount (in safeTokens) being deposited into the vault
        @return boolean success of the deposit
    */
    function deposit(uint _amount)
        internal
    {
        require(msg.value == _amount);

        // Does the RewardDAO know about the deposit?
        if (isContract(rewardDAO)) {
            require(rewardDAO.onDeposit(_amount));
        } 

        // Bubble up ^
        Deposit(msg.value);
    }

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

        @param  _newSafeToken     New address associated with the rewardsDAO
    */
    function setSafeToken(address _newSafeToken) {
        require(safeToken != _newSafeToken);
        assert(_newSafeToken != 0x0);

        delete safeToken;
        safeToken = AO(_newSafeToken);
    }
}