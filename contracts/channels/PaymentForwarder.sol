pragma solidity ^0.4.17;

import "./authority/Roles.sol";

interface PaymentForwarderEmitterI {
    function emitLogPaymentForwarded(address from, address destination, uint256 amount) public;
}


contract PaymentForwarder {
    PaymentForwarderEmitterI public factory;
    address public destination;

    function PaymentForwarder(address destination_) public {
        destination = destination_;
        factory = PaymentForwarderEmitterI(msg.sender);
    }

    function () payable public {
        destination.transfer(msg.value);
        factory.emitLogPaymentForwarded(msg.sender, address(this), msg.value);
    }
}


contract ForwarderFactoryEvents {
    event LogForwarderCreated(address forwarder);
    event LogPaymentForwarded(address from, address destination, uint256 amount);
}


contract ForwarderFactory is ForwarderFactoryEvents, PaymentForwarderEmitterI, SecuredWithRoles {
    mapping(address => bool) forwarders;

    function ForwarderFactory(address rolesContract) public SecuredWithRoles("ForwarderFactory", rolesContract) {
        // nothing to do, just calling super
    }

    function createForwarder(address destination) public roleOrOwner("admin") {
        PaymentForwarder forwarder = new PaymentForwarder(destination);
        forwarders[forwarder] = true;
        LogForwarderCreated(address(forwarder));
    }

    function emitLogPaymentForwarded(address from, address destination, uint256 amount) public {
        require(forwarders[msg.sender]);
        LogPaymentForwarded(from, destination, amount);
    }
}
