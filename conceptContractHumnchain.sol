/* humnchain token for transfer of funds */
contract token { function transfer(address receiver, uint amount){  } }

/* CharityProject implements the www.humnchain.org smart contract for raising funds for charitable projects
   and tracking execution of these projects. These succesful completion of each project phase triggers the 
   payment of the next installment.

   In this prototype, the charity creates the CharityProject contract and supplies minimum information:
   - project name
   - project charter (hyperlink)
   - funding goal in ether
   - duration of the funding round
   - cost of each toker in ether
   - wallet address of the charity
   - address of the token used

   Donors can send tokens to the fund until the funding goal has been reached. Once reached, the fundraising
   stops.

   After the contract has been created, the charity can provide more information on the objective of this
   (single phase) project. They can then add reports on progress. Once the phase has been completed, they
   can add evidence of completion. All of these reports would be hyperlinks to the reports and evidence. 
   This contract should add a hash of the report to ensure that the reports don't change, but this is not
   in this prototype contract yet.

   At any time, donors or the charity can check if the funding goal has been completed and if evidence of 
   the completion of the (single phase) project has been provided. When this is the case, then the funds
   will be released to the charity.

   Any comments to henk@humnchain.org

   Thanks to Ethereum for creating the crowdfunding contract which was used as a basis for this humnchain
   contract.
   
   */

contract CharityProject {
    address public charity;
    uint public fundingGoal; uint public amountRaised; uint public deadline; uint public price;
    token public tokenReward;
    string public projectName;  string public charter; string public projectStatus;
    string public phaseObjective; string public phaseEvidence="none"; string public phaseReport;
    Funder[] public funders;
    event FundTransfer(address backer, uint amount, bool isContribution);
    bool charityProjectClosed = false; 
    bool charityProjectFunded = false;

    /* data structure to hold information about charitable donors */
    struct Funder {
        address addr;
        uint amount;
    }

    /*  at initialization, setup the owner */
    function CharityProject(
        string name,
        string projectCharter,
        uint fundingGoalInEthers, 
        uint durationInMinutes, 
        uint etherCostOfEachToken, 
        address ifSuccessfulSendTo, 
        token addressOfTokenUsedAsReward
    ) {
        charity = ifSuccessfulSendTo;
        fundingGoal = fundingGoalInEthers * 1 ether;
        deadline = now + durationInMinutes * 1 minutes;
        price = etherCostOfEachToken * 1 ether;
        tokenReward = token(addressOfTokenUsedAsReward);
        projectName=name;
        charter=projectCharter;
    }   

    /* update project phase info */

    function createPhaseObjective(string phase) {
        if (msg.sender==charity) {
            phaseObjective=phase;
        }
    }
    function createPhaseReport(string report) {
        if (msg.sender==charity) {
            phaseReport=report;
        }
    }
    function createPhaseEvidence(string evidence) {
            if (msg.sender==charity) {
            phaseEvidence=evidence;
        }
    }


    /* The function without name is the default function that is called whenever anyone sends funds to a contract */
    function () {
        if (charityProjectClosed || charityProjectFunded) throw;
        uint amount = msg.value;
        funders[funders.length++] = Funder({addr: msg.sender, amount: amount});
        amountRaised += amount;
        tokenReward.transfer(msg.sender, amount / price);
        FundTransfer(msg.sender, amount, true);
    }

    modifier afterDeadline() { if (now >= deadline) _ }
    modifier phaseDelivered() { if (!stringsEqual(phaseEvidence,"none")) _ }

    /* checks if the goal or time limit has been reached. If not, funds are returned*/
    function checkGoalReached() afterDeadline {
        if (amountRaised >= fundingGoal){
            projectStatus="Funding completed";
            charityProjectFunded=true;
        } else {
            projectStatus="Funding failed. Funds returned to donors";
            for (uint i = 0; i < funders.length; ++i) {
              funders[i].addr.send(funders[i].amount);  
              FundTransfer(funders[i].addr, funders[i].amount, false);
            }               
        }
    }
    
    /* checks if phase has been delivered, transfers funds and closes project*/
    function checkPhaseDelivered() phaseDelivered {
        charity.send(amountRaised);
        FundTransfer(charity, amountRaised, false);
        charity.send(this.balance); // send any remaining balance to charity anyway
        projectStatus="Phase delivered and paid";
        charityProjectClosed = true;
    }

     /* Function to recover the funds on the contract */
    function kill() { if (msg.sender == charity) suicide(charity); }
    
    function stringsEqual(string storage _a, string memory _b) internal returns (bool) {
        bytes storage a = bytes(_a);
        bytes memory b = bytes(_b);
        if (a.length != b.length)
            return false;
        // @todo unroll this loop
        for (uint i = 0; i < a.length; i ++)
            if (a[i] != b[i])
                return false;
        return true;
    }

}
