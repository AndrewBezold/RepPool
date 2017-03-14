pragma solidity ^0.4.9;
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
    -Admins change accepted tokens


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

contract Reporting {
    function makeHash(uint256 salt, uint256 fxpReport, uint256 augurEvent, uint256 sender, uint256 ethics) returns (uint256);
    function submitReportHash(uint256 augurEvent, uint256 reportHash, uint256 encryptedSaltyHash) returns (uint256);
    function submitReport(uint256 augurEvent, uint256 salt, uint256 fxpReport, uint256 ethics) returns (uint256);
}

contract Rep {
    function transferFrom(uint256 from, uint256 to, uint256 amount) returns (uint256);
    function transfer(uint256 to, uint256 amount) returns (uint256);
}

contract CollectFees {
    function collectRep(uint256 branch, uint256 sender) returns (uint256);
    function collectFees(uint256 branch, uint256 sender, uint256 currency) returns (uint256);
}

contract Consensus {
    function penalizeWrong(uint256 branch, uint256 augurEvent) returns (uint256);
}

contract Token {
    function transferFrom(address from, address to, uint256 amount);
    function transfer(address to, uint256 amount);
}

contract RepPool {

    //list of addresses:  https://github.com/AugurProject/augur-contracts/blob/master/contracts.json
    //address for reporting contract
    Reporting public reporting;
    //address for REP token
    Rep public rep;
    //address for fee collecting contract
    CollectFees public collectFees;
    //address for penalization
    Consensus public consensus;
    //list of addresses approved to report
    address[] public admin;
    //list of tokens accepted by Augur and, by extension, RepPool
    address[] public tokens;

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
    mapping(address => uint) admin_tokens;
    uint admin_eth;

    //Complete
    modifier isAdmin() {
        for(uint i = 0; i < admin.length; i++){
            if(msg.sender == admin[i]){
                _;
                break;
            }
        }
    }

    function RepPool(address reportingAddr, address repAddr, address collectFeesAddr, address consensusAddr) {
        reporting = Reporting(reportingAddr);
	    rep = Rep(repAddr);
	    collectFees = CollectFees(collectFeesAddr);
	    consensus = Consensus(consensusAddr);
        admin.push(msg.sender);
    }

    //Must have "approved" contract to transfer Rep tokens
    //TODO check that transferFrom generates exception correctly if something goes wrong
    function depositRep(uint amount) {
        rep.transferFrom(uint256(msg.sender), uint256(this), amount);
        rep_owned[msg.sender] += amount;
    }

    //Complete
    function withdrawRep(uint amount) {
        if(rep_owned[msg.sender] >= amount){
            rep_owned[msg.sender] -= amount;
            rep.transfer(uint256(msg.sender), amount);
        }
    }

    function withdrawRewards() {
        //for each token
	for(uint i = 0; i < tokens.length; i++){
	    if(tokens_owned[msg.sender][tokens[i]] > 0){
	        uint amount = tokens_owned[msg.sender][tokens[i]];
	        tokens_owned[msg.sender][tokens[i]] = 0;
	        Token(tokens[i]).transfer(msg.sender, amount);
	    }
	}
	//end for
	if(eth_owned[msg.sender] > 0){
	    //send eth to msg.sender
	    amount = eth_owned[msg.sender];
	    eth_owned[msg.sender] = 0;
	    if(!msg.sender.send(amount)){
	        throw;
	    }
	}
    }

    function withdrawAdmin() isAdmin {
        if(admin_rep > 0){
    	    uint amount = admin_rep;
    	    admin_rep = 0;
    	    rep.transfer(uint256(msg.sender), amount);
        }
	//for each token
	for(uint i = 0; i < tokens.length; i++){
	    if(admin_tokens[tokens[i]] > 0){
	        amount = admin_tokens[tokens[i]];
	        admin_tokens[tokens[i]] = 0;
	        Token(tokens[i]).transfer(msg.sender, amount);
	    }
	}
	if(admin_eth > 0){
            //send eth to msg.sender
	    amount = admin_eth;
	    admin_eth = 0;
	    if(!msg.sender.send(amount)){
	        throw;
	    }
        }
    }

    //Monster merge is done, following 4 functions need to be checked for correctness

    //needs to handle errors.  How?  What's a non-error result?
    //if penalty, decrease owned rep counts accordingly.  Recount?
    //first half of the reporting period
    function penalizeWrong(uint256 branch, uint256 augurEvent) isAdmin {
        //must be called at the beginning of the reporting period
        uint256 number = consensus.penalizeWrong(branch, augurEvent);
    }

    //error handing here too
    //first half of the reporting period
    function report(uint256 salt, uint256 report, uint256 augurEvent, uint256 ethics) isAdmin {
        //if sender address is in admin address array
        //use Augur function to report result
	uint256 reportHash = reporting.makeHash(salt, report, augurEvent, uint256(this), ethics);
	//TODO figure out how to get this
	uint256 encryptedSaltyHash = 0;
	uint256 number = reporting.submitReportHash(augurEvent, reportHash, encryptedSaltyHash);
    }

    //error checking
    //second half of the reporting period
    function reveal(uint256 augurEvent, uint256 salt, uint256 report, uint256 ethics) isAdmin {
        uint256 number = reporting.submitReport(augurEvent, salt, report, ethics);
    }

    //error checking
    //second half of the reporting period
    //cannot send or receive pre-collection.  Therefore, if someone tries to call deposit or withdraw, call collectFees
    //In the beginning of the function, check if collectFees was already called this period
    function collectFees(uint256 branch) {
        uint256 number = collectFees.collectRep(branch, uint256(this));
        for(uint i = 0; i < tokens.length; i++){
            number = collectFees.collectFees(branch, uint256(this), uint256(tokens[i]));
        }
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
    
    function setAugurAddress(address newReporting, address newRep, address newCollectFees, address newConsensus) isAdmin {
            reporting = Reporting(newReporting);
            rep = Rep(newRep);
            collectFees = CollectFees(newCollectFees);
            consensus = Consensus(newConsensus);
    }
    
    function update() isAdmin{
    
    }

}
