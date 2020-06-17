pragma solidity >0.4.25 <0.7.0;



contract ERC20 {
 
    address public owner;           //address of owner
    address public newOwner;        //address of new owner
    string public name;             //name of token
    string public symbol;           //symbol of token
    uint8 public decimals = 8;      //decimal of token
    uint256 totalFrozen;            //total frozen token
    uint256 public totalSupply;     //totalsupply

    mapping (address => uint256) public balanceOf;          //to check balance of an address
    
    mapping (address => mapping (address => uint256)) private allowance;     //mapping address to the other address
    
    mapping (address => uint256) private _balances;         
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    event OwnershipTransferred(address indexed _from, address indexed _to);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    event Burn(address indexed from, uint256 value);
    
    event Freeze(address indexed owner, uint256 tokens);
	
	event Unfreeze(address indexed owner, uint256 tokens);
	
    uint256 initialSupply = 1000000;      //1m Supply
    string tokenName = 'Test Token';        // token name
    string tokenSymbol = 'TST';             // token symbol
    
    
    constructor() public {
        owner = msg.sender;
        totalSupply = initialSupply * 10 ** uint256(decimals);  
        balanceOf[msg.sender] = totalSupply;                
        name = tokenName;                                   
        symbol = tokenSymbol;                               
    }
    
    
      modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }
  
    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
  }
  
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
  }


    function _transfer(address _from, address _to, uint _value) internal {
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }


    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   
        balanceOf[msg.sender] -= _value;            
        totalSupply -= _value;                      
        emit Burn(msg.sender, _value);
        return true;
    }

    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);                
        require(_value <= allowance[_from][msg.sender]);    
        balanceOf[_from] -= _value;                         
        allowance[_from][msg.sender] -= _value;             
        totalSupply -= _value;                             
        emit Burn(_from, _value);
        return true;
    }

    function freeze(uint256 _tokens) external {
		_freeze(_tokens);
	}

	function unfreeze(uint256 _tokens) external {
		_unfreeze(_tokens);
	}
	
	function bulkTransfer(address[]  _receivers, uint256[]  _amounts) external {
		require(_receivers.length == _amounts.length);
		for (uint256 i = 0; i < _receivers.length; i++) {
			_transfer(msg.sender, _receivers[i], _amounts[i]);
		}
	}
	
	
	function totalFrozenToken() public view returns (uint256) {
		return totalFrozen;
	}

	function _freeze(uint256 _amount) internal {
        require(balanceOf[msg.sender] >= _amount);
		totalFrozen += _amount;
		emit Freeze(msg.sender, _amount);
	}
	

	function _unfreeze(uint256 _amount) internal {
		totalFrozen -= _amount;
		emit Unfreeze(msg.sender, _amount);
	}

}