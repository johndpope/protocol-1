// Copyright (C) 2017 Sweetbridge Foundation, Switzerland
// All Rights Reserved
// Unauthorized reproducing or copying of this work, via any medium is strictly prohibited
// Written by the Sweetbridge Foundation Team, https://sweetbridge.com/
//
pragma solidity ^0.4.17;

import "../authority/Owned.sol";


contract TokenData is Owned {
    uint256 public supply;
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public approvals;
    address logic;

    modifier onlyLogic {
        assert(msg.sender == logic);
        _;
    }

    function TokenData(address logic_, uint256 supply_, address owner_) public {
        logic = logic_;
        supply = supply_;
        owner = owner_;
        balances[owner] = supply;
    }

    function setTokenLogic(address logic_) public onlyLogic {
        logic = logic_;
    }

    function setSupply(uint256 supply_) public onlyLogic {
        supply = supply_;
    }

    function setBalances(address guy, uint256 balance) public onlyLogic {
        balances[guy] = balance;
    }

    function setApprovals(address src, address guy, uint256 wad) public onlyLogic {
        approvals[src][guy] = wad;
    }


}
