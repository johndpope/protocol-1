/* ---------------------------------------------------------------------------- *
 *                                General Notes                                 *
 * ---------------------------------------------------------------------------- *
 * This is NOT intended to be a thorough or automatic testing script -- this is *
 * instead intended to be a manual REPL-like testing script for debugging and   *
 * manual testing for verification. This will likely only be used in initial    *
 * stages of development and may be shortly deprecated                          * 
 * ---------------------------------------------------------------------------- */

/* ---------------------------------------------------------------------------- *
 *                                 Helper Calls                                 * 
 * ---------------------------------------------------------------------------- */
// below are general helper functions
web3.personal.unlockAccount(web3.eth.coinbase)

/* ---------------------------------------------------------------------------- *
 *                                   Test Setup                                 * 
 * ---------------------------------------------------------------------------- */
// variables pointing to deployed contracts
var BNK = null;
var rewardDAO = null;
var etherToken = null;
var balances = null;

const ether = 1000000000000000000;

BNK.deployed().then(function(i) { BNK = i; })
RewardDAO.deployed().then(function(i) { rewardDAO = i; })
EtherToken.deployed().then(function(i) { etherToken = i; })
Balances.deployed().then(function(i) { balances = i; })

etherToken.deposit( { value: 50 * ether } );
web3.fromWei(web3.eth.getBalance(etherToken.address)); // check successful transfer

// sets up event listeners
var vaultCreated = rewardDAO.VaultCreated();
vaultCreated.watch(function(error, result) { if (error == null) { console.log(result.args); } });

var deposit = rewardDAO.Deposit();
deposit.watch(function(error, result) { if (error == null) { console.log(result.args); } });

/* ---------------------------------------------------------------------------- *
 *                              Deploys Vault                                   * 
 * ---------------------------------------------------------------------------- */
rewardDAO.deployVault(); // deploys the vault for our user
rewardDAO.deployVault(); // should do nothing -> cannot deploy 2 vaults

/* ---------------------------------------------------------------------------- *
 *                         Testing for ERC Balances                             * 
 * ---------------------------------------------------------------------------- */
// example balance addr: 0x5cad749a4cbf7e268e90579be75fa2abb44a6d9f
etherToken.transfer("0x5cad749a4cbf7e268e90579be75fa2abb44a6d9f", 60 * ether); // should error

etherToken.approve(web3.eth.coinbase, 20 * ether);
etherToken.transferFrom(web3.eth.coinbase, "0x5cad749a4cbf7e268e90579be75fa2abb44a6d9f", 20 * ether); 
// now: balance -> 20 ETH, web3.eth.coinbase -> 30 ETH

etherToken.withdraw(35 * ether); // should error
etherToken.withdraw(30 * ether); // should work
web3.fromWei(web3.eth.getBalance(web3.eth.coinbase)); // confirm (should be 80 ETH)

/* ---------------------------------------------------------------------------- *
 *                             SafeContract Testing                             * 
 * ---------------------------------------------------------------------------- */
// deposit the ether coins from RewardDAO: mints ERC20 wrappers and track in vault
etherToken.approve(rewardDAO.address, 10 * ether);
rewardDAO.deposit(etherToken.address, 10 * ether);

rewardDAO.withdraw(); 

