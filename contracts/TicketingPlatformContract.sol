// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract TicketingPlatformContract is ERC721URIStorage {

    string public eventName = "My Event";
    uint256 public ticketPrice = 0.01 ether;
    uint256 public maxTickets = 500;
    uint256 public ticketsSold;
    address public owner = msg.sender;

    uint256 private currentTokenId = 1;

    mapping(uint256 => address) public ticketOwners;
    mapping(address => uint256[]) public ticketsByOwner;

    enum TicketStatus { Valid, Cancelled }

    struct Ticket {
        uint256 id;
        string tokenURI;
        TicketStatus status;
    }

    mapping(uint256 => Ticket) public tickets;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not event organizer");
        _;
    }

    modifier ticketExists(uint256 _ticketId) {
        require(_ticketId > 0 && _ticketId < currentTokenId, "Ticket does not exist");
        _;
    }

    constructor() ERC721("EventTicket", "ETK") {}

    function buyTicket(string memory _tokenURI) external payable {
        require(ticketsSold < maxTickets, "Tickets sold out");
        require(msg.value == ticketPrice, "Incorrect ETH sent");
        require(bytes(_tokenURI).length > 0, "Token URI cannot be empty");

       
        uint256 tokenId = currentTokenId;
        currentTokenId++;
        ticketsSold++;

        _mint(msg.sender, tokenId);
        _setTokenURI(tokenId, _tokenURI);

        ticketOwners[tokenId] = msg.sender;
        ticketsByOwner[msg.sender].push(tokenId);

        tickets[tokenId] = Ticket({
            id : tokenId,
            tokenURI : _tokenURI,
            status : TicketStatus.Valid
        });
    }

    function cancelTicket(uint256 _ticketId) external ticketExists(_ticketId) {
        require(ownerOf(_ticketId) == msg.sender, "You don't own this ticket");
        require(tickets[_ticketId].status == TicketStatus.Valid, "Ticket already cancelled");


        if(tickets[_ticketId].status == TicketStatus.Cancelled){
            revert("tickets have already been cancelled");
        }

        tickets[_ticketId].status = TicketStatus.Cancelled;
    }

    function checkIfTicketExists(uint256 _ticketId) external view returns (bool) {
        return ownerOf(_ticketId) != address(0);
    }

    function checkIfTicketIsValid(uint256 _ticketId) external view ticketExists(_ticketId) returns (bool) {
        return tickets[_ticketId].status == TicketStatus.Valid;
    }

    function getTicketsOwnedBy(address _user) external view returns (uint256[] memory) {
        return ticketsByOwner[_user];
    }

    function getTotalTicketsSold() external view returns (uint256) {
        return ticketsSold;
    }

    function withdrawFunds() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}
