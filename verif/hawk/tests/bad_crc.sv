
// ***********************************************************************
// File:   bad_crc.sv
// Author: bhunter
/* About:  Enable Bad CRC generation.
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

`ifndef __BAD_CRC_SV__
   `define __BAD_CRC_SV__

   `include "basic.sv"

// class: bad_crc_test_c
class bad_crc_test_c extends basic_test_c;
   `uvm_component_utils_begin(bad_crc_test_c)
   `uvm_component_utils_end

   //----------------------------------------------------------------------------------------
   // Group: Constraints

   // constraint: bad_crc_pct_cnstr
   // Allow bad CRC's at a 5% rate
   constraint bad_crc_pct_cnstr {
      cfg.bad_crc_pct == 5;
   }

   //----------------------------------------------------------------------------------------
   // Group: Methods
   function new(string name="bad_crc",
                uvm_component parent=null);
      super.new(name, parent);
   endfunction : new

   ////////////////////////////////////////////
   // func: randomize_cfg
   // Disable the L2_bad_crc_pct constraint
   virtual function void randomize_cfg();
      cfg.L2_bad_crc_pct_cnstr.constraint_mode(0);
      super.randomize_cfg();
   endfunction : randomize_cfg

endclass : bad_crc_test_c

`endif // __BAD_CRC_SV__

