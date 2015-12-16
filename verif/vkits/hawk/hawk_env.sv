
// ***********************************************************************
// File:   hawk_env.sv
// Author: bhunter
/* About:  Creates an rx and tx agent that run independently.
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

`ifndef __HAWK_ENV_SV__
   `define __HAWK_ENV_SV__

`include "hawk_agent.sv"

// class: env_c
class env_c extends uvm_env;
   `uvm_component_utils_begin(hawk_pkg::env_c)
      `uvm_field_object(cfg, UVM_REFERENCE)
   `uvm_component_utils_end

   //----------------------------------------------------------------------------------------
   // Group: Configuration Fields

   // var: cfg
   // The hawk cfg knobs class
   cfg_c cfg;

   //----------------------------------------------------------------------------------------
   // Group: Fields

   // var: rx_agent, tx_agent
   // The hawk rx_agent & tx_agent
   hawk_pkg::agent_c rx_agent, tx_agent;

   //----------------------------------------------------------------------------------------
   // Group: Methods
   function new(string name="[name]",
                uvm_component parent=null);
      super.new(name, parent);
   endfunction : new

   ////////////////////////////////////////////
   // func: build_phase
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      tx_agent = hawk_pkg::agent_c::type_id::create("rx_agent", this);
      rx_agent = hawk_pkg::agent_c::type_id::create("tx_agent", this);
      uvm_config_db#(uvm_object)::set(this, "*", "cfg", cfg);
   endfunction : build_phase

   ////////////////////////////////////////////
   // func: connect_phase
   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      rx_agent.mon_item_port.connect(tx_agent.inb_item_export);
      tx_agent.mon_item_port.connect(rx_agent.inb_item_export);
   endfunction : connect_phase
endclass : env_c

`endif // __HAWK_ENV_SV__

