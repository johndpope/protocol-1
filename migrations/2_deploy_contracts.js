/* global artifacts */
/* eslint-disable prefer-reflect */

const AO        = artifacts.require('AO.sol');
const RewardDAO = artifacts.require('RewardDAO.sol');

// the below contracts are only included for testing purposes
const EtherToken = artifacts.require('bancor_contracts/EtherToken.sol');
const Balances = artifacts.require('Balances.sol');

var debug = true;

module.exports = function(deployer) {
    deployer.deploy(AO);
    deployer.deploy(RewardDAO);

    if (debug) {
        deployer.deploy(EtherToken);
        deployer.deploy(Balances);
    }
};