/*

    TODO LIST
    -Update contract
    -Track incoming REP by address
    -Distribute earnings
    -Add reporting capability
    -Add ability to retrieve earnings
    -Add enum results, maybe?
    -Users deposit REP
    -Admins withdraw REP
    -Admins withdraw rewards
    -Users withdraw rewards


    DONE
    -Users withdraw REP


    USE CASES
    -REP owner deposits REP
    -REP owner withdraws REP
    -REP owner withdraws owed tokens and ETH
    -Creator withdraws owed tokens and ETH
    -Creator approves address for reporting
    -Admin address reports
    -REP is received from Augur and distributed
    -Tokens and ETH is received from Augur and distributed

*/

//TODO include abstracts for code to be called, including basic token usage and augur

contract RepPool {

    //list of addresses:  https://github.com/AugurProject/augur-contracts/blob/master/contracts.json
    //address for reporting contract
    Reporting public reporting;
    //address for REP token
    Rep public rep;
    //list of addresses approved to report
    address[] public admin;

    //tokens and eth owned by pool members
    mapping(address => uint) rep_owned;
    mapping(address => mapping(address => uint)) tokens_owned; //mapping of user address to tokens.  Second mapping is token address to amount of tokens.
    mapping(address => uint) eth_owned;

    //overflow is used when amount can't be evenly distributed between pool members
    mapping(address => uint) rep_overflow;
    mapping(address => mapping(address => uint)) tokens_overflow;
    mapping(address => uint) eth_overflow;

    //amount owned by admins - distributed as soon as it's deposited
    uint admin_rep;
    mapping(address => uint) admin_tokens
    uint admin_eth;

    //TODO figure out how to check if value is in array
    //TODO determine best practices for modifiers
    modifier isAdmin() {
        if(msg.sender is in admin) {
            _
        }
    }

    function RepPool(address augurAddress, address repAddress) {
        augur = Augur(augurAddress);
	rep = Rep(repAddress);
        admin.push(msg.sender);
    }

    //Must have "approved" contract to transfer Rep tokens
    //TODO check that transferFrom generates exception correctly if something goes wrong
    function depositRep(uint amount) {
        rep.transferFrom(msg.sender, this, amount);
        rep_owned[msg.sender] += amount;
    }

    //Complete
    function withdrawRep(uint amount) {
        if(rep_owned[msg.sender] >= amount){
            rep_owned[msg.sender] -= amount;
            rep.transfer(msg.sender, amount);
        }
    }

    function withdrawRewards() {
        //for each token
        if(tokens_owned[msg.sender][token] > 0){
	    uint amount = tokens_owned[msg.sender][token];
	    tokens_owned[msg.sender][token] = 0;
            token.transfer(msg.sender, amount);
	}
	//end for
	if(eth_owned[msg.sender] > 0){
	    //send eth to msg.sender
	}
    }

    function withdrawAdmin() isAdmin {
        if(admin > 0){
	    uint amount = rep_admin;
	    rep_admin = 0;
	    rep.transfer(msg.sender, amount);
        }
	//for each token
	if(tokens_admin[token] > 0){
	    uint amount = tokens_admin[token];
	    tokens_admin[token] = 0;
	    token.transfer(msg.sender, amount);
	}
	if(eth_admin > 0){
            //send eth to msg.sender
        }
    }

    //!!!!There is a monster merge coming up between the develop and master branches of Augur, so things will change and I don't know which format will take precedence for each function.  The following four functions are the ones I'm worried about.  Can't set these in stone until after the merge.  Then we'll see.

    //first half of the reporting period
    function penalizeWrong() Admin {
        //must be called at the beginning of the reporting period
        penalizeWrong(uint256 branch, uint256 sender) returns number;
    }

    //first half of the reporting period
    function report(uint256 salt, uint256 report, uint256 event, uint256 ethics) Admin {
        //if sender address is in admin address array
        //use Augur function to report result
	uint256 salt; //use as argument?  Have to keep track for when the report is revealed.
	uint256 report; //this will have to be an argument, as this is the actual report.
	uint256 eventID; //retrieve this somehow.  Maybe an argument.  Function to be looped through with an array of events?
	uint256 sender = this; //assumed to be the address of this contract.
	uint256 ethics;  //This is a flag for the ethicality of the event - 0 if unethical, 1 if ethical.  Use as argument
	uint256 reportHash = report.makeHash(salt, report, event, sender, ethics) returns hash;
	report.submitReportHash(uint256 event, uint256 reportHash, uint256 encryptedSaltyHash) returns number;
    }

    //second half of the reporting period
    function reveal() Admin {
        report.submitReport(uint256 event, uint256 salt, uint256 report, uint256 ethics) returns number;
    }

    //second half of the reporting period
    //cannot send or receive pre-collection.  Therefore, if someone tries to call deposit or withdraw, call collectFees
    //In the beginning of the function, check if collectFees was already called this 
    function collectFees() {
        collectFees(uint256 branch, uint256 sender) returns number;
    }
    
    function() {
        //used only when Augur sends Eth.  All else is considered donations.
	//I don't think the function needs to contain anything.
    }

    function updateTokenCount() {
        //distribute tokens and update count when tokens are sent by Augur.
	//Can't automatically read when tokens are sent, so have to do it on a timer.
	//Do it either at the time they are sent, or as soon after as is feasible, to keep people from trying to get rewards twice by depositing after getting their rewards.  Maybe save a snapshot of the distribution, and distribute that way?

        //there's a function called collectFees, current thoughts is that the function distributes income based on rep held at the time of calling.  That could take care of my entire issue.
    }
    
    function setAugurAddress(address newAugur) Admin {
            augur = Augur(newAugur);
    }
    
    function update() Admin{
    
    }

}
