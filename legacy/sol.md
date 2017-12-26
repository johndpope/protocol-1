* [ERC20](#erc20)
  * [approve](#function-approve)
  * [totalSupply](#function-totalsupply)
  * [transferFrom](#function-transferfrom)
  * [balanceOf](#function-balanceof)
  * [transfer](#function-transfer)
  * [allowance](#function-allowance)
  * [Transfer](#event-transfer)
  * [Approval](#event-approval)
* [Escapable](#escapable)
  * [escapeHatchCaller](#function-escapehatchcaller)
  * [changeOwnership](#function-changeownership)
  * [removeOwnership](#function-removeownership)
  * [proposeOwnership](#function-proposeownership)
  * [acceptOwnership](#function-acceptownership)
  * [isTokenEscapable](#function-istokenescapable)
  * [owner](#function-owner)
  * [escapeHatch](#function-escapehatch)
  * [newOwnerCandidate](#function-newownercandidate)
  * [changeHatchEscapeCaller](#function-changehatchescapecaller)
  * [escapeHatchDestination](#function-escapehatchdestination)
  * [EscapeHatchBlackistedToken](#event-escapehatchblackistedtoken)
  * [EscapeHatchCalled](#event-escapehatchcalled)
  * [OwnershipRequested](#event-ownershiprequested)
  * [OwnershipTransferred](#event-ownershiptransferred)
  * [OwnershipRemoved](#event-ownershipremoved)
* [Owned](#owned)
  * [changeOwnership](#function-changeownership)
  * [removeOwnership](#function-removeownership)
  * [proposeOwnership](#function-proposeownership)
  * [acceptOwnership](#function-acceptownership)
  * [owner](#function-owner)
  * [newOwnerCandidate](#function-newownercandidate)
  * [OwnershipRequested](#event-ownershiprequested)
  * [OwnershipTransferred](#event-ownershiptransferred)
  * [OwnershipRemoved](#event-ownershipremoved)

# ERC20


## *function* approve

ERC20.approve(_spender, _value) `nonpayable` `095ea7b3`

> Allows _spender to withdraw from the msg.sender's account up to the _value amount

Inputs

| | | |
|-|-|-|
| *address* | _spender | undefined |
| *uint256* | _value | undefined |


## *function* totalSupply

ERC20.totalSupply() `view` `18160ddd`

> Returns the total token supply




## *function* transferFrom

ERC20.transferFrom(_from, _to, _value) `nonpayable` `23b872dd`

> Transfers _value number of tokens from address _from to address _to

Inputs

| | | |
|-|-|-|
| *address* | _from | undefined |
| *address* | _to | undefined |
| *uint256* | _value | undefined |


## *function* balanceOf

ERC20.balanceOf(_owner) `view` `70a08231`

> Returns the account balance of the account with address _owner

Inputs

| | | |
|-|-|-|
| *address* | _owner | undefined |


## *function* transfer

ERC20.transfer(_to, _value) `nonpayable` `a9059cbb`

> Transfers _value number of tokens to address _to

Inputs

| | | |
|-|-|-|
| *address* | _to | undefined |
| *uint256* | _value | undefined |


## *function* allowance

ERC20.allowance(_owner, _spender) `view` `dd62ed3e`

> Returns the amount which _spender is still allowed to withdraw from _owner

Inputs

| | | |
|-|-|-|
| *address* | _owner | undefined |
| *address* | _spender | undefined |

## *event* Transfer

ERC20.Transfer(_from, _to, _value) `ddf252ad`

Arguments

| | | |
|-|-|-|
| *address* | _from | indexed |
| *address* | _to | indexed |
| *uint256* | _value | not indexed |

## *event* Approval

ERC20.Approval(_owner, _spender, _value) `8c5be1e5`

Arguments

| | | |
|-|-|-|
| *address* | _owner | indexed |
| *address* | _spender | indexed |
| *uint256* | _value | not indexed |


---
# Escapable


## *function* escapeHatchCaller

Escapable.escapeHatchCaller() `view` `1f6eb6e7`





## *function* changeOwnership

Escapable.changeOwnership(_newOwner) `nonpayable` `2af4c31e`

**`owner` can step down and assign some other address to this role**

> In this 2nd option for ownership transfer `changeOwnership()` can  be called and it will immediately assign ownership to the `newOwner`

Inputs

| | | |
|-|-|-|
| *address* | _newOwner | The address of the new owner |


## *function* removeOwnership

Escapable.removeOwnership(_dac) `nonpayable` `666a3427`

**Decentralizes the contract, this operation cannot be undone **

> In this 3rd option for ownership transfer `removeOwnership()` can  be called and it will immediately assign ownership to the 0x0 address;  it requires a 0xdece be input as a parameter to prevent accidental use

Inputs

| | | |
|-|-|-|
| *address* | _dac | `0xdac` has to be entered for this function to work |


## *function* proposeOwnership

Escapable.proposeOwnership(_newOwnerCandidate) `nonpayable` `710bf322`

**`onlyOwner` Proposes to transfer control of the contract to a  new owner**

> In this 1st option for ownership transfer `proposeOwnership()` must  be called first by the current `owner` then `acceptOwnership()` must be  called by the `newOwnerCandidate`

Inputs

| | | |
|-|-|-|
| *address* | _newOwnerCandidate | The address being proposed as the new owner |


## *function* acceptOwnership

Escapable.acceptOwnership() `nonpayable` `79ba5097`

**Can only be called by the `newOwnerCandidate`, accepts the  transfer of ownership**





## *function* isTokenEscapable

Escapable.isTokenEscapable(_token) `view` `892db057`

**Checks to see if `_token` is in the blacklist of tokens**


Inputs

| | | |
|-|-|-|
| *address* | _token | the token address being queried |

Outputs

| | | |
|-|-|-|
| *bool* |  | undefined |

## *function* owner

Escapable.owner() `view` `8da5cb5b`





## *function* escapeHatch

Escapable.escapeHatch(_token) `nonpayable` `a142d608`

**The `escapeHatch()` should only be called as a last resort if a security issue is uncovered or something unexpected happened**


Inputs

| | | |
|-|-|-|
| *address* | _token | to transfer, use 0x0 for ether |


## *function* newOwnerCandidate

Escapable.newOwnerCandidate() `view` `d091b550`





## *function* changeHatchEscapeCaller

Escapable.changeHatchEscapeCaller(_newEscapeHatchCaller) `nonpayable` `d836fbe8`

**Changes the address assigned to call `escapeHatch()`**


Inputs

| | | |
|-|-|-|
| *address* | _newEscapeHatchCaller | The address of a trusted account or  contract to call `escapeHatch()` to send the value in this contract to  the `escapeHatchDestination`; it would be ideal that `escapeHatchCaller`  cannot move funds out of `escapeHatchDestination` |


## *function* escapeHatchDestination

Escapable.escapeHatchDestination() `view` `f5b61230`





## *event* EscapeHatchBlackistedToken

Escapable.EscapeHatchBlackistedToken(token) `6b44fa01`

Arguments

| | | |
|-|-|-|
| *address* | token | not indexed |

## *event* EscapeHatchCalled

Escapable.EscapeHatchCalled(token, amount) `a50dde91`

Arguments

| | | |
|-|-|-|
| *address* | token | not indexed |
| *uint256* | amount | not indexed |

## *event* OwnershipRequested

Escapable.OwnershipRequested(by, to) `13a4b3bc`

Arguments

| | | |
|-|-|-|
| *address* | by | indexed |
| *address* | to | indexed |

## *event* OwnershipTransferred

Escapable.OwnershipTransferred(from, to) `8be0079c`

Arguments

| | | |
|-|-|-|
| *address* | from | indexed |
| *address* | to | indexed |

## *event* OwnershipRemoved

Escapable.OwnershipRemoved() `94e8b32e`




---
# Owned

Adrià Massanet <adria@codecontext.io>

## *function* changeOwnership

Owned.changeOwnership(_newOwner) `nonpayable` `2af4c31e`

**`owner` can step down and assign some other address to this role**

> In this 2nd option for ownership transfer `changeOwnership()` can  be called and it will immediately assign ownership to the `newOwner`

Inputs

| | | |
|-|-|-|
| *address* | _newOwner | The address of the new owner |


## *function* removeOwnership

Owned.removeOwnership(_dac) `nonpayable` `666a3427`

**Decentralizes the contract, this operation cannot be undone **

> In this 3rd option for ownership transfer `removeOwnership()` can  be called and it will immediately assign ownership to the 0x0 address;  it requires a 0xdece be input as a parameter to prevent accidental use

Inputs

| | | |
|-|-|-|
| *address* | _dac | `0xdac` has to be entered for this function to work |


## *function* proposeOwnership

Owned.proposeOwnership(_newOwnerCandidate) `nonpayable` `710bf322`

**`onlyOwner` Proposes to transfer control of the contract to a  new owner**

> In this 1st option for ownership transfer `proposeOwnership()` must  be called first by the current `owner` then `acceptOwnership()` must be  called by the `newOwnerCandidate`

Inputs

| | | |
|-|-|-|
| *address* | _newOwnerCandidate | The address being proposed as the new owner |


## *function* acceptOwnership

Owned.acceptOwnership() `nonpayable` `79ba5097`

**Can only be called by the `newOwnerCandidate`, accepts the  transfer of ownership**





## *function* owner

Owned.owner() `view` `8da5cb5b`





## *function* newOwnerCandidate

Owned.newOwnerCandidate() `view` `d091b550`





## *event* OwnershipRequested

Owned.OwnershipRequested(by, to) `13a4b3bc`

Arguments

| | | |
|-|-|-|
| *address* | by | indexed |
| *address* | to | indexed |

## *event* OwnershipTransferred

Owned.OwnershipTransferred(from, to) `8be0079c`

Arguments

| | | |
|-|-|-|
| *address* | from | indexed |
| *address* | to | indexed |

## *event* OwnershipRemoved

Owned.OwnershipRemoved() `94e8b32e`




---