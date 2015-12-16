
// ***********************************************************************
// File:   hawk_phy_cseq.sv
// Author: bhunter
/* About:  Chaining sequence receives link items and transmits phy items
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

`ifndef __HAWK_PHY_CSEQ_SV__
   `define __HAWK_PHY_CSEQ_SV__

`include "hawk_link_item.sv"
`include "hawk_phy_item.sv"

typedef class phy_csqr_c;

// class: phy_cseq_c
class phy_cseq_c extends uvm_sequence#(phy_item_c);
   `uvm_object_utils(hawk_pkg::phy_cseq_c)
   `uvm_declare_p_sequencer(phy_csqr_c)

   //----------------------------------------------------------------------------------------
   // Group: Methods
   function new(string name="phy_cseq");
      super.new(name);
   endfunction : new

   ////////////////////////////////////////////
   // func: body
   virtual task body();
      fork
         send_link_items();
         send_idles();
         handle_rsp();
      join
   endtask : body

   ////////////////////////////////////////////
   // func: send_link_items
   // Send the link items coming from upstream
   virtual task send_link_items();
      link_item_c link_item;
      phy_item_c phy_item;

      forever begin
         // fetch the next upstream link packet to send
         p_sequencer.get_up_item(link_item);

         `cmn_dbg(200, ("RX from LNK: %s", link_item.convert2string()))
         if(link_item.phy_char == PKT) begin
            byte unsigned stream[];
            link_item.pack_bytes(stream);
            foreach(stream[idx]) begin
               `uvm_create(phy_item)
               phy_item.uid = link_item.uid.new_subid("PHY");
               phy_item.valid = 1;
               phy_item.data = stream[idx];
               `uvm_send_pri(phy_item, PKT_PRI)
               `cmn_dbg(200, ("TX to   DRV: %s", phy_item.convert2string()))
            end
            `uvm_create(phy_item)
            phy_item.uid = link_item.uid.new_subid("PHY");
            phy_item.valid = 0;
            phy_item.data = EOP;
            `uvm_send_pri(phy_item, PKT_PRI)
         end else begin
            // otherwise send the PHY character (ACK or NAK)
            phy_item_c phy_item;
            `uvm_create(phy_item)
            phy_item.uid = link_item.uid.new_subid("PHY");
            `uvm_rand_send_pri_with(phy_item, ACK_NAK_PRI, {
               valid == link_item.phy_char[8];
               data == link_item.phy_char[7:0];
            })
            `cmn_dbg(200, ("TX to   DRV: %s", phy_item.convert2string()))
         end
      end
   endtask : send_link_items

   ////////////////////////////////////////////
   // func: send_idles
   // Constantly send idles. These have the lowest priority, so will
   // only win arbitration when nothing else is going on
   virtual task send_idles();
      byte unsigned idle_cnt = 0;
      phy_item_c idle_item;

      forever begin
         if(idle_cnt == 'hF1)
            idle_cnt = 0;
         `uvm_do_pri_with(idle_item, IDLE_PRI, {
            valid == 0;
            data == idle_cnt;
         })
         idle_cnt += 1;
      end
   endtask : send_idles

   ////////////////////////////////////////////
   // func: handle_rsp
   // Pull phy_item responses from sequencer. Filter out idles and training.
   // from the rest, pack up as link_items and send as upstream responses
   virtual task handle_rsp();
      link_item_c up_rsp;
      phy_item_c pkt_items[$];
      phy_item_c seed_item;

      `uvm_create(seed_item)
      seed_item.seed_item = 1;
      `uvm_send(seed_item)

      forever begin
         get_response(rsp); // rsp is a phy_item_c
         `cmn_dbg(200, ("RX from DRV: %s", rsp.convert2string()))

         // if it's either IDLE or training, then toss it on the floor
         if(rsp.is_idle_or_trn())
            continue;

         if(rsp.valid == 1)
            pkt_items.push_back(rsp);
         else if(rsp.data == EOP) begin
            // create a link item out of all the pkt_items in the queue
            up_rsp = make_link_item(pkt_items);
            pkt_items.delete();
            // send upstream
            p_sequencer.put_up_response(up_rsp);
         end else begin
            up_rsp = link_item_c::type_id::create("up_rsp");
            up_rsp.phy_char = {rsp.valid, rsp.data};
            p_sequencer.put_up_response(up_rsp);
         end
      end
   endtask : handle_rsp

   ////////////////////////////////////////////
   // func: make_link_item
   // Pack up phy items into a link item
   virtual function link_item_c make_link_item(ref phy_item_c _items[$]);
      byte unsigned stream[];
      make_link_item = link_item_c::type_id::create("make_link_item");
      stream = new[_items.size()];
      foreach(_items[idx])
         stream[idx] = _items[idx].data;
      make_link_item.unpack_bytes(stream);
      make_link_item.corrupt_crc = 0;
   endfunction : make_link_item
endclass : phy_cseq_c

`endif // __HAWK_PHY_CSEQ_SV__

