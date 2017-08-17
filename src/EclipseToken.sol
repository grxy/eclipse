pragma solidity ^0.4.15;

contract Token {
    uint256 public totalSupply;
    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract StandardToken is Token {
    function transfer(address _to, uint256 _value) returns (bool success) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;

    mapping (address => mapping (address => uint256)) allowed;
}

contract Eclipse is StandardToken {
    uint8 public decimals = 18;
    string public name = 'Eclipse';
    address owner;
    string public symbol = 'ECL';
    uint256 public totalContribution = 0;

    uint startTime = 1503330410; // Aug 21, 2017 at 15:46:50 UTC
    uint endTime = 1503349461; // Aug 21, 2017 at 21:04:21 UTC

    uint METERS_IN_ASTRONOMICAL_UNIT = 149597870700;
    uint MILES_IN_ASTRONOMICAL_UNIT = 92955807;

    uint TOTAL_SUPPLY_CAP = METERS_IN_ASTRONOMICAL_UNIT;
    uint TOKENS_PER_ETH = MILES_IN_ASTRONOMICAL_UNIT;

    function () payable {
        // revert if solar eclipse has not started
        if (now < startTime) revert();

        // revert if TOTAL_SUPPLY_CAP has been exhausted
        if (totalSupply >= TOTAL_SUPPLY_CAP) revert();

        uint tokensIssued;

        if (now > endTime) {
            // transfer remaining supply to owner
            tokensIssued = TOTAL_SUPPLY_CAP - totalSupply;
            balances[owner] += tokensIssued;
            totalSupply = TOTAL_SUPPLY_CAP;
        } else {
            // Send ETH to owner
            owner.transfer(msg.value);

            // Send tokens to contributor
            tokensIssued = msg.value * TOKENS_PER_ETH;

            if (totalSupply + tokensIssued > TOTAL_SUPPLY_CAP) {
                tokensIssued = TOTAL_SUPPLY_CAP - totalSupply;
            }

            totalSupply += tokensIssued;
            balances[msg.sender] += tokensIssued;
            Transfer(address(this), msg.sender, tokensIssued);
        }
    }

    function Eclipse() {
        owner = msg.sender;
        totalSupply = 0;
    }
}
