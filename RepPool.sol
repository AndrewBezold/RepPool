/*

    TODO LIST
    -Update contract
    -Track incoming REP by address
    -Distribute earnings
    -Add reporting capability
    -Add ability to retrieve earnings
    -Add enum results, maybe?

*/


contract RepPool {

    address creator;
    address public augur;
    address[] approved;
    mapping(address => uint) rep_owned;
    

    function RepPool(address augurAddress) {
        creator = msg.sender;
	augur = augurAddress;
	approved.push(msg.sender);
    }

    function depositRep() {

    }

    function withdrawRep() {

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
    
    !!function setAugurAddress(address newAugur) {
        if(!!sender == creator.address){
            augur = newAugur;
        }
    }
    
    function update {
    
    }

}