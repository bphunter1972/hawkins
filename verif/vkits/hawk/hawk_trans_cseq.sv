
// ***********************************************************************
// File:   hawk_trans_cseq.sv
// Author: bhunter
/* About:  Chaining sequence for Transaction level.
   Copyright (C) 2015-2016  Brian P. Hunter

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
 *************************************************************************/

`ifndef __HAWK_TRANS_CSEQ_SV__
   `define __HAWK_TRANS_CSEQ_SV__

`include "hawk_trans_item.sv"
`include "hawk_os_item.sv"
`include "hawk_types.sv"

typedef class trans_csqr_c;

// class: trans_cseq_c
// Sends transaction items to the link layer. Also receives inbound transaction items as responses
class trans_cseq_c extends cmn_pkg::cseq_c#(trans_item_c, trans_item_c,
                                            os_item_c, os_item_c,
                                            trans_csqr_c);
   `uvm_object_utils(hawk_pkg::trans_cseq_c)
   `uvm_declare_p_sequencer(trans_csqr_c)

   //----------------------------------------------------------------------------------------
   // Group: Fields

   // var: outstanding_reads
   // All of the reads from the OS that are expecting a response, based on tag
   os_item_c outstanding_reads[tag_t];

   // var: memory
   // The actual memory values of this node. May be written to or read from.
   data_t memory[addr_t];

   // var: free_tags
   // A pool of free tags
   tag_t free_tags[$];

   //----------------------------------------------------------------------------------------
   // Group: Methods
   function new(string name="trans_cseq");
      super.new(name);

      // seed all free tags
      for(int tag=0; tag < 16; tag++)
         free_tags.push_back(tag);
      free_tags.shuffle();
   endfunction : new

   ////////////////////////////////////////////
   // func: body
   // Prototype is what we want, no reason to override

   ////////////////////////////////////////////
   // func: handle_up_items
   // Retrieve transaction-level items from upstream and send them along
   virtual task handle_up_items();
      trans_item_c trans_item;
      os_item_c os_item;

      forever begin
         get_next_up_item(os_item);
         `cmn_dbg(200, ("RX from OS : %s", os_item.convert2string()))
         case(os_item.access)
            UVM_READ: begin
               // for reads, we must first get a free tag before the read can be done
               // once sent, we need to keep it as an outstanding read to be retired later
               tag_t read_tag;
               get_a_free_tag(read_tag);
               `uvm_create(trans_item)
               trans_item.uid = os_item.uid.new_subid("TRN");
               `uvm_rand_send_with(trans_item, {
                  tag == read_tag;
                  cmd == RD;
                  addr == os_item.addr;
               })
               `cmn_dbg(200, ("TX to   LNK: %s", trans_item.convert2string()))
               outstanding_reads[read_tag] = os_item;
            end
            UVM_WRITE: begin
               // writes can just be done straightaway. Just give the trans-item
               // it's own unique sub-id
               `uvm_create(trans_item)
               trans_item.uid = os_item.uid.new_subid("TRN");
               `uvm_rand_send_with(trans_item, {
                  cmd == WR;
                  addr == os_item.addr;
                  data == os_item.data;
               })
               `cmn_dbg(200, ("TX to   LNK: %s", trans_item.convert2string()))
            end
         endcase
      end
   endtask : handle_up_items

   ////////////////////////////////////////////
   // func: handle_down_traffic
   // Because send_read_response is a task, we cannot simply use create_up_rsp
   // and must instead override handle_down_traffic
   // This function handles all of the reads and writes, and only sends UP the responses
   // to reads from the OS level
   virtual task handle_down_traffic();
      trans_item_c down_traffic;

      forever begin
         get_down_traffic(down_traffic);
         `cmn_dbg(200, ("RX from LNK: %s", down_traffic.convert2string()))

         case(down_traffic.cmd)
            WR  : begin
               memory[down_traffic.addr] = down_traffic.data;
               `cmn_dbg(200, ("Wrote [%08X] = %016X", down_traffic.addr, down_traffic.data))
            end
            RD  : send_read_response(down_traffic);
            RESP: begin
               if(outstanding_reads.exists(down_traffic.tag)) begin
                  os_item_c outstanding_read = outstanding_reads[down_traffic.tag];
                  outstanding_read.data = down_traffic.data;
                  put_up_response(outstanding_read);
                  outstanding_reads.delete(down_traffic.tag);
                  free_a_tag(down_traffic.tag);
               end else
                  `cmn_err(("TAG:%01X Received response with tag that does not match any outstanding reads.", down_traffic.tag))
            end
         endcase
      end
   endtask : handle_down_traffic

   ////////////////////////////////////////////
   // func: get_a_free_tag
   // Get a tag. Block if none are available
   virtual task get_a_free_tag(ref tag_t _tag);
      wait(free_tags.size() > 0);
      _tag = free_tags.pop_front();
      `cmn_dbg(300, ("TAG:%01X Consumed", _tag))
   endtask : get_a_free_tag

   ////////////////////////////////////////////
   // func: free_a_tag
   // Frees up a tag for consumption
   virtual function void free_a_tag(tag_t _tag);
      free_tags.push_back(_tag);
      `cmn_dbg(300, ("TAG:%01X Freed", _tag))
   endfunction : free_a_tag

   ////////////////////////////////////////////
   // func: send_read_response
   // Respond to a read
   virtual task send_read_response(trans_item_c _read_request);
      trans_item_c response_item;
      data_t rsp_data;

      if(!memory.exists(_read_request.addr)) begin
         memory[_read_request.addr] = 0;
         `cmn_warn(("Reading from uninitialized memory location [%016X]", _read_request.addr))
      end

      rsp_data = memory[_read_request.addr];

      `uvm_do_with(response_item, {
         cmd  == RESP;
         data == rsp_data;
         tag  == _read_request.tag;
      })

      `cmn_dbg(200, ("TX to   LNK: %s", response_item.convert2string()))
   endtask : send_read_response

endclass : trans_cseq_c

`endif // __HAWK_TRANS_CSEQ_SV__

