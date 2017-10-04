/* global artifacts */

const BNK          = artifacts.require('BNK.sol');
const RewardDAO   = artifacts.require('RewardDAO.sol');
const KnownTokens = artifacts.require('KnownTokens.sol');

// below are all the bancor defined contracts
const EtherToken     = artifacts.require('bancor_contracts/EtherToken.sol');
const BancorFormula  = artifacts.require('bancor_contracts/BancorFormula.sol');
const BancorChanger  = artifacts.require('bancor_contracts/BancorChanger.sol');

// the below contracts are only included for testing purposes
const Balances = artifacts.require('Balances.sol');

// constants used in the Bancor deployment for token exchanges
const CHANGE_FEE = 10000; // 1%  : Bancor change fee for token conversion
const CRR = 250000;       // 25% : reserve ratio of ETH to BNK for Bancor in PPM

module.exports = async (deployer) => {
    await deployer.deploy(BNK);
    await deployer.deploy(BancorFormula);
    await deployer.deploy(EtherToken);

    await deployer.deploy(BancorChanger,
                BNK.address,
                BancorFormula.address,
                CHANGE_FEE,
                EtherToken.address,
                CRR);

    deployer.deploy(KnownTokens,
        BancorChanger.address);

    deployer.deploy(RewardDAO,
                BancorChanger.address,
                KnownTokens.address,
                BNK.address,
                EtherToken.address);
};