//-*- mode: Verilog; verilog-indent-level: 3; indent-tabs-mode: nil; tab-width: 1 -*-
// vim: tabstop=3 expandtab shiftwidth=3 softtabstop=3

// **********************************************************************
// * CAVIUM CONFIDENTIAL AND PROPRIETARY NOTE
// *
// * This software contains information confidential and proprietary to
// * Cavium, Inc. It shall not be reproduced in whole or in part, or
// * transferred to other documents, or disclosed to third parties, or
// * used for any purpose other than that for which it was obtained,
// * without the prior written consent of Cavium, Inc.
// * Copyright 2016, Cavium, Inc.  All rights reserved.
// * (utg v1.3.2)
// ***********************************************************************
// File:   hawk_mem.sv
// Author: bhunter
/* About:  Contains the memory of an agent.
 *************************************************************************/

`ifndef __HAWK_MEM_SV__
   `define __HAWK_MEM_SV__

`include "hawk_types.sv"

// class: mem
// Just holds a memory. More advanced stuff if you need it.
class mem_c extends uvm_component;
   `uvm_component_utils_begin(hawk_pkg::mem_c)
   `uvm_component_utils_end

   //----------------------------------------------------------------------------------------
   // Group: Fields

   // var: memory
   // The actual memory values of this node. May be written to or read from.
   data_t memory[addr_t];

   //----------------------------------------------------------------------------------------
   // Group: Methods
   function new(string name="mem",
                uvm_component parent=null);
      super.new(name, parent);
   endfunction : new
endclass : mem_c

`endif // __HAWK_MEM_SV__

