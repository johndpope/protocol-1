pragma solidity ^0.4.15;


contract IProfitSharing {

  // inherited
    function owner() public constant returns(address);
    function pendingOwner() public constant returns(address);
    function destroy();
    function changeOwnership(address _to) returns(bool);
    function claimOwnership() returns(bool);

    function token() public constant returns(MiniMeToken);
    function RECYCLE_TIME() public constant returns(uint256);
    function dividends() public constant returns(Dividend);
    function depositDividend() payable;
    function claimDividend(uint256 _dividendIndex) public;
    function claimDividendAll() public;
    function recycleDividend(uint256 _dividendIndex) public;
}
