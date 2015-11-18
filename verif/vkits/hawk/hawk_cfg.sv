
// ***********************************************************************
// File:   hawk_cfg.sv
// Author: bhunter
/* About:  Knobs for hawk vkit.
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

`ifndef __HAWK_CFG_SV__
   `define __HAWK_CFG_SV__

// class: cfg_c
class cfg_c extends uvm_object;
   `uvm_object_utils_begin(hawk_pkg::cfg_c)
      `uvm_field_int(coverage_enable, UVM_ALL_ON)
      `uvm_field_int(nak_pct,         UVM_DEFAULT | UVM_DEC)
      `uvm_field_int(bad_crc_pct,     UVM_DEFAULT | UVM_DEC)
   `uvm_object_utils_end

   //----------------------------------------------------------------------------------------
   // Group: Fields

   // var: coverage_enable
   // Is functional coverage collection enabled?
   int coverage_enable;

   // var: nak_pct
   // The percentage of packets received by the link layer that will be NAK'ed.
   rand int unsigned nak_pct;

   // constraint: L0_nak_pct_cnstr
   // Keep NAK betweek 0-100
   constraint L0_nak_pct_cnstr {
      nak_pct inside {[0:100]};
   }

   // constraint: L1_nak_pct_cnstr
   // Keep NAK low
   constraint L1_nak_pct_cnstr {
      nak_pct inside {[0:10]};
   }

   // constraint: L2_nak_pct_cnstr
   // Turn it off altogether
   constraint L2_nak_pct_cnstr {
      nak_pct == 0;
   }

   // var: bad_crc_pct
   // Percentage of time that BAD CRC should be sent
   rand int unsigned bad_crc_pct;

   // constraint: L0_bad_crc_pct_cnstr
   // Keep between 0 and 100
   constraint L0_bad_crc_pct_cnstr {
      bad_crc_pct inside {[0:100]};
   }

   // constraint: L1_bad_crc_pct_cnstr
   // Keep it small
   constraint L1_bad_crc_pct_cnstr {
      bad_crc_pct inside {[0:10]};
   }

   // constraint: L2_bad_crc_pct_cnstr
   // Turn it off
   constraint L2_bad_crc_pct_cnstr {
      bad_crc_pct == 0;
   }

   //----------------------------------------------------------------------------------------
   // Group: Methods
   function new(string name="[name]");
      super.new(name);
      if(coverage_enable)
         cg = new();
   endfunction : new

   ////////////////////////////////////////////
   // func: sample_cg
   // Sample the covergroup if functional coverage is enabled
   virtual function void sample_cg();
      if(cg)
         cg.sample();
   endfunction : sample_cg

   //----------------------------------------------------------------------------------------
   // Group: Functional Coverage

   // prop: cg
   // Covergroup for configuration options
   covergroup cg;
      coverpoint nak_pct {
         bins disabled = {0};
         bins enabled  = {[1:100]};
      }
      coverpoint bad_crc_pct {
         bins disabled = {0};
         bins enabled  = {[1:100]};
      }
   endgroup : cg

endclass : cfg_c

`endif // __HAWK_CFG_SV__

