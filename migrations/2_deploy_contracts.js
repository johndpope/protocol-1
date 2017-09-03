/* global artifacts */
/* eslint-disable prefer-reflect */

const AO        = artifacts.require('AO.sol');
const Balances  = artifacts.require('Balances.sol');
const Backdoor  = artifacts.require('Backdoor.sol');
const RewardDAO = artifacts.require('RewardDAO.sol');

module.exports = async (deployer) => {
    deployer.deploy(Backdoor);
    await deployer.deploy(AO);
    deployer.deploy(RewardDAO, AO.address);
};