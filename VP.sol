pragma solidity >=0.4.24;
library Address {

        /**
         * Returns whether the target address is a contract
         * @dev This function will return false if invoked during the constructor of a contract,
         * as the code is not actually created until after the constructor finishes.
         * @param account address of the account to check
         * @return whether the target address is a contract
         */
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // XXX Currently there is no better way to check if there is a contract in an address
        // than to check the size of the code at that address.
        // See https://ethereum.stackexchange.com/a/14016/36603
        // for more details about how this works.
        // TODO Check this again before the Serenity release, because all addresses will be
        // contracts then.
        // solium-disable-next-line security/no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
  
}

contract Register {
    
    using Address for *;
      bytes32 account=keccak256(abi.encodePacked(msg.sender));
    enum Type {
       User,
        Hospital
    }
    
    struct Details {
        string name;
        bytes32 password;
        bool registered;
        Type types;
        string pictureBase64;
        address useraddress;
    }
    struct VaccineDetails{
        string VaccineName;
        string manufactory;
        string MedicineType;
        string DateInProduced;
        string duration;
    }
    mapping (bytes32 => Details) private data;
    mapping (bytes32 => VaccineDetails) private VData;

    event Registered(
    address indexed userAdd,
    string userName,
    uint signupTime);
                     
    event Login(
    address indexed userAdd,
    string userName,
    uint indexed loginTime);   

    event modify(
        address indexed userAdd,
    string userName,
    uint indexed loginTime
    );   

     event LogPasswordRenew(
        uint indexed timestamp, 
         string userName, 
        address indexed owner
    ); 
     event LogPasswordTransfer(
        uint indexed timestamp, 
        string userName, 
        address indexed owner
    );
                        
    modifier isHuman() {
        require(!msg.sender.isContract(),"only humans can register");
        _;
    }                    
    modifier alreadyRegistered() {
        require(!data[account].registered,"already registered");
        _;
    }
    function register(string memory _name,uint _type,string memory _password,string memory _pictureBase64 ) public isHuman alreadyRegistered returns(bytes32){
        require(_type == 1 || _type == 2,"please select a type 1.User 2. Hospital");
        bytes32 password = keccak256(abi.encodePacked(_password));
        if(_type == 1) {  
            if(bytes(_pictureBase64).length==0) {revert("please send a picture");}
            else
        data[account] = Details(_name,password,true,Type.User, _pictureBase64,msg.sender);}
        else if(_type == 2) {data[account] = Details(_name,password,true,Type.Hospital,_pictureBase64,msg.sender);}
        else revert("please choose a type");
        emit Registered(msg.sender,_name,block.timestamp);
        return data[account].password;}

 //   function login(bytes32 _password) public returns (address,uint){
  //      require(data[msg.sender].registered,"your address is not registered");
   //     require(_password == data[msg.sender].password,"Incorrect password");
   //     emit Login(msg.sender,data[msg.sender].name,block.timestamp);
   //     return (msg.sender,block.timestamp);
  //  }
    
    function loginOnChain(bytes32 _password) public returns (address,uint){
        require(data[account].registered,"your address is not registered");
        require(_password == data[account].password,"Incorrect password");
        emit Login(msg.sender,data[account].name,block.timestamp);
        return (msg.sender,block.timestamp);
    }
    
    function getUserDetails() public view returns(string memory name, bytes32 _account,string memory pictureBase64,
    string memory VaccineName,string memory manufactory,string memory MedicineType,string memory DateInProduced,string memory duration
     ){
        require(data[account].registered,"not registered");
        require (data[account].types == Type.User);
        return (
        data[account].name,
        keccak256(abi.encodePacked(msg.sender)),
        data[account].pictureBase64,
        VData[account].VaccineName,
        VData[account].manufactory,
        VData[account].MedicineType,
        VData[account].DateInProduced,
        VData[account].duration
        );
        }
        
    function HospitalChangeData(bytes32 _UserAccount, string memory _VaccineName, string memory _Manufactory, 
    string memory _MedicineType, string memory _DateInProduced, string memory _duration) public returns(bool){
    require(data[account].registered,"not registered");
      require (data[account].types == Type.Hospital);
    VData[_UserAccount] = VaccineDetails(_VaccineName,_Manufactory,_MedicineType,_DateInProduced, _duration);
    emit modify(msg.sender,data[account].name,block.timestamp);
    return true;
    }


      function renewpassword(bytes32 _password) public {
       require(data[account].registered,"not registered");
        require(_password == data[account].password,"Incorrect password");
        // LogNameRenew event
        emit LogPasswordRenew(
            block.timestamp,
         data[account].name,
            msg.sender
        );
    }

function transferPassword(string memory _passport) public returns (bytes32){
        require(msg.sender== data[account].useraddress,"you do not have the right to change the password");   
        bytes32 password = keccak256(abi.encodePacked(_passport));
        data[account].password = password;
        emit LogPasswordTransfer(
            block.timestamp,
         data[account].name,
            msg.sender
        );
        return data[account].password;
    }



}