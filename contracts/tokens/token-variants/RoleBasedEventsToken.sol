// Copyright (C) 2017 Sweetbridge Foundation, Switzerland
// All Rights Reserved
// Unauthorized reproducing or copying of this work, via any medium is strictly prohibited
// Written by the Sweetbridge Foundation Team, https://sweetbridge.com/
//

pragma solidity ^0.4.17;

import "../authority/Roles.sol";
import "./ERC20.sol";
import "./TokenLogic.sol";


contract TokenEvents {
    event LogBurn(address indexed src, uint256 wad);
    event LogMint(address indexed src, uint256 wad);
    event LogLogicReplaced(address newLogic);
}


contract Token is ERC20, SecuredWithRoles, TokenEvents {
    string public symbol;
    string public name; // Optional token name
    uint8 public decimals = 18; // standard token precision. override to customize
    TokenLogicI public logic;

    function Token(string name_, string symbol_, address rolesContract) public SecuredWithRoles(name_, rolesContract) {
        // you can't create logic here, because this contract would be the owner.
        name = name_;
        symbol = symbol_;
    }

    function totalSupply() public view returns (uint256) {
        return logic.totalSupply();
    }

    function balanceOf( address who ) public view returns (uint256 value) {
        return logic.balanceOf(who);
    }

    function allowance(address owner, address spender ) public view returns (uint256 _allowance) {
        return logic.allowance(owner, spender);
    }

    function setLogic(address logic_) public {
        // the logic contract can be set by anyone if it has not been set. It can only be replaced by the logic contract
        require(address(logic) == address(0x0) || msg.sender == address(logic));
        assert(logic_ != address(0));
        logic = TokenLogicI(logic_);
        LogLogicReplaced(logic);
    }

    function transfer(address dst, uint256 wad) public stoppable returns (bool) {
        bool retVal = logic.transfer(msg.sender, dst, wad);
        if (retVal) {
            Transfer(msg.sender, dst, wad);
        }
        return retVal;
    }

    function transferFrom(address src, address dst, uint256 wad) public stoppable returns (bool) {
        bool retVal = logic.transferFrom(src, dst, wad);
        if (retVal) {
            Transfer(src, dst, wad);
        }
        return retVal;
    }

    function approve(address guy, uint256 wad) public stoppable returns (bool) {
        bool ok = logic.approve(msg.sender, guy, wad);
        if (ok)
            Approval(msg.sender, guy, wad);
        return ok;
    }

    function pull(address src, uint256 wad) public stoppable returns (bool) {
        return transferFrom(src, msg.sender, wad);
    }

    function mintFor(address recipient, uint256 wad) public stoppable onlyRole("minter") {
        logic.mintFor(recipient, wad);
        LogMint(recipient, wad);
        Transfer(address(0x0), recipient, wad);
    }

    function burn(uint256 wad) public stoppable {
        logic.burn(msg.sender, wad);
        LogBurn(msg.sender, wad);
    }

    function setName(string name_) public roleOrOwner("admin") {
        name = name_;
    }
}
