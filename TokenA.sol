// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title TokenA - Test Token for SimpleSwap
 * @notice ERC20 token implementation for testing purposes
 * @dev Basic ERC20 token with mint and burn capabilities for educational use
 * @author Student Implementation for University Exam
 */
contract TokenA {
    
    /// @notice Token name
    string public constant name = "TokenA";
    
    /// @notice Token symbol  
    string public constant symbol = "TKA";
    
    /// @notice Token decimals
    uint8 public constant decimals = 18;
    
    /// @notice Total token supply
    uint256 public totalSupply;
    
    /// @notice Token balances mapping
    mapping(address => uint256) public balanceOf;
    
    /// @notice Token allowances mapping
    mapping(address => mapping(address => uint256)) public allowance;
    
    /// @notice Contract owner
    address public owner;
    
    /// @notice Transfer event
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    /// @notice Approval event
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    /**
     * @notice Constructor - deploys TokenA with initial supply
     * @param _initialSupply Initial token supply to mint
     */
    constructor(uint256 _initialSupply) {
        owner = msg.sender;
        totalSupply = _initialSupply * 10**decimals;
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }
    
    /**
     * @notice Transfer tokens to another address
     * @param _to Recipient address
     * @param _value Amount to transfer
     * @return success True if transfer succeeded
     */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        require(_to != address(0), "Invalid recipient");
        
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
    /**
     * @notice Approve spender to use tokens
     * @param _spender Address to approve
     * @param _value Amount to approve
     * @return success True if approval succeeded
     */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    /**
     * @notice Transfer tokens from one address to another
     * @param _from Sender address
     * @param _to Recipient address
     * @param _value Amount to transfer
     * @return success True if transfer succeeded
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Insufficient allowance");
        require(_to != address(0), "Invalid recipient");
        
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        
        emit Transfer(_from, _to, _value);
        return true;
    }
    
    /**
     * @notice Mint new tokens (only owner)
     * @param _to Recipient address
     * @param _value Amount to mint
     */
    function mint(address _to, uint256 _value) public {
        require(msg.sender == owner, "Only owner can mint");
        require(_to != address(0), "Invalid recipient");
        
        totalSupply += _value;
        balanceOf[_to] += _value;
        
        emit Transfer(address(0), _to, _value);
    }
    
    /**
     * @notice Burn tokens from own balance
     * @param _value Amount to burn
     */
    function burn(uint256 _value) public {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        
        emit Transfer(msg.sender, address(0), _value);
    }
}
