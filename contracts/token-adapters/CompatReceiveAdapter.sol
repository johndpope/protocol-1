pragma solidity ^0.4.11;

import './ERC20ReceiveAdapter.sol';
import './ERC667ReceiveAdapter.sol';
import './ReceiveApprovalAdapter.sol';
import './EtherReceiveAdapter.sol';

/**
 * @dev This ReceiveAdapter supports all possible tokens
 */
contract CompatReceiveAdapter is ERC20ReceiveAdapter, ERC667ReceiveAdapter, ReceiveApprovalAdapter, EtherReceiveAdapter {

}