// ***********************************************************************
// File:   hawk_agent.sv
// Author: bhunter
/* About:  The Hawk agent.
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

`ifndef __HAWK_AGENT_SV__
   `define __HAWK_AGENT_SV__

`include "hawk_drv.sv"
`include "hawk_mon.sv"
`include "hawk_sqr_lib.sv"
`include "hawk_phy_item.sv"

// class: agent_c
class agent_c extends uvm_agent;
   `uvm_component_utils_begin(hawk_pkg::agent_c)
      `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
   `uvm_component_utils_end

   //----------------------------------------------------------------------------------------
   // Group: TLM Ports

   // var: mon_item_port
   // Monitored items go out of this port
   uvm_analysis_port#(phy_item_c) mon_item_port;

   // var: inb_item_export
   // Items coming INTO this agent from the OTHER monitor come in through here
   uvm_analysis_export #(phy_item_c) inb_item_export;

   //----------------------------------------------------------------------------------------
   // Group: Fields

   // vars: Driver
   // Driver
   drv_c drv;

   // var: mon
   // The hawkins interface monitor
   mon_c mon;

   // var: phy_csqr
   // Chained sequencer that drives to driver
   phy_csqr_c phy_csqr;

   // var: link_csqr
   // Chained sequencer for the link layer
   link_csqr_c link_csqr;

   // var: trans_csqr
   // Chained sequencer for the log layer
   trans_csqr_c trans_csqr;

   // var: os_sqr
   // OS-level sequencer that drives to the transaction level
   os_sqr_c os_sqr;

   //----------------------------------------------------------------------------------------
   // Group: Methods
   function new(string name="hawk_agent",
                uvm_component parent=null);
      super.new(name, parent);
   endfunction : new

   ////////////////////////////////////////////
   // func: build_phase
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      mon_item_port = new("mon_item_port", this);
      inb_item_export = new("inb_item_export", this);
      if(is_active) begin
         drv = drv_c::type_id::create("drv", this);
         phy_csqr = phy_csqr_c::type_id::create("phy_csqr", this);
         link_csqr = link_csqr_c::type_id::create("link_csqr", this);
         trans_csqr = trans_csqr_c::type_id::create("trans_csqr", this);
         os_sqr = os_sqr_c::type_id::create("os_sqr", this);
      end
      mon = mon_c::type_id::create("mon", this);
   endfunction : build_phase

   ////////////////////////////////////////////
   // func: connect_phase
   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      mon.phy_item_port.connect(mon_item_port);
      if(is_active) begin
         inb_item_export.connect(drv.inb_item_imp);
         drv.seq_item_port.connect(phy_csqr.seq_item_export);
         phy_csqr.seq_item_port.connect(link_csqr.seq_item_export);
         link_csqr.seq_item_port.connect(trans_csqr.seq_item_export);
         trans_csqr.seq_item_port.connect(os_sqr.seq_item_export);
      end
   endfunction : connect_phase
endclass : agent_c

`endif // __HAWK_AGENT_SV__

