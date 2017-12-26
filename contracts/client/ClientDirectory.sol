pragma solidity ^0.4.17;

import "./Root.sol";
import "./authority/Roles.sol";


contract ClientDirectoryFactory is ClientDirectoryFactoryI {
    function createClientDirectory(address root, address client, address rolesContract) public returns (address) {
        return new ClientDirectory(root, client, rolesContract);
    }
}


contract ClientDirectoryEvents {
    event LogWalletAdded(address newWallet);
    event LogWalletRemoved(address removedWallet);
}


contract ClientDirectory is ClientDirectoryEvents, SecuredWithRoles {
    RootI public root; // needs to be public in order to be accessible in Wallet
    WalletFactoryI walletFactory;
    string public profile; //hash of the profile data
    bool public kyc = false;

    address[] public wallets;

    function ClientDirectory(
        address root_,
        address owner_,
        address rolesContract) public SecuredWithRoles("ClientDirectory", rolesContract)
    {
        require(root_ != address(0));
        require(owner_ != address(0));

        owner = owner_;
        root = RootI(root_);
    }

    function setKYC(bool kyc_) public onlyRole("clientManager") {
        kyc = kyc_;
    }

    function walletCount() public view returns (uint32) {
        return uint32(wallets.length);
    }

    function addWallet(bytes3 currency) public roleOrOwner("clientManager") {
        address wallet = root.walletFactory().createWallet(this, currency);
        // limit the number of wallets to avoid an OOG during operations
        require(wallets.length < 255);
        wallets.push(wallet);
        LogWalletAdded(wallet);
    }

    function removeWallet(address wallet_) public onlyOwner {
        int found = -1;
        for (uint256 i = 0; i < wallets.length; i++) {
            if (wallets[i] == wallet_) {
                found = int(i);
                break;
            }
        }
        if (found >= 0) {
            uint256 len = wallets.length - 1;
            wallets[uint256(found)] = wallets[len];
            wallets.length = len;
            LogWalletRemoved(address(wallet_));
        }
    }
}
