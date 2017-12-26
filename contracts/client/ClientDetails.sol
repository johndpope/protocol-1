pragma solidity ^0.4.16;


contract Clients {

    /// @dev This will create an array of structures each containing info for a client
    Client[] public Clients;

    /* Different mapping definitions */
    mapping(bytes32=>address) public emailsWithClientAddresses;       //Map client wallet addresses with registered email number 
    mapping(address=>bytes32) public PasswordsWithAddress;          //Map client account password with associated wallet address
    mapping(address=>bytes32) public ClientIDsWithAddress;            //Map client unique ID with associated wallet address
    mapping(address=>Client) public clientDetails;                      //Map client details with associated wallet address
    mapping(bytes32=>address) public clientlogin;                     //Map client associated wallet address with unique ID 
    mapping(bytes32=>bool) public adminLogin;


    /// Structure to hold details for each client
    struct Client {
        bytes32 firstName;
        bytes32 lastName;
        bytes32 clientID;
        bytes32 email;
        uint bnkAccountNo;
    }

    /**
     * @dev Add a new client
     * @param firstName of the client
     * @param lastName of the client
     * @param walletAddr of the client
     * @param clientID of the client
     */
    function addNewClient(
        bytes32 _firstName,
        bytes32 _lastName,
        address _walletAddr,
        bytes32 _clientID,
        uint _bnkAccountNo,
        bytes32 _clientPwd,
        bytes32 _email
        ) public returns (bool addClient_status)
        {
        Client memory newRegdClient;
    
        newRegdClient.firstName = _firstName;
        newRegdClient.lastName = _lastName;
        newRegdClient.clientID = _clientID;
        newRegdClient.email = _email; 
        newRegdClient.bnkAccountNo = _bnkAccountNo;
        
        Clients.push(newRegdClient);

        emailsWithClientAddresses[_email] = _walletAddr;
        ClientIDsWithAddress[_walletAddr] = _clientID;
        PasswordsWithAddress[_walletAddr] = _clientPwd;
        clientDetails[_walletAddr] = newRegdClient; 
        clientlogin[_clientID] = _walletAddr;
        adminLogin[_clientID] = false;

        return true; 
    }

    function setAdmin(bytes32 _adminID,address _walletAddress,bytes32 _password) returns (bool _success){
        ClientIDsWithAddress[_walletAddress] = _adminID;
        PasswordsWithAddress[_walletAddress] = _password;
        clientlogin[_adminID] = _walletAddress;
        adminLogin[_adminID] = true;
        return true;
    }

    function getAdminLogin(bytes32 _clientID,bytes32 _clientPwd) constant returns (bool _status){
        if (adminLogin[_clientID]) {
            return true;
        } else {
            return false;
        }
    }

    /* Function to query client details with associated wallet address*/
    function getClientDetailsByWallet(address _walletAddr) constant returns (bytes32, bytes32, bytes32, uint, bytes32) {
        bytes32 _firstName = clientDetails[_walletAddr].firstName;
        bytes32 _lastName = clientDetails[_walletAddr].lastName;
        uint _bnkAccountNo = clientDetails[_walletAddr].bnkAccountNo;
        bytes32 _clientID = clientDetails[_walletAddr].clientID;
        bytes32 _email = clientDetails[_walletAddr].email;
        return (_firstName, _lastName, _clientID, _bnkAccountNo, _email);
    }

    /* Function to get all client IDs */
    function getClientIDs() constant returns ( bytes32[] ) {
        uint length = Clients.length;
        bytes32[] memory clientIDs = new bytes32[](length);
    
        for (var i = 0; i < length; i++) {
            Client memory currentClient;
            currentClient = Clients[i];
            clientIDs[i] = currentClient.clientID;
        }
        return clientIDs;
    }

     /* Function to get details of all clients */
    function getClientsDetails() constant returns (bytes32[], bytes32[], bytes32[], uint[], byte32[]) {
        uint length = Clients.length;
        bytes32[] memory firstNames = new bytes32[](length);
        bytes32[] memory lastNames = new bytes32[](length);
        uint[] memory bnkAccountNos = new uint[](length);
        bytes32[] memory clientIDs = new bytes32[](length);
        uint[] memory emails = new uint[](length);    
        for (var i = 0; i < length; i++) {
            Client memory currentClient;
            currentClient = Clients[i];
            firstNames[i] = currentClient.firstName;
            lastNames[i] = currentClient.lastName;
            bnkAccountNos[i] = currentClient.bnkAccountNo;
            clientIDs[i] = currentClient.clientID;
            emails[i] = currentClient.email;
        }
        return(firstNames, lastNames, clientIDs, bnkAccountNos, emails);
    }

    /* Function to query ClientID by registered email number */                                                                                                                                                        
    function getClientIDbyEmail(bytes32 _email) constant returns (bytes32 ) {
        address _owner = emailsWithClientAddresses[_email];
        return ClientIDsWithAddress[_owner];
    }

    /* Function to query Client Passwords by associated wallet address */                                                                                                                                                                                                                                    function getPasswordbyMobNumber(bytes32 _email) constant returns (bytes32 ){
        address _owner = emailsWithClientAddresses[_email];        
        return PasswordsWithAddress[_owner];      
    }

    /* Function to query ClientID by associated wallet address */                                                                                                                                                                                                                                    
    function getClientnameByAddress(address _addr) constant returns (bytes32,bytes32) {
        return (clientDetails[_addr].firstName,clientDetails[_addr].lastName);
    }

    /* Function to query associated wallet address by ClientID  */
    function getWalletByClientID(bytes32 _clientid) constant returns(address) {
        return clientlogin[_clientid];
    }

    /* Function to chack client's login credentials */
    function getLogin(bytes32 _clientid, bytes32 _pwd) constant returns(bool) {
        address addr = clientlogin[_clientid];
        bytes32 pwd = PasswordsWithAddress[addr];
        if(pwd == _pwd){return true;} else {return false;}
    }                                                                                                                                                                                                                                                                                                     

     /* Function to query ClientID and account password by registered email number */                                                                                                                                   
    function getClientIDandPasswordbyMobNumber(bytes32 _email) constant returns (bytes32, bytes32) {
        address _owner = emailsWithClientAddresses[_email];
        return ( ClientIDsWithAddress[_owner], PasswordsWithAddress[_owner] );
    }
  }