// SPDX-License-Identifier: MIT

pragma solidity ^0.5.0;

/**
 * Dividends Distribution Smart Contract
 * This contracts allows to make a distribution of dividends to the holders of your ERC-20 tokens
 * Dividends are not distributed automatically to token holders. Once the total dividend per token is known, 
 * then, it is the holder who has to call a function to be able to claim their dividends
 */
contract DividendsDistribution {
    string public name;
    string public symbol;
    uint256 public decimals;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // This variable represents the dividend (amount of funds) that belongs to a token
    uint256 dividendPerToken;
    // This is the historical dividend per token (all the dividends that have been generated)
    mapping(address => uint256) dividendBalanceOf;
    // This is the cumulative historical dividend (all the dividends that had been paid) prior to the current one
    // This is used to calculate @dividenBalanceOf
    mapping(address => uint256) dividendCreditedTo;

    function update(address _address) internal {
        uint256 debit = dividendPerToken - dividendCreditedTo[_address];
        dividendBalanceOf[_address] += balanceOf[_address] * debit;
        dividendCreditedTo[_address] = dividendPerToken;
    }

    function withdraw() public {
        update(msg.sender);
        uint256 amount = dividendBalanceOf[msg.sender];
        dividendBalanceOf[msg.sender] = 0;
        msg.sender.transfer(amount);
    }

    function deposit() public payable {
        dividendPerToken += msg.value / totalSupply;
    }

    constructor() public {
        name = "My Token";
        symbol = "MT";
        decimals = 18;
        totalSupply = 100000000 * (uint256(10) ** decimals);
        balanceOf[msg.sender] = totalSupply;
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function transfer(address _to, uint256 _value) public returns(bool success) {
        require(balanceOf[msg.sender] >= _value);
        update(msg.sender);
        update(_to);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns(bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns(bool success) {
        require(balanceOf[_from] >= _value);
        require(allowance[_from][msg.sender] >= _value);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

}
