
// ***********************************************************************
// File:   hawk_link_cseq.sv
// Author: bhunter
/* About:  Chaining sequence for Link-level
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

`ifndef __HAWK_LINK_CSEQ_SV__
   `define __HAWK_LINK_CSEQ_SV__

`include "hawk_link_item.sv"
`include "hawk_trans_item.sv"
`include "hawk_cfg.sv"

typedef class link_csqr_c;

// class: link_cseq_c
// Sends link-level items, receives link-level requests
// Also receives from upstream transaction-level items and sends back transaction level items
class link_cseq_c extends uvm_sequence#(link_item_c);
   `uvm_object_utils(hawk_pkg::link_cseq_c)
   `uvm_declare_p_sequencer(link_csqr_c)

   //----------------------------------------------------------------------------------------
   // Group: Fields

   // var: link_id
   // A link ID put onto every single packet link item
   rand byte unsigned link_id;

   // var: replay_buffer
   // All of the link items that have been sent go here until either acknowledged or NAK is
   // received
   link_item_c replay_buffer[$];

   // var: ack_buffer
   // Incoming link-level items that must be either ACKed or NAKed
   // after ACK, send as upstream response
   link_item_c ack_buffer[$];

   // var: acks_to_send
   // Each bit will send an acknowledge. If the bit is 1, then send a NAK
   mailbox#(bit) acks_to_send;

   // var: cfg
   // The hawk cfg class
   cfg_c cfg;

   //----------------------------------------------------------------------------------------
   // Group: Methods
   function new(string name="link_cseq");
      super.new(name);
      acks_to_send = new();
   endfunction : new

   ////////////////////////////////////////////
   // func: body
   virtual task body();
      // get a handle to the cfg class
      cfg = p_sequencer.cfg;
      assert(cfg) else
         `cmn_fatal(("Eek! There is no cfg"))

      // fork off all of these threads
      fork
         handle_trans_items();
         handle_rsp();
         send_ack_nak();
      join
   endtask : body

   ////////////////////////////////////////////
   // func: handle_trans_items
   // Manage all upstream transaction items, wrapping them with LINK ID and
   // sending them on as link-level items
   virtual task handle_trans_items();
      trans_item_c trans_item;
      link_item_c link_item;
      forever begin
         p_sequencer.get_up_item(trans_item);
         `cmn_dbg(200, ("RX from LOG: %s", trans_item.convert2string()))
         `uvm_create(link_item)
         link_item.trans_item = trans_item;
         `uvm_rand_send_pri_with(link_item, PKT_PRI, {
            phy_char == PKT;
            corrupt_crc dist {
               0 := (100-cfg.bad_crc_pct),
               1 := cfg.bad_crc_pct
            };
         })
         replay_buffer.push_back(link_item);
         `cmn_dbg(200, ("TX to   PHY: %s", link_item.convert2string()))
      end
   endtask : handle_trans_items

   ////////////////////////////////////////////
   // func: handle_rsp
   // Handle all link-level responses from the PHY level.  All ACKs pull from
   // the replay buffer and are thrown away. All NAKs are replayed.
   // All incoming packets are pushed as upstream responses
   virtual task handle_rsp();
      link_item_c replay;

      forever begin
         get_response(rsp);
         `cmn_dbg(200, ("RX from PHY: %s", rsp.convert2string()))
         case(rsp.phy_char)
            ACK: begin
               replay = replay_buffer.pop_front();
               `cmn_dbg(300, ("Item was acknowledged: %s", replay.convert2string()))
            end
            NAK: retry_item();
            PKT: begin
               bit send_nak;
               std::randomize(send_nak) with {send_nak dist {1 := cfg.nak_pct, 0 := (100-cfg.nak_pct)}; };
               acks_to_send.put(send_nak);
               if(!send_nak)
                  p_sequencer.put_up_response(rsp.trans_item);
            end
            default:
               `cmn_err(("Link-layer must never see these: %s", rsp.convert2string()))
         endcase
      end
   endtask : handle_rsp

   ////////////////////////////////////////////
   // func: send_ack_nak
   // Fetch acks to be sent from the acks_to_send mailbox and send them
   virtual task send_ack_nak();
      bit send_nak;
      link_item_c ack_item;
      phy_char_e phy_char;
      forever begin
         acks_to_send.get(send_nak);
         phy_char = (send_nak)? NAK : ACK;
         `uvm_do_pri_with(ack_item, ACK_NAK_PRI, {
            phy_char == local::phy_char;
            corrupt_crc == 0;
         })
         `cmn_dbg(100, ("TX to   PHY: %s", ack_item.convert2string()))
      end
   endtask : send_ack_nak

   ////////////////////////////////////////////
   // func: retry_item
   // Pulls from the replay buffer and re-sends a packet
   virtual task retry_item();
      link_item_c replay;

      replay = replay_buffer.pop_front();
      if(replay == null)
         `cmn_err(("Received a NAK but there were no outstanding replays."))
      else begin
         `cmn_dbg(1000, ("NAK RCVD for this packet: %s", replay.convert2string()))
         // re-send with high priority
         // lock to ensure it does not intermingle with packets from send_link_items
         lock();
         `uvm_send_pri(replay, REPLAY_PRI)
         replay_buffer.push_back(replay);
         unlock();
      end
   endtask : retry_item

endclass : link_cseq_c

`endif // __HAWK_LINK_CSEQ_SV__

