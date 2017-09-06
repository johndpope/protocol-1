/* global artifacts */

const AO        = artifacts.require('AO.sol');
const RewardDAO = artifacts.require('RewardDAO.sol');

// below are all the bancor defined contracts
const EtherToken    = artifacts.require('bancor_contracts/EtherToken.sol');
const BancorFormula = artifacts.require('bancor_contracts/BancorFormula.sol');
const BancorChanger = artifacts.require('bancor_contracts/BancorChanger.sol');

// the below contracts are only included for testing purposes
const Balances = artifacts.require('Balances.sol');

var debug = false;

module.exports = async (deployer) => {
    await deployer.deploy(AO);
    await deployer.deploy(BancorFormula);
    await deployer.deploy(EtherToken);

    await deployer.deploy(BancorChanger,
            AO.address,
            BancorFormula.address,
            10000,
            EtherToken.address,
            250000);

    deployer.deploy(RewardDAO, BancorChanger.address, EtherToken.address);
    if (debug) {
        deployer.deploy(Balances);
    }
}