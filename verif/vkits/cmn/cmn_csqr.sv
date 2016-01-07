// ***********************************************************************
// File:   cmn_csqr.sv
// Author: bhunter
/* About:  A chained sequencer, for use in sequence hierarchies.
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

`ifndef __CMN_CSQR_SV__
   `define __CMN_CSQR_SV__

`include "cmn_msgs.sv"

// class: csqr_c
class csqr_c#(type UP_REQ=uvm_sequence_item, UP_TRAFFIC=UP_REQ,
              DOWN_REQ=uvm_sequence_item, DOWN_TRAFFIC=DOWN_REQ)
              extends uvm_sequencer#(DOWN_REQ);
   `uvm_component_utils_begin(cmn_pkg::csqr_c)
      `uvm_field_int(drv_disabled, UVM_DEFAULT)
   `uvm_component_utils_end

   //----------------------------------------------------------------------------------------
   // Group: Configuration Fields

   // var: drv_disabled
   // When set, the down_seq_item_port is created and takes the place of another chained
   // sequencer's driver. Downstream requests are then automatically pulled.
   bit drv_disabled = 0;

   //----------------------------------------------------------------------------------------
   // Group: TLM Ports

   // var: up_seq_item_port
   // Gets the next sequence from the upstream sequencer
   uvm_seq_item_pull_port#(UP_REQ) up_seq_item_port;

   // var: up_traffic_port
   // Drives traffic back upstream
   uvm_analysis_port#(UP_TRAFFIC) up_traffic_port;

   // var: down_traffic_export
   // Receives traffic from the downstream sequencer
   uvm_analysis_export #(DOWN_TRAFFIC) down_traffic_export;

   // var: down_seq_item_port
   // Pulls downstream items from another chained sequencer just as a driver would
   // only created when drv_disabled == 1
   uvm_seq_item_pull_port#(DOWN_REQ, DOWN_TRAFFIC) down_seq_item_port;

   //----------------------------------------------------------------------------------------
   // Group: Fields
   // var: up_item_mbox
   // A mailbox that contains the next upstream items
   mailbox#(UP_REQ) up_item_mbox;

   // var: up_item_pulled
   // Triggered when the mailbox is pulled from
   event up_item_pulled;

   // var: down_traffic_fifo
   // Receives the traffic from the downstream sequencer
   uvm_tlm_analysis_fifo#(DOWN_TRAFFIC) down_traffic_fifo;

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

      up_traffic_port = new("up_traffic_port", this);
      down_traffic_export = new("down_traffic_export", this);
      down_traffic_fifo = new("down_traffic_fifo", this);

      up_item_mbox = new();
      up_seq_item_port = new("up_seq_item_port", this);

      set_arbitration(UVM_SEQ_ARB_STRICT_FIFO);
      if(drv_disabled)
         down_seq_item_port = new("down_seq_item_port", this);
   endfunction : build_phase

   ////////////////////////////////////////////
   // func: connect_phase
   // Connect downstream traffic fifo to export
   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      down_traffic_export.connect(down_traffic_fifo.analysis_export);
   endfunction : connect_phase

   ////////////////////////////////////////////
   // func: run_phase
   virtual task run_phase(uvm_phase phase);
      fork
         super.run_phase(phase);
         up_fetcher();
         if(drv_disabled)
            downstream_driver();
      join
   endtask : run_phase

   ////////////////////////////////////////////
   // func: up_fetcher
   virtual task up_fetcher();
      UP_REQ item;

      forever begin
         // get the next item
         up_seq_item_port.get_next_item(item);

         up_item_mbox.put(item);
         @(up_item_pulled);
         up_seq_item_port.item_done();
      end
   endtask : up_fetcher

   ////////////////////////////////////////////
   // func: downstream_driver
   // Pulls the requests out of the down_seq_item_port as a
   // driver would. Converts these to downstream traffic and pushes
   // it into the downstream fifo
   virtual task downstream_driver();
      DOWN_REQ down_req;
      DOWN_TRAFFIC down_traffic;

      forever begin
         down_seq_item_port.get_next_item(down_req);
         `cmn_info(("Saw down_req: %s", down_req.convert2string()))
         down_traffic = convert_down_req(down_req);
         down_traffic_fifo.analysis_export.write(down_traffic);
         down_seq_item_port.item_done();
      end
   endtask : downstream_driver

   ////////////////////////////////////////////
   // func: get_down_traffic
   // Return the next available piece of traffic from downstream
   virtual task get_down_traffic(ref DOWN_TRAFFIC _down_traffic);
      down_traffic_fifo.get(_down_traffic);
   endtask : get_down_traffic

   ////////////////////////////////////////////
   // func: convert_down_req
   // Convert a downstream request to downstream traffic
   // By default, these are the same and a cast will work. Override
   // if necessary
   virtual function DOWN_TRAFFIC convert_down_req(ref DOWN_REQ _down_req);
      $cast(convert_down_req, _down_req);
   endfunction : convert_down_req

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
   // func: put_up_traffic
   // Send traffic upstream.
   virtual function void put_up_traffic(UP_TRAFFIC _up_traffic);
      `cmn_info(("Putting upstream traffic: %s", _up_traffic.convert2string()))
      up_traffic_port.write(_up_traffic);
   endfunction : put_up_traffic

   ////////////////////////////////////////////
   // func: put_up_response
   // Send a response upstream using the sequence item port
   virtual function void put_up_response(UP_TRAFFIC _up_traffic);
      up_seq_item_port.put_response(_up_traffic);
   endfunction : put_up_response

endclass : csqr_c

`endif // __CMN_CSQR_SV__

