
// ***********************************************************************
// File:   hawk_mem.sv
// Author: bhunter
/* About:  Contains the memory of an agent.
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

