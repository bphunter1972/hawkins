
// ***********************************************************************
// File:   link_level.sv
// Author: bhunter
/* About:  Run without the PHY level enabled.
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

`ifndef __LINK_LEVEL_SV__
   `define __LINK_LEVEL_SV__

   `include "basic.sv"

// class: link_level_test_c
class link_level_test_c extends basic_test_c;
   `uvm_component_utils(link_level_test_c)

   //----------------------------------------------------------------------------------------
   // Group: Methods
   function new(string name="link_level",
                uvm_component parent=null);
      super.new(name, parent);
   endfunction : new

   ////////////////////////////////////////////
   // func: build_phase
   // Do not enable the phy level stuff.
   virtual function void build_phase(uvm_phase phase);
      uvm_config_db#(int)::set(this, "hawk_env", "phy_enable", 0);
      super.build_phase(phase);
   endfunction : build_phase

endclass : link_level_test_c

`endif // __LINK_LEVEL_SV__

