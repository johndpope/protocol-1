pragma solidity ^0.4.16;

import ".././math/SafeMath.sol";
import ".././ownership/Ownable.sol";


/// @title Vested Payment
/// @dev Version 1.618


contract VestedPayment is Ownable {
    using SafeMath for uint256;

    // When the vested schedule starts
    uint256 public startTimestamp;

    // How many seconds each period will last
    uint256 public secondsPerPeriod;

    // How many periods will have in total
    uint256 public totalPeriods;

    // The amount of tokens to be vested in total
    uint256 public tokens;

    // How many tokens were claimed
    uint256 public claimed;

    // The token contract
    /// Token public token; /// Must be specified for token veing vested

    // Duration (in periods) of the initial cliff in the vesting schedule
    uint256 public cliffDuration;

  /**
    @dev Constructor.
    @param _startTimestamp see `startTimestamp`
    @param _secondsPerPeriod see `secondsPerPeriod`
    @param _totalPeriods see `totalPeriods
    @param _cliffDuration see `cliffDuration`
    @param _tokens see `tokens`
    @param tokenAddress the address of the token contract
   */
    function VestedPayment (
        uint256 _startTimestamp,
        uint256 _secondsPerPeriod,
        uint256 _totalPeriods,
        uint256 _cliffDuration,
        uint256 _tokens,
        address _tokenAddress
    ) {
        require(_startTimestamp >= block.timestamp);
        require(_secondsPerPeriod > 0);
        require(_totalPeriods > 0);
        require(_tokenAddress != address(0));
        require(_cliffDuration < _totalPeriods);
        require(_tokens > 0);
        startTimestamp = _startTimestamp;
        secondsPerPeriod = _secondsPerPeriod;
        totalPeriods = _totalPeriods;
        cliffDuration = _cliffDuration;
        tokens = _tokens;
       /// token = _tokenAddress; // TokenName(_tokenAddress); can also be used to specify a token
    }

    /**
    * @dev Get quantity of tokens available to be claimed
    * @returns 0 if timestamp is before vesting cliff duration
    */
    function getAvailableTokens() public constant returns (uint256) {
        uint256 period = block.timestamp.sub(startTimestamp)
        .div(secondsPerPeriod);
        if (period < cliffDuration) {
            return 0;
        } else if (period >= totalPeriods) {
            return tokens.sub(claimed);
        } else {
            return tokens.mul(period.add(1)).div(totalPeriods).sub(claimed);
        }
    }

  /**
    * @dev Claim tokens by the owner of the contract
    * @param amount how many tokens to be claimed
    */
    function claimTokens(uint256 amount) public onlyOwner {
        assert(getAvailableTokens() >= amount);
        claimed = claimed.add(amount);
       /// token.transfer(owner, amount);
    }

}
