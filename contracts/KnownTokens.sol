pragma solidity ^0.4.15;
import './AO.sol';

import './bancor_contracts/EtherToken.sol';

/**
    KnownTokens.sol is a shared data store contract between the RewardDao
    and the user Balances. It allows for a central store for both
    contracts to call access from, and (TODO) opens an API to add
    more supported tokens to the Safecontract network.
 */
contract KnownTokens {
    EtherToken etherToken;  
    AO safeToken;

    //         token1  =>         token2  => priceDiscovery
    // mapping(address => mapping(address => IPriceDiscovery)) priceDiscovery;
    //    EG. priceDiscovery[token1][token2].exchangeRate(); 

    // We add in etherToken and safeToken as defaults to the network. (TODO) In
    // the future we will use this contract to make it easy to add more supported
    // tokens to the Safecontract network.
    address[] public knownTokens;

    function KnownTokens(address _etherToken, address _safeToken) {
        etherToken = _etherToken;
        safeToken = _safeToken;

        knownTokens.push(etherToken);
        knownTokens.push(safeToken);
    }



    // function addToken(address _tokenAddr)
}