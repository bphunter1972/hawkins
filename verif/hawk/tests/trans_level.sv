
// ***********************************************************************
// File:   trans_level.sv
// Author: bhunter
/* About:  Run test with neither the PHY nor the LINK level sequences populated.
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

`ifndef __TRANS_LEVEL_SV__
   `define __TRANS_LEVEL_SV__

   `include "basic.sv"

// class: trans_level_test_c
class trans_level_test_c extends basic_test_c;
   `uvm_component_utils(trans_level_test_c)

   //----------------------------------------------------------------------------------------
   // Group: Methods
   function new(string name="trans_level",
                uvm_component parent=null);
      super.new(name, parent);
   endfunction : new

   ////////////////////////////////////////////
   // func: build_phase
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      uvm_config_db#(int)::set(this, "hawk_env", "link_enable", 0);
   endfunction : build_phase

endclass : trans_level_test_c

`endif // __TRANS_LEVEL_SV__

