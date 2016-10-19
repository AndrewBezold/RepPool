/*

    TODO LIST
    -Update contract
    -Track incoming REP by address
    -Distribute earnings
    -Add reporting capability
    -Add ability to retrieve earnings
    -Add enum results, maybe?


    USE CASES
    -REP owner deposits REP
    -REP owner withdraws REP
    -REP owner withdraws owed tokens and ETH
    -Creator withdraws owed tokens and ETH
    -Creator approves address for reporting
    -Approved address reports
    -REP is received from Augur and distributed
    -Tokens and ETH is received from Augur and distributed

*/

//#import "augur.sol" //don't know what the correct way to import Augur would be.
//Also, I'd rather not clog my relatively small contract with the entirety of the Augur
//code.  Is there a better way?

contract RepPool {

    address creator;
    Augur public augur;
    address[] public approved;

    //tokens and eth owned by pool members
    mapping(address => uint) rep_owned;
    mapping(address => mapping(address => uint)) tokens_owned; //mapping of user address to tokens.  Second mapping is token address to amount of tokens.
    mapping(address => uint) eth_owned;

    //overflow is used when amount can't be evenly distributed between pool members
    mapping(address => uint) rep_overflow;
    mapping(address => mapping(address => uint)) tokens_overflow;
    mapping(address => uint) eth_overflow;

    //amount owned by creator - distributed as soon as it's deposited
    uint creators_rep;
    mapping(address => uint) creators_tokens
    uint creators_eth;

    function RepPool(address augurAddress) {
        creator = msg.sender;
        augur = Augur(augurAddress);
        approved.push(msg.sender);
    }

    function depositRep(uint amount) {
        //check if sender has rep greater than or equal to "amount"
        //if no, throw or return false or otherwise break
        //if yes, receive rep, update rep_owned by adding "amount" to address mapping
    }

    function withdrawRep(uint amount) {
        //check if sender owns rep greater than or equal to "amount" deposited within contract
        //if no, throw or return false or otherwise break
        //if yes, send rep, update rep_owned by subtracting "amount" from address mapping
    }

    function withdrawRewards() {

    }
    
    function report() {
        //if sender address is in approved address array
        //use Augur function to report result
    }
    
    function() {
        //possibly pointless function, only accept REP
    }
    
    function setAugurAddress(address newAugur) {
        if(msg.sender == creator){
            augur = Augur(newAugur);
        }
    }
    
    function update {
    
    }

}
