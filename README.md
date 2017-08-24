# The Safecontract Protocol

### Preamble

The Safecontract protocol is a platform in which users can securely hold their crypto-assets on the Ethereum blockchain.
We augment this basic functionality with the Safecontroller (alternatively known as the Reward DAO) which presents a higher-
level contract on top of the basic Safe vaults. The Safecontroller is the user-facing API for the underlying network of vaults,
as well as the contract which determines the logic to pay out *interest* to holders. The Safecontroller topples legacy
financial institutions as an alternative way to store and earn on interest on value.

### Architecture
 - Safecontroller
   * a
   * b 
   * c
 - Safe
   * Holds user funds denominated in either Ether or supported ERC20 token.
   * Seperates logic into two contracts, the `Balances` contract which holds business logic of user funds, and the `SafeInterface` contract which is an upgradable contract in case the need arises.
 - SafeToken (AO)
   * The SafeToken is the internal currency of the Safecontract protocol and is used to withdraw funds from a user's Safe. 
   * The ticker symbol of the SafeToken is AO.
 - Bancor
   * The Safecontract Protocol uses the Bancor protocol as a way to provide always available liquidity to users wishing to buy AO to withdraw their funds.
   * We forked the official Bancor repo on August 24, 2017. If we incorporate upstream changes we will update the changelog.
  
