const BigNumber = require('bignumber.js')

const BancorFormula = artifacts.require('../contracts/bancor_contracts/BancorFormula.sol')
const RewardDAO = artifacts.require('../contracts/RewardDAO.sol')
const TokenChanger = artifacts.require('../contracts/bancor_contracts/BancorChanger.sol')
const TBK = artifacts.require('../contracts/TBK.sol')
const Weth = artifacts.require('../contracts/bancor_contracts/EtherToken.sol')

contract('RewardDAO', function(accounts) {
    const tester = accounts[0]
    const user1 = accounts[1]
    const user2 = accounts[2]
    const user3 = accounts[3]

    let bancorFormula
    let rewardDAO
    let tokenChanger
    let tbk 
    let weth

    it('Deploys all contracts', async function() {
        /// Deploys tokens
        weth = await Weth.new()
        tbk = await TBK.new()

        /// Deploys token changer
        let changeFee = 0
        let ccr = 250000
        bancorFormula = await BancorFormula.new()
        tokenChanger = await BancorChanger.new(tbk,
                                         banocrFormula,
                                         changeFee,
                                         weth,
                                         ccr)

        /// Deploys RewardDAO
        rewardDAO = await RewardDAO.new(weth.address,
                                  tbk.address,
                                  tokenChanger.address)
        
        /// Assert rewardDAO is deployed
        assert(rewardDAO)
    })
})