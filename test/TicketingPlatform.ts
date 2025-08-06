import { expect } from "chai";
import { ethers } from "hardhat";
import { parseEther } from "ethers";

describe("TicketingPlatform", function () {
  let ticketingPlatform: any;
  let owner: any;
  let user1: any;
  const ticketPrice = parseEther("0.01");

  beforeEach(async () => {
    [owner, user1] = await ethers.getSigners();

    const TicketingPlatform = await ethers.getContractFactory("TicketingPlatformContract", owner);
    ticketingPlatform = await TicketingPlatform.deploy(); // Signer now attached
  });

  it("Should deploy with correct default values", async function () {
    expect(await ticketingPlatform.eventName()).to.equal("My Event");
    expect(await ticketingPlatform.ticketPrice()).to.equal(ticketPrice);
    expect(await ticketingPlatform.maxTickets()).to.equal(500);
    expect(await ticketingPlatform.owner()).to.equal(owner.address);
  });

  it("Should allow a user to buy a ticket", async function () {
    const tokenURI = "ipfs://ticket1";
    const tx = await ticketingPlatform.connect(user1).buyTicket(tokenURI, { value: ticketPrice });
    await tx.wait();

    const tickets = await ticketingPlatform.getTicketsOwnedBy(user1.address);
    expect(tickets.length).to.equal(1);

    const ticketId = tickets[0];
    const ticket = await ticketingPlatform.tickets(ticketId);
    expect(ticket.tokenURI).to.equal(tokenURI);
    expect(ticket.status).to.equal(0); // TicketStatus.Valid
  });

  it("Should reject ticket purchase with incorrect price", async function () {
    await expect(
      ticketingPlatform.connect(user1).buyTicket("ipfs://ticket1", { value: parseEther("0.005") })
    ).to.be.revertedWith("Incorrect ETH sent");
  });

  it("Should cancel a ticket", async function () {
    const tokenURI = "ipfs://ticket1";
    await ticketingPlatform.connect(user1).buyTicket(tokenURI, { value: ticketPrice });

    const tickets = await ticketingPlatform.getTicketsOwnedBy(user1.address);
    const ticketId = tickets[0];

    const cancelTx = await ticketingPlatform.connect(user1).cancelTicket(ticketId);
    await cancelTx.wait();

    const ticket = await ticketingPlatform.tickets(ticketId);
    expect(ticket.status).to.equal(1); // TicketStatus.Cancelled
  });

  
});
