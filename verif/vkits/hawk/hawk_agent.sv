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
`include "hawk_csqr_lib.sv"
`include "hawk_os_sqr.sv"
`include "hawk_phy_item.sv"
`include "hawk_os_item.sv"

// class: agent_c
class agent_c extends uvm_agent;
   `uvm_component_utils_begin(hawk_pkg::agent_c)
      `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
      `uvm_field_int(phy_enable, UVM_DEFAULT)
   `uvm_component_utils_end

   //----------------------------------------------------------------------------------------
   // Group: Configuration Fields

   // var: phy_enable
   // When set, the PHY CSQR will be connected, and the driver and monitor will also be created
   bit phy_enable = 1;

   //----------------------------------------------------------------------------------------
   // Group: TLM Ports

   // var: mon_item_port
   // Monitored items go out of this port
   uvm_analysis_port#(phy_item_c) mon_item_port;

   // var: inb_item_export
   // Items coming INTO this agent from the OTHER monitor come in through here
   uvm_analysis_export #(phy_item_c) inb_item_export;

   // var: rx_os_item_port
   // All monitored OS items go out here
   uvm_analysis_port#(os_item_c) rx_os_item_port;

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
   // Chained sequencer for the transaction layer
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

      if(phy_enable) begin
         mon_item_port = new("mon_item_port", this);
         inb_item_export = new("inb_item_export", this);
         mon = mon_c::type_id::create("mon", this);
         if(is_active) begin
            drv = drv_c::type_id::create("drv", this);
            phy_csqr = phy_csqr_c::type_id::create("phy_csqr", this);
         end
      end else
         uvm_config_db#(int)::set(this, "link_csqr", "drv_disabled", 1);

      if(is_active) begin
         link_csqr = link_csqr_c::type_id::create("link_csqr", this);
         trans_csqr = trans_csqr_c::type_id::create("trans_csqr", this);
         os_sqr = os_sqr_c::type_id::create("os_sqr", this);
      end

      rx_os_item_port = new("rx_os_item_port", this);
   endfunction : build_phase

   ////////////////////////////////////////////
   // func: connect_phase
   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if(mon && mon_item_port)
         mon.phy_item_port.connect(mon_item_port);
      if(is_active) begin
         if(phy_enable) begin
            drv.seq_item_port.connect(phy_csqr.seq_item_export);
            phy_csqr.up_seq_item_port.connect(link_csqr.seq_item_export);
            phy_csqr.up_traffic_port.connect(link_csqr.down_traffic_export);
            inb_item_export.connect(phy_csqr.down_traffic_export);
         end

         link_csqr.up_seq_item_port.connect(trans_csqr.seq_item_export);
         trans_csqr.up_seq_item_port.connect(os_sqr.seq_item_export);
         link_csqr.up_traffic_port.connect(trans_csqr.down_traffic_export);

         trans_csqr.up_traffic_port.connect(rx_os_item_port);
         trans_csqr.up_traffic_port.connect(os_sqr.rcvd_os_item_export);
      end
   endfunction : connect_phase
endclass : agent_c

`endif // __HAWK_AGENT_SV__

