pragma solidity 0.4.15;

library Util {
        
    /**
     * @dev Determines whether the passed in address is a contract or user account.
     * @param  _addr Address being investigated.
     * @return boolean Whether or not we are looking at valid contract.
     */
    function isContract(address _addr) 
        constant internal returns(bool)
    {
        uint size;
        if (_addr == 0) {
            return false;
        }
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }
}