
// ***********************************************************************
// File:   nak.sv
// Author: bhunter
/* About:  Enable NAKs.
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

`ifndef __NAK_SV__
   `define __NAK_SV__

   `include "basic.sv"

// class: nak_test_c
class nak_test_c extends basic_test_c;
   `uvm_component_utils_begin(nak_test_c)
   `uvm_component_utils_end

   //----------------------------------------------------------------------------------------
   // Group: Constraints

   // constraint: nak_pct_cnstr
   // Permit nak to be 2-3%
   constraint nak_pct_cnstr {
      cfg.nak_pct == inside {2, 3};
   }

   //----------------------------------------------------------------------------------------
   // Group: Methods
   function new(string name="nak",
                uvm_component parent=null);
      super.new(name, parent);
   endfunction : new

   ////////////////////////////////////////////
   // func: randomize_cfg
   // Disable the L2 NAK Constraint
   virtual function void randomize_cfg();
      cfg.L2_nak_pct_cnstr.constraint_mode(0);
      super.randomize_cfg();
   endfunction : randomize_cfg

endclass : nak_test_c

`endif // __NAK_SV__

