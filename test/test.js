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
var ao = null;
var rewardDao = null;
var etherToken = null;
var balances = null;

const ether = 1000000000000000000;

AO.deployed().then(function(i) { ao = i; })
RewardDAO.deployed().then(function(i) { rewardDao = i; })
EtherToken.deployed().then(function(i) { etherToken = i; })
Balances.deployed().then(function(i) { balances = i; })

etherToken.deposit( { value: 50 * ether } );
web3.fromWei(web3.eth.getBalance(etherToken.address)); // check successful transfer

// sets up event listeners
var vaultCreated = rewardDao.VaultCreated();
vaultCreated.watch(function(error, result) { if (error == null) { console.log(result.args); } });

var deposit = rewardDao.Deposit();
deposit.watch(function(error, result) { if (error == null) { console.log(result.args); } });

/* ---------------------------------------------------------------------------- *
 *                              Deploys Vault                                   * 
 * ---------------------------------------------------------------------------- */
rewardDao.deployVault(); // deploys the vault for our user
rewardDao.deployVault(); // should do nothing -> cannot deploy 2 vaults

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
etherToken.approve(rewardDao.address, 10 * ether);
rewardDao.deposit(etherToken.address, 10 * ether);

rewardDao.withdraw(); 

