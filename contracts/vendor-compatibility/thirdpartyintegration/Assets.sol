// Copyright (C) 2017 Sweetbridge Foundation, Switzerland
// All Rights Reserved
// Unauthorized reproducing or copying of this work, via any medium is strictly prohibited
// Written by the Sweetbridge Foundation Team, https://sweetbridge.com/
//
pragma solidity ^0.4.17;

import "./tokens/ERC20.sol";
import "./authority/Roles.sol";


// AssetsLib provides funcitonality for managing assets which we represent as
// an ERC20 list
library AssetsLib {
    function assetsLen(ERC20[] storage self) public view returns(uint32) {
        return uint32(self.length);
    }

    // @returns array of token addresses and array of associated balances.
    function balances(ERC20[] storage self) internal view returns(address[], uint256[]) {
        address[] memory addrs = new address[](self.length);
        uint256[] memory bs = new uint256[](self.length);
        for (uint32 i = 0; i < self.length; ++i) {
            addrs[i] = address(self[i]);
            bs[i] = self[i].balanceOf(this);
        }
        return (addrs, bs);
    }

    function hasFunds(ERC20[] storage self) public view returns(bool nonZero) {
        for (uint32 i = 0; i < self.length; ++i) {
            nonZero = self[i].balanceOf(this) > 0 || nonZero;
        }
        return nonZero;
    }

    // @wad - the amount of tokens to add. Can be 0 - the motivation is to enable
    //   the accountant to see the tokens which he should manage
    function addAsset(
        ERC20[] storage self,
        ERC20 token,
        address src,
        uint128 wad) public
    {
        // limit the number of assets to avoid an OOG during operations
        if (wad > 0)
            require(src != address(0x0));
        var (, ok) = indexOf(self, token);
        if (!ok) {
            require(self.length < 255);
            self.push(token);
        }
        if (wad > 0)
            token.transferFrom(src, this, wad);
    }

    function rmAsset(ERC20[] storage self, ERC20 token, address dst) public returns(bool) {
        require(dst != address(0));
        var (i, ok) = indexOf(self, token);
        if (ok) {
            self[i].transfer(dst, self[i].balanceOf(this));
            rmAssetIdx(self, i);
            return true;
        }
        return false;
    }

    // returns the first index at which a given element can be found in the storage,
    // or -1 if it is not present.
    function indexOf(ERC20[] storage self, ERC20 token) public view returns(uint32, bool) {
        for (uint32 i = 0; i < self.length; ++i) {
            if (self[i] == token)
                return (i, true);
        }
        return (0, false);
    }

    function rmAssetIdx(ERC20[] storage self, uint32 idx) private {
        uint32 len = uint32(self.length) - 1;
        if (idx != len)
            self[idx] = self[len];
        delete self[len];
        self.length = len;
    }

    // Removes empty entries in assets storage
    function cleanStorage(ERC20[] storage self) public {
        uint32 len = uint32(self.length) - 1;
        for (var i = len; i >= 0; --i) {
            if (self[i].balanceOf(this) == 0 ) {
                if (i != len) {
                    self[i] = self[len];
                }
                delete self[len];
                --len;
            }
        }
        self.length = len;
    }
}


contract AssetEvents {
    event AssetAdded(address token, address owner, uint256 wad);
    event AssetRemoved(address token);
}


contract Assets is SecuredWithRoles, AssetEvents {
    using AssetsLib for ERC20[];
    ERC20[] public assets;

    function Assets(address[2] defaultTokens, string contractName, address rolesContract) SecuredWithRoles(contractName, rolesContract) public {
        for(uint32 i = 0; i < defaultTokens.length; i++) {
            if(defaultTokens[i] != address(0x0)) {
                addAsset(ERC20(defaultTokens[i]), address(0x0), 0);
            }
        }
    }

    function assetsLen() public view returns(uint256) {
        return assets.assetsLen();
    }

    function balanceOf(ERC20 token) public view returns(uint256) {
        return token.balanceOf(this);
    }

    function ethBalance() public view returns(uint256) {
        return this.balance;
    }

    function balances() public view returns(address[], uint256[]) {
        return assets.balances();
    }

    function hasFunds() public view returns(bool) {
        return assets.hasFunds() || this.balance > 0;
    }

    function addAsset(ERC20 token, address src, uint128 wad) public roleOrOwner("assetManager") {
        assets.addAsset(token, src, wad);
        AssetAdded(token, src, wad);
    }

    function transfer(ERC20 token, address dst, uint128 wad) stoppable public onlyOwner {
        token.transfer(dst, wad);
    }

    function transferEth(address dst, uint256 wad) stoppable public onlyOwner {
        dst.transfer(wad);
    }

    // @dst - address where the outstanding balance should be transferred.
    function rmAsset(ERC20 token, address dst) public onlyOwner stoppable returns(bool) {
        if(assets.rmAsset(token, dst)) {
            AssetRemoved(token);
            return true;
        }
        return false;
    }

    function cleanStorage() public roleOrOwner("assetManager") {
        assets.cleanStorage();
    }

    function () public payable {

    }
}
