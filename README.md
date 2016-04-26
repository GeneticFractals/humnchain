CharityProject implements the www.humnchain.org smart contract for raising funds for charitable projects
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
