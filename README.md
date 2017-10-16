# TokenBnk Protocol 

TokenBnk is the world's first Ethereum-based savings account to hold ether and ERC20 tokens. It leverages the Bancor protocol Token Changer contract in order to autonomously manage paying out rewards to users in the same base currency that they hold. Users interact with the RewardDAO contract in order to deploy their own Savings Contract, an isolated contract which holds their funds securely. The RewardDAO is hooked in to a decentralized network of Savings Contracts in order to facilitate the deposits and withdraws of users into their respective contracts. On top of this network is introduced the notion of user-based rewards which get distributed throughout the network whenever a user withdraws their funds and pay the withdrawal fee.

### Smart Contract Arcitecture

 * RewardDAO.sol
 * Balances.sol (Savings Contract)
 * TBK.sol
 * bancor_contracts