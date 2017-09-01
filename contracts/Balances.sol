pragma solidity ^0.4.13;
import './AO.sol';
import './Backdoor.sol';            // temporary
import './SafeMath.sol';

/**
    The idea of this contract is that it will hold the business
    logic of user funds held in a Safe denominated in ether. 
    (Eventually supported ERC20 tokens as well.) We do this in
    order to isolate user funds from the higher level interface
    of the Safe in case we need to upgrade the Safe contract in
    the future we can do so with minimal impact (ideally, no impact)
    on the user.

 */
contract Balances is Backdoor {
    using SafeMath for uint;

    uint MULTIPLIER = 1.0;              // The bonus for having AO deposits. 

    AO safeToken;                       // Address of the official SafeToken
    IRewardDAO rewardDAO;               // The RewardDAO addresss.
    address user;

    function Balances(address _rewardDAO,
                      address _safeToken,
                      address _user) {
        rewardDAO = IRewardDAO(_rewardDAO);
        safeToken = AO(_safeToken);                    
        user = _user;
    }

    function queryBalance()
        public constant returns (uint)
    {
        var etherValueOfSafeToken = safeToken.balanceOf(msg.sender).mul(MULTIPLIER);

        // TODO add function to AO for safeToken.balanceOfInEther();
        return this.balance.add(etherValueOfSafeToken);
    }

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
    /// @dev Fallback function to call the deposit function.
    function ()
        payable
    {
        deposit(msg.value);
    }

    /// @dev Sets a new official address of the AO.
    function setSafeToken(address _newSafeToken) {
        require(safeToken != _newSafeToken);
        assert(_newSafeToken != 0x0);

        delete safeToken;
        safeToken = AO(_newSafeToken);
    }

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
        return size>0;
    }

    event Deposit(uint indexed amount); // event released when deposit to safe successful
}