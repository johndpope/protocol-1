pragma solidity ^0.4.17;

import './TBK.sol';
import './bancor_contracts/EtherToken.sol';
import './PriceDiscovery.sol';

import './interfaces/IPriceDiscovery.sol';
import './interfaces/IKnownTokens.sol';
import './bancor_contracts/interfaces/ITokenChanger.sol';

/**
 * @title KnownTokens
 * Shared data store contract which keeps track of all of the known tokens
 * of the network and exposes an API for RewardDAO and user Balances to access
 * this information.
 */
contract KnownTokens is IKnownTokens {
    ITokenChanger tokenChanger;

    /// Takes a token pair and discovers the address of the Token Changer.
    mapping(address => mapping(address => ITokenChanger)) priceDiscoveryMap;

    address[20] public allKnownTokens;
    uint8 constant public MAX_TOKENS = 20;

    // /**
    //  * @dev Constructor
    //  * @param  _tokenChanger   Address of the token changer (i.e. Bancor changer)
    //  */
    // function KnownTokens(ITokenChanger _tokenChanger) {
    //     tokenChanger = _tokenChanger;
    // }

    /**
        @dev Given the address of two tokens, determines what the conversion is, i.e.
        how many of token1 are in a single token2

        @param  _fromToken   FROM token address (i.e. conversion source)
        @param  _toToken     TO   token address (i.e. conversion destination)

    */
    function recoverPrice(address _fromToken, address _toToken)
        public constant returns (uint)
    {
        //TODO: implement function
        assert(_fromToken != _toToken); // ensure not doing useless conversion to same token
        var res = priceDiscoveryMap[_fromToken][_toToken];
        return res.exchangeRate();
    }

    /**
     * @dev Adds a new token pair with the price discovery method into the network.
     * @param _tokenOne A token to be added.
     * @param _tokenTwo A token to be added.
     * @param _tokenChanger The token changer which allows for price discovery between the two tokens.
    */
    function addTokenPair(address _tokenOne, address _tokenTwo, address _tokenChanger)
        // TODO: Add onlyOwner or onlyRewardDAO modifier
        public returns (bool)
    {
        require(allKnownTokens.length <= MAX_TOKENS - 2);
        for (uint i = 0; i < allKnownTokens.length; i++) {
            
        }
        priceDiscoveryMap[_tokenOne][_tokenTwo] = ITokenChanger(_tokenChanger);
        return true; //priceDiscoveryMap[_tokenOne][_tokenTwo].exists();
    }

    function allTokens()
        public constant returns (address[20])
    {
        
        return allKnownTokens;
    }

    /**
        @dev Generic search function for finding an entry in address array.

        @param _token   Address of the token of interest (to see whether registered)
        @return  boolean indicating if the token was previously registered (true) or not (false)
    */
    function containsToken(address _token)
        public constant returns (bool)
    {
        for (uint i = 0; i < MAX_TOKENS; ++i) {
            if (_token == allKnownTokens[i]) {return true;}
        }
        return false;
    }

    function addTokenChanger(address _tokenChanger) {
    }
}