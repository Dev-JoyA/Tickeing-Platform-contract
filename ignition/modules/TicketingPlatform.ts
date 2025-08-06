// ignition/modules/TicketingPlatform.ts

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("TicketingPlatformModule", (m) => {
  const ticketingPlatform = m.contract("TicketingPlatformContract");

  return {
    ticketingPlatform,
  };
});
