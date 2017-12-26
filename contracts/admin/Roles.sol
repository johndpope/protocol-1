// Copyright (C) 2017 Sweetbridge Foundation, Switzerland
// All Rights Reserved
// Unauthorized reproducing or copying of this work, via any medium is strictly prohibited
// Written by the Sweetbridge Foundation Team, https://sweetbridge.com/
//
pragma solidity ^0.4.17;

import "./Owned.sol";


contract SecuredWithRoles is Owned {
    Roles public roles;
    bytes32 public contractHash;
    bool public stopped = false;

    function SecuredWithRoles(string contractName_, address roles_) public {
        contractHash = keccak256(contractName_);
        roles = Roles(roles_);
    }

    modifier stoppable() {
        require(!stopped);
        _;
    }

    modifier onlyRole(string role) {
        require(senderHasRole(role));
        _;
    }

    modifier roleOrOwner(string role) {
        require(msg.sender == owner || senderHasRole(role));
        _;
    }

    // returns true if the role has been defined for the contract
    function hasRole(string roleName) public view returns (bool) {
        return roles.knownRoleNames(contractHash, keccak256(roleName));
    }

    function senderHasRole(string roleName) public view returns (bool) {
        return hasRole(roleName) && roles.roleList(contractHash, keccak256(roleName), msg.sender);
    }

    function stop() public roleOrOwner("stopper") {
        stopped = true;
    }

    function restart() public roleOrOwner("restarter") {
        stopped = false;
    }

    function setRolesContract(address roles_) public onlyOwner {
        // it must not be possible to change the roles contract on the roles contract itself
        require(this != roles);
        roles = Roles(roles_);
    }

}


contract RolesEvents {
    event LogRoleAdded(bytes32 contractHash, string roleName);
    event LogRoleRemoved(bytes32 contractHash, string roleName);
    event LogRoleGranted(bytes32 contractHash, string roleName, address user);
    event LogRoleRevoked(bytes32 contractHash, string roleName, address user);
}


contract Roles is RolesEvents, SecuredWithRoles {
    // mapping is contract -> role -> sender_address -> boolean
    mapping(bytes32 => mapping (bytes32 => mapping (address => bool))) public roleList;
    // the intention is
    mapping (bytes32 => mapping (bytes32 => bool)) public knownRoleNames;

    function Roles() SecuredWithRoles("RolesRepository", this) public {}

    function addContractRole(bytes32 ctrct, string roleName) public roleOrOwner("admin") {
        require(!knownRoleNames[ctrct][keccak256(roleName)]);
        knownRoleNames[ctrct][keccak256(roleName)] = true;
        LogRoleAdded(ctrct, roleName);
    }

    function removeContractRole(bytes32 ctrct, string roleName) public roleOrOwner("admin") {
        require(knownRoleNames[ctrct][keccak256(roleName)]);
        delete knownRoleNames[ctrct][keccak256(roleName)];
        LogRoleRemoved(ctrct, roleName);
    }

    function grantUserRole(bytes32 ctrct, string roleName, address user) public roleOrOwner("admin") {
        require(knownRoleNames[ctrct][keccak256(roleName)]);
        roleList[ctrct][keccak256(roleName)][user] = true;
        LogRoleGranted(ctrct, roleName, user);
    }

    function revokeUserRole(bytes32 ctrct, string roleName, address user) public roleOrOwner("admin") {
        delete roleList[ctrct][keccak256(roleName)][user];
        LogRoleRevoked(ctrct, roleName, user);
    }

}
