
// ***********************************************************************
// File:   cmn_pkg.sv
// Author: bhunter
/* About:  Common package
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

`include "uvm_macros.svh"
`include "cmn_macros.sv"

// package: cmn_pkg
package cmn_pkg;

   //----------------------------------------------------------------------------------------
   // Imports
   import uvm_pkg::*;
   localparam UVM_COMPONENT = UVM_NOPACK | UVM_NOCOMPARE | UVM_NOCOPY;

   //----------------------------------------------------------------------------------------
   // Includes

`include "cmn_clk_drv.sv"
`include "cmn_cseq.sv"
`include "cmn_csqr.sv"
`include "cmn_msgs.sv"
`include "cmn_objection.sv"
`include "cmn_rand_delays.sv"
`include "cmn_report_server.sv"
`include "cmn_rst_drv.sv"
`include "cmn_uid.sv"

endpackage : cmn_pkg

