pragma solidity ^0.4.16;


contract Users {

    /// @dev This will create an array of structures each containing info for a user
    User[] public Users;

    /* Different mapping definitions */
    mapping(bytes32=>address) public emailsWithUserAddresses;       //Map user wallet addresses with registered email number 
    mapping(address=>bytes32) public PasswordsWithAddress;          //Map user account password with associated wallet address
    mapping(address=>bytes32) public UserIDsWithAddress;            //Map user unique ID with associated wallet address
    mapping(address=>User) public userDetails;                      //Map user details with associated wallet address
    mapping(bytes32=>address) public userlogin;                     //Map user associated wallet address with unique ID 
    mapping(bytes32=>bool) public adminLogin;


    /// Structure to hold details for each user
    struct User {
        bytes32 firstName;
        bytes32 lastName;
        bytes32 userID;
        bytes32 email;
        uint bnkAccountNo;
    }

    /**
     * @dev Add a new user
     * @param firstName of the user
     * @param lastName of the user
     * @param walletAddr of the user
     * @param userID of the user
     */
    function addNewUser(
        bytes32 _firstName,
        bytes32 _lastName,
        address _walletAddr,
        bytes32 _userID,
        uint _bnkAccountNo,
        bytes32 _userPwd,
        bytes32 _email
        ) public returns (bool addUser_status)
        {
        User memory newRegdUser;
    
        newRegdUser.firstName = _firstName;
        newRegdUser.lastName = _lastName;
        newRegdUser.userID = _userID;
        newRegdUser.email = _email; 
        newRegdUser.bnkAccountNo = _bnkAccountNo;
        
        Users.push(newRegdUser);

        emailsWithUserAddresses[_email] = _walletAddr;
        UserIDsWithAddress[_walletAddr] = _userID;
        PasswordsWithAddress[_walletAddr] = _userPwd;
        userDetails[_walletAddr] = newRegdUser; 
        userlogin[_userID] = _walletAddr;
        adminLogin[_userID] = false;

        return true; 
    }

    function setAdmin(bytes32 _adminID,address _walletAddress,bytes32 _password) returns (bool _success){
        UserIDsWithAddress[_walletAddress] = _adminID;
        PasswordsWithAddress[_walletAddress] = _password;
        userlogin[_adminID] = _walletAddress;
        adminLogin[_adminID] = true;
        return true;
    }

    function getAdminLogin(bytes32 _userID,bytes32 _userPwd) constant returns (bool _status){
        if (adminLogin[_userID]) {
            return true;
        } else {
            return false;
        }
    }

    /* Function to query user details with associated wallet address*/
    function getUserDetailsByWallet(address _walletAddr) constant returns (bytes32, bytes32, bytes32, uint, bytes32) {
        bytes32 _firstName = userDetails[_walletAddr].firstName;
        bytes32 _lastName = userDetails[_walletAddr].lastName;
        uint _bnkAccountNo = userDetails[_walletAddr].bnkAccountNo;
        bytes32 _userID = userDetails[_walletAddr].userID;
        bytes32 _email = userDetails[_walletAddr].email;
        return (_firstName, _lastName, _userID, _bnkAccountNo, _email);
    }

    /* Function to get all user IDs */
    function getUserIDs() constant returns ( bytes32[] ) {
        uint length = Users.length;
        bytes32[] memory userIDs = new bytes32[](length);
    
        for (var i = 0; i < length; i++) {
            User memory currentUser;
            currentUser = Users[i];
            userIDs[i] = currentUser.userID;
        }
        return userIDs;
    }

     /* Function to get details of all users */
    function getUsersDetails() constant returns (bytes32[], bytes32[], bytes32[], uint[], byte32[]) {
        uint length = Users.length;
        bytes32[] memory firstNames = new bytes32[](length);
        bytes32[] memory lastNames = new bytes32[](length);
        uint[] memory bnkAccountNos = new uint[](length);
        bytes32[] memory userIDs = new bytes32[](length);
        uint[] memory emails = new uint[](length);    
        for (var i = 0; i < length; i++) {
            User memory currentUser;
            currentUser = Users[i];
            firstNames[i] = currentUser.firstName;
            lastNames[i] = currentUser.lastName;
            bnkAccountNos[i] = currentUser.bnkAccountNo;
            userIDs[i] = currentUser.userID;
            emails[i] = currentUser.email;
        }
        return(firstNames, lastNames, userIDs, bnkAccountNos, emails);
    }

    /* Function to query UserID by registered email number */                                                                                                                                                        
    function getUserIDbyEmail(bytes32 _email) constant returns (bytes32 ) {
        address _owner = emailsWithUserAddresses[_email];
        return UserIDsWithAddress[_owner];
    }

    /* Function to query User Passwords by associated wallet address */                                                                                                                                                                                                                                    function getPasswordbyMobNumber(bytes32 _email) constant returns (bytes32 ){
        address _owner = emailsWithUserAddresses[_email];        
        return PasswordsWithAddress[_owner];      
    }

    /* Function to query UserID by associated wallet address */                                                                                                                                                                                                                                    
    function getUsernameByAddress(address _addr) constant returns (bytes32,bytes32) {
        return (userDetails[_addr].firstName,userDetails[_addr].lastName);
    }

    /* Function to query associated wallet address by UserID  */
    function getWalletByUserID(bytes32 _userid) constant returns(address) {
        return userlogin[_userid];
    }

    /* Function to chack user's login credentials */
    function getLogin(bytes32 _userid, bytes32 _pwd) constant returns(bool) {
        address addr = userlogin[_userid];
        bytes32 pwd = PasswordsWithAddress[addr];
        if(pwd == _pwd){return true;} else {return false;}
    }                                                                                                                                                                                                                                                                                                     

     /* Function to query UserID and account password by registered email number */                                                                                                                                   
    function getUserIDandPasswordbyMobNumber(bytes32 _email) constant returns (bytes32, bytes32) {
        address _owner = emailsWithUserAddresses[_email];
        return ( UserIDsWithAddress[_owner], PasswordsWithAddress[_owner] );
    }
  }