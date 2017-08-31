pragma solidity ^0.4.15;
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

    uint MULTIPLIER = 1.0;              // TODO: Describe what this does and have it be dynamic?

    AO safeToken;                       // Address of the official SafeToken
    address connectedContract;          // The Safe contract addresss.

    event Deposit(uint indexed amount); // event released when deposit to safe successful

    function Balances(address _contract,
                      address _safeToken) {
        connectedContract = _contract;
        safeToken = AO(_safeToken);                    
    }

    function queryBalance()
        public constant returns (uint)
    {
        var etherValueOfSafeToken = safeToken.balanceOf(msg.sender).mul(MULTIPLIER);

        // TODO add function to AO for safeToken.balanceOfInEther();
        return this.balance.add(etherValueOfSafeToken);
    }

    function deposit()
        public payable returns (bool)
    {
        assert(msg.sender == connectedContract);
        assert(msg.value > 0);

        Deposit(msg.value);
    }

    function ()
        payable
    {
        deposit();
    }

    /// @dev Sets a new official address of the AO.
    function setSafeToken(address _newSafeToken) {
        require(safeToken != _newSafeToken);
        assert(_newSafeToken != 0x0);

        delete safeToken;
        safeToken = AO(_newSafeToken);
    }
}