pragma solidity ^0.4.11;

import './SafeMath.sol';


contract Channels {
  address public owner;
  // deposits hold the total values used in payment channels
  uint256 public deposits;

  using SafeMath for uint256;

  struct PaymentChannel {
    address owner;
    address recipient;
    uint256 value;
    uint validUntil;
    bool valid;
  }


  // Channels uses asynchronous withdrawing for the recipients.
  struct PaymentWithdraw {
    address recipient;
    uint256 claimable;
  }

  mapping(bytes32 => PaymentChannel) public channels;
  mapping(bytes32 => PaymentWithdraw) public withdraws;
  uint id;

  event LogNewChannel(address indexed owner, address indexed recipient, bytes32 indexed channel, uint validUntil);
  event LogDeposit(address indexed owner, bytes32 indexed channel, uint value);
  event LogClaim(address indexed who, bytes32 indexed channel, uint value);
  event LogReclaim(bytes32 indexed channel);

  function Channels() public {
    owner = msg.sender;
    id = 0;
  }

  function transferOwnership(address _to) public {
    require(msg.sender == owner);
    require(_to != address(0));
    owner = _to;
  }

  // Channels can not receive Ether by transactions or send, but can get some by mining or selfdestruct. The owner can get it back.
  function withdrawExtra() public {
    require(msg.sender == owner);
    // owner can not get the deposits back
    require(this.balance > deposits);
    require(owner.send(this.balance - deposits));
  }
  // Only the sender can create a channel, by sending ether. Upon creation, the receiver is unknown
  function createChannel(uint duration, address recipient) public payable {
    require(recipient != address(0));
    bytes32 channel = keccak256(id++, owner, msg.sender, recipient);
    channels[channel] = PaymentChannel(msg.sender, recipient, msg.value, now + duration * 1 days, true);
    deposits += msg.value;
    LogNewChannel(msg.sender, recipient, channel, now + duration * 1 days);
    LogDeposit(msg.sender, channel, msg.value);
  }


  function getHash(bytes32 channel, address recipient, uint value) private pure returns(bytes32) {
    var h1 = keccak256('string Order', 'bytes32 Channel', 'address To', 'uint Amount');
    // var h1 = 0xe9485e119b2dbdba8b62c219b4428200dd31f04706a5d0b5a68f5acd772309e7
    var h2 = keccak256('Transfer amount', channel, recipient, value);
    return keccak256(h1, h2);
  }

  function verify(bytes32 channel, address recipient, uint value, uint8 v, bytes32 r, bytes32 s) constant public returns(bool) {
    require(recipient != address(0));
    PaymentChannel memory ch = channels[channel];
    return ch.valid && ch.validUntil >= now && ch.owner == ecrecover(getHash(channel, recipient, value), v, r, s);
  }

  function claim(bytes32 channel, uint value, uint8 v, bytes32 r, bytes32 s) public returns(bool) {
    address recipient = msg.sender;
    require(verify(channel, recipient, value, v, r, s));
    PaymentChannel memory ch = channels[channel];
    require(recipient == ch.recipient);

    uint256 claimable = 0;

    if (value > ch.value) {
      claimable = ch.value;
      } else {
        claimable = value;
      }
      ch.value -= claimable;
      ch.valid = false;

      withdraws[channel] = PaymentWithdraw(recipient, claimable);
      LogClaim(recipient, channel, value);
    }

    function deposit(bytes32 channel) public payable {
      require(isValidChannel(channel));
      PaymentChannel memory ch = channels[channel];
      require(ch.owner == msg.sender);
      ch.value += msg.value;
      deposits += msg.value;
      LogDeposit(msg.sender, channel, ch.value);
    }

    function recipientReclaim(bytes32 channel) public {
      PaymentWithdraw memory withdraw = withdraws[channel];
      require(msg.sender == withdraw.recipient);
      require(withdraw.claimable != 0);
      require(this.balance >= withdraw.claimable);
      deposits -= withdraw.claimable;
      require(withdraw.recipient.send(withdraw.claimable));
      delete withdraws[channel];
    }

    function channelOwnerReclaim(bytes32 channel) public {
      PaymentChannel memory ch = channels[channel];
      require(msg.sender == ch.owner);
      require(ch.value != 0);
      require(ch.validUntil < now);
      require(this.balance >= ch.value);
      deposits -= ch.value;
      require(ch.owner.send(ch.value));
      delete channels[channel];
    }

    function getChannelValue(bytes32 channel) constant public returns(uint256) {
      return channels[channel].value;
    }

    function getChannelOwner(bytes32 channel) constant public returns(address) {
      return channels[channel].owner;
    }

    function  getChannelValidUntil(bytes32 channel) constant public returns(uint) {
      return channels[channel].validUntil;
    }
    function isValidChannel(bytes32 channel) constant public returns(bool) {
      PaymentChannel memory ch = channels[channel];
      return ch.valid && ch.validUntil >= now;
    }
  }
