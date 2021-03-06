/**           |
*           \ | /
*         -=- 0 -=-    ryanhendricks@gmail.com
*           / | \                          _\/_
*             |                            //☯\  _\/_
*   _  ___ ___  _ __ __ _  _ _  _ _ __  __ _ | __/☯\\ _
* .-"-._.-"-._.-.-"-._.-"-._.-.-"-._.-"-._,-'|"'""-|-,_
* -"-._.-"-._.-"-._.-.-"-._.-"-._.-.-"-~/          |
* _.-"-._.-"-._.-"-._.-.-"-._.-"-._.-""/           jgs */
pragma solidity ^0.4.15;


contract ERC20Token {
    /* This is a slight change to the ERC20 base standard.
     * function totalSupply() constant returns (uint256 supply);
     * is replaced with: uint256 public totalSupply;
     * This automatically creates a getter function for the totalSupply.
     * This is moved to the base contract since public getter functions are not
     * currently recognised as an implementation of the matching abstract
     * function by the compiler.
     */

    /// total amount of tokens
    uint256 public totalSupply;
    /// replaces: function totalSupply() constant returns (uint256 balance);

    /**
    * @dev Get number of tokens currently belonging to given owner.
    * @param _owner address that will be queried for balance
    * @return number of tokens currently belonging a given address of owner
    */
    function balanceOf (address _owner) public constant returns (uint256 balance);

    /**
    * @dev Transfer given number of tokens from message sender to given recipient.
    * @param _to address to transfer tokens to the owner of
    * @param _value number of tokens to transfer to the owner of given address
    * @return true if tokens were transferred successfully, false otherwise
    */
    function transfer (address _to, uint256 _value) public returns (bool success);

    /**
    * @dev Transfer given number of tokens from given owner to given recipient.
    * @param _from address to transfer tokens from the owner of
    * @param _to address to transfer tokens to the owner of
    * @param _value number of tokens to transfer from given owner to given recipient
    * @return true if tokens were transferred successfully, false otherwise
    */
    function transferFrom (address _from, address _to, uint256 _value) public returns (bool success);

    /**
    * @dev Allow given spender to transfer given number of tokens from message sender.
    * @param _spender address to allow the owner of to transfer tokens from message sender
    * @param _value number of tokens to allow to transfer
    * @return true if token transfer was successfully approved, false otherwise
    */
    function approve (address _spender, uint256 _value) public returns (bool success);

    /**
    * @dev Tell how many tokens given spender is currently allowed to transfer from given owner.
    * @param _owner address to get number of tokens allowed to be transferred from the owner of
    * @param _spender address to get number of tokens allowed to be transferred by the owner of
    * @return number of tokens given spender is currently allowed to transfer from given owner
    */
    function allowance (address _owner, address _spender) public constant returns (uint256 remaining);

    /**
    * @dev Logged when tokens were transferred from one owner to another.
    * @param _from address of the owner, tokens were transferred from
    * @param _to address of the owner, tokens were transferred to
    * @param _value number of tokens transferred
    */
    event Transfer (address indexed _from, address indexed _to, uint256 _value);

    /**
    * @dev Logged when owner approved his tokens to be transferred by some spender.
    * @param _owner owner who approved his tokens to be transferred
    * @param _spender spender who were allowed to transfer the tokens belonging to the owner
    * @param _value number of tokens belonging to the owner, approved to be transferred by the spender
    */
    event Approval (address indexed _owner, address indexed _spender, uint256 _value);
}