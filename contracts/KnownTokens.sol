pragma solidity ^0.4.17;

import './TBK.sol';
import './bancor_contracts/EtherToken.sol';

import './interfaces/IKnownTokens.sol';
import './bancor_contracts/interfaces/ITokenChanger.sol';
import './bancor_contracts/interfaces/IERC20Token.sol';

/**
 * @title KnownTokens
 * Shared data store contract which keeps track of all of the known tokens
 * of the network and exposes an API for RewardDAO and user Balances to access
 * this information.
 */
contract KnownTokens {
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

    /**
     * @dev Returns an array of known tokens in the network.
     */
    function allTokens()
        public constant returns (address[20])
    {
        
        return allKnownTokens;
    }

    /**
     * @dev Function to return true if an address is a known token in this contract.
     * @param _token Address of the token being checked.
     * @return bool True if it is known, false if not.
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

    /**
     * @dev Queries the TokenChanger.
     * @param _fromToken Token one.
     * @param _toToken Token two.
     * @param _amount Amount of token being converted.
     */
    function getReturn(address _fromToken, address _toToken, uint _amount)
        public constant returns (uint)
    {
        /// Ensure the two tokens are different.
        assert(_fromToken != _toToken);

        ITokenChanger changer = priceDiscoveryMap[_fromToken][_toToken];
        return changer.getReturn(IERC20Token(_fromToken), IERC20Token(_toToken), _amount);
    }
}