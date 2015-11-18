// ***********************************************************************
// File:   cmn_csqr.sv
// Author: bhunter
/* About:  A chained sequencer, for use in sequence hierarchies.
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

`ifndef __CMN_CSQR_SV__
   `define __CMN_CSQR_SV__

`include "cmn_msgs.sv"

// class: csqr_c
class csqr_c#(type UP_REQ=uvm_sequence_item, UP_RSP=UP_REQ,
              DOWN_REQ=uvm_sequence, DOWN_RSP=DOWN_REQ)
              extends uvm_sequencer#(DOWN_REQ, DOWN_RSP);
   `uvm_component_utils(cmn_pkg::csqr_c)

   //----------------------------------------------------------------------------------------
   // Group: TLM Ports

   // var: seq_item_port
   // Gets the next sequence from sequencers above this one
   uvm_seq_item_pull_port#(UP_REQ, UP_RSP) seq_item_port;

   //----------------------------------------------------------------------------------------
   // Group: Fields
   // var: up_item_mbox
   // A mailbox that contains the next upstream items
   mailbox#(UP_REQ) up_item_mbox;

   // var: up_item_pulled
   // Triggered when the mailbox is pulled from
   event up_item_pulled;

   // var: up_id_info
   // The first sequence item from the upstream chaining sequence. All response items
   // are set to it
   UP_REQ up_id_info;

   //----------------------------------------------------------------------------------------
   // Group: Methods
   function new(string name="csqr",
                uvm_component parent=null);
      super.new(name, parent);
   endfunction : new

   ////////////////////////////////////////////
   // func: build_phase
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      up_item_mbox = new();
      seq_item_port = new("seq_item_port", this);
      set_arbitration(UVM_SEQ_ARB_STRICT_FIFO);
   endfunction : build_phase

   ////////////////////////////////////////////
   // func: run_phase
   virtual task run_phase(uvm_phase phase);
      fork
         super.run_phase(phase);
         fetcher();
      join
   endtask : run_phase

   ////////////////////////////////////////////
   // func: fetcher
   virtual task fetcher();
      UP_REQ item;
      seq_item_port.get_next_item(item);
      up_id_info = item;

      forever begin
         up_item_mbox.put(item);
         @(up_item_pulled);
         seq_item_port.item_done();

         // get the next item
         seq_item_port.get_next_item(item);
      end
   endtask : fetcher

   ////////////////////////////////////////////
   // func: try_get_up_item
   // Try to return an item in the mailbox
   virtual function bit try_get_up_item(ref UP_REQ _item);
      if(up_item_mbox.try_get(_item)) begin
         ->up_item_pulled;
         return 1;
      end else
         return 0;
   endfunction : try_get_up_item

   ////////////////////////////////////////////
   // func: get_up_item
   // Return the next item in the mailbox or wait
   virtual task get_up_item(ref UP_REQ _item);
      up_item_mbox.get(_item);
      ->up_item_pulled;
   endtask: get_up_item

   ////////////////////////////////////////////
   // func: put_up_response
   // Send a response back upstream. If no transaction ID has been set
   // for this response, then the first request received will be used
   // instead
   virtual function void put_up_response(UP_RSP _up_rsp);
      if(_up_rsp.get_transaction_id() == -1) begin
         if(up_id_info) begin
            _up_rsp.set_id_info(up_id_info);
         end else begin
            `cmn_err(("A response is pending before upstream ID information was found."))
            return;
         end
      end
      seq_item_port.put_response(_up_rsp);
   endfunction : put_up_response
endclass : csqr_c

`endif // __CMN_CSQR_SV__

