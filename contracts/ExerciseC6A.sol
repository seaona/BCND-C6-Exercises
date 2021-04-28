pragma solidity 0.8.4;

contract ExerciseC6A {

    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/
    struct UserProfile {
        bool isRegistered;
        bool isAdmin;
    }

    address private contractOwner;                  // Account used to deploy contract
    mapping(address => UserProfile) userProfiles;   // Mapping for storing user profiles

    // STOP LOSS
    bool private operational = true;

    // MULTI PARTY CONSENSUS
    uint constant M = 2;
    address[] multiCalls = new address[](0);
    /********************************************************************************************/
    /*                                       EVENT DEFINITIONS                                  */
    /********************************************************************************************/

    // No events

    /**
    * @dev Constructor
    *      The deploying account becomes contractOwner
    */
    constructor(){
        contractOwner = msg.sender;
    }

    /********************************************************************************************/
    /*                                       FUNCTION MODIFIERS                                 */
    /********************************************************************************************/

    // Modifiers help avoid duplication of code. They are typically used to validate something
    // before a function is allowed to be executed.

    /**
    * @dev Modifier that requires the "ContractOwner" account to be the function caller
    */
    modifier requireContractOwner() {
        require(msg.sender == contractOwner, "Caller is not contract owner");
        _;
    }

    modifier requireIsOperational() {
        require(operational == true, "Contract is not operational");
        _;
    }
    /********************************************************************************************/
    /*                                       UTILITY FUNCTIONS                                  */
    /********************************************************************************************/

   /**
    * @dev Check if a user is registered
    *
    * @return A bool that indicates if the user is registered
    */   
    function isUserRegistered (address account) external view returns(bool) {
        require(account != address(0), "'account' must be a valid address.");
        return userProfiles[account].isRegistered;
    }

    function isOperational () public view returns(bool) {
        return operational;
    }

    function setOperatingStatus (bool status) external {
        require(status != operational, "New mode must be different from existing mode");
        require(userProfiles[msg.sender].isAdmin, "Caller is not an admin");

        bool isDuplicate = false;
        // avoid loop with mapping or looping on client side
        for(uint c=0; c<multiCalls.length; c++) {
            if (multiCalls[c] == msg.sender) {
                isDuplicate = true;
                break;
            }
        }
        require(!isDuplicate, "Caller has already called this function.");

        multiCalls.push(msg.sender);
        if (multiCalls.length >= M) {
            operational = status;      
            multiCalls = new address[](0);      
        }
    }

    /********************************************************************************************/
    /*                                     SMART CONTRACT FUNCTIONS                             */
    /********************************************************************************************/

    function registerUser (address account, bool isAdmin) external requireContractOwner requireIsOperational{
        require(!userProfiles[account].isRegistered, "User is already registered.");
        userProfiles[account] = UserProfile({isRegistered: true, isAdmin: isAdmin});
    }
}

