pragma solidity ^0.4.11;

contract EtherLock {  
    
    event log_string(string log); // Event
    event log_uint256(uint256);
    
    address owner;
    bool public released;
    uint timestamp_created;
   
    uint lock_days;
    
  
    mapping (address => bool)  releasers_map;
    address [] releasers;
    

    modifier ownerOnly{
        
        if (msg.sender != owner) revert();
        _;
    }
    
    modifier releaserOnly{
        
        if (!releasers_map[msg.sender]) revert();
        _;
    }

    
    function EtherLock (uint daysAfter, address[] rel) payable {
        
        if (daysAfter == 0 || rel.length == 0) {
            
            revert();
            
        }
        
        releasers = rel;
        for (uint i = 0; i < rel.length;i++ ) {
            
            releasers_map[rel[i]] = true;
            
            
            
        }     
       
        owner = msg.sender;
        released = false;
        lock_days = daysAfter;
       
        timestamp_created = now;
       
        
    }
    
    

    
    function release() 
    
        releaserOnly {
        if (!released) {
            
            released = true;
            
        }
        else {
            revert();
            
        }
        
    }
    
    function refund() ownerOnly 
       {
        if (released || (now > timestamp_created + lock_days * 1 days)) {
            
            suicide(owner);
           
        }
        else {
              revert();   
        }
        
        
    }
    
    function getBalance() public constant  returns  (uint bal) {
        
        bal = this.balance;
        return bal;
    }
    
    
    
     function getAllReleasers() ownerOnly constant returns(address[]) {
         
       
        return releasers;
    }
    
    
    function () payable { // fallback function
    
    
        
    }
    
}
