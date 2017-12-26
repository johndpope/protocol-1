pragma solidity ^0.4.16;


contract InputValidator {

    /// @notice throws if ether was sent accidentally
    modifier refundEtherSentByAccident() {
        require(msg.value <= 0);
        _;
    }

    /// @notice throw if an address is invalid
    /// @param _target the address to check
    modifier throwIfAddressIsInvalid(address _target) {
        require(_target != 0x0 && _target != address(0));
        _;
    }

    /// @notice throw if the id is invalid
    /// @param _id the ID to validate
    modifier throwIfIsEmptyString(string _id) {
        require(bytes(_id).length != 0);
        _;
    }

    /// @notice throw if the uint is equal to zero
    /// @param _id the ID to validate
    modifier throwIfEqualToZero(uint _id) {
        require(_id != 0);
        _;
    }

    /// @notice throw if the id is invalid
    /// @param _id the ID to validate
    modifier throwIfIsEmptyBytes32(bytes32 _id) {
        require(_id != "");
        _;
    }

        /// @dev check which prevents short address attack
    modifier payloadSizeIs(uint _size) {
        require(msg.data.length == _size + 4 /* function selector */);
        _;
    }
}
