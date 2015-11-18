
// ***********************************************************************
// File:   hawk_types.sv
// Author: bhunter
/* About:  Contains enumerated types, etc.
   Copyright (C) 2015  Brian P. Hunter

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
 *************************************************************************/

`ifndef __HAWK_TYPES_SV__
   `define __HAWK_TYPES_SV__

`uvm_analysis_imp_decl(_inb_item)

// type: addr_t
// 64-bit addresses
typedef bit[63:0] addr_t;

// type: data_t
// 64-bit data
typedef bit[63:0] data_t;

// type: tag_t
// 4-bit tags
typedef bit[3:0] tag_t;

// enum: phy_char_e
// PHY Characters
typedef enum bit[8:0] {
   IDLE = 9'b000, // actual data between 00 and F0 stolen from link_id
   EOP =  9'h0FA, // end of packet
   ACK =  9'h0FC, // packet acknowledgement
   NAK =  9'h0FE, // packet not acknowledged
   TRN =  9'h0FF, // training sequence
   PKT =  9'h100  // holds packet data
} phy_char_e;

// enum: trans_cmd_e
// transaction commands
typedef enum bit[3:0] {
   RD = 4'h1,
   WR = 4'h2,
   RESP = 4'h4
} trans_cmd_e;

// enum: priority_e
// Priorities for sending traffic
typedef enum int {
   IDLE_PRI = 100,
   PKT_PRI = 200,
   REPLAY_PRI = 400,
   ACK_NAK_PRI = 500,
   TRN_PRI = 1000
} priority_e;

`endif // __HAWK_TYPES_SV__

