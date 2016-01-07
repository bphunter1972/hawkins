// ***********************************************************************
// File:   hawk_pkg.sv
// Author: bhunter
/* About:  hawk package
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

// package: hawk_pkg
package hawk_pkg;

   //----------------------------------------------------------------------------------------
   // Group: Imports
   import uvm_pkg::*;

   //----------------------------------------------------------------------------------------
   // Group: Includes

   `include "hawk_agent.sv"
   `include "hawk_cfg.sv"
   `include "hawk_drv.sv"
   `include "hawk_env.sv"
   `include "hawk_link_cseq.sv"
   `include "hawk_link_item.sv"
   `include "hawk_mem.sv"
   `include "hawk_mon.sv"
   `include "hawk_os_mem_seq.sv"
   `include "hawk_os_seq_lib.sv"
   `include "hawk_os_sqr.sv"
   `include "hawk_phy_cseq.sv"
   `include "hawk_phy_item.sv"
   `include "hawk_phy_trn_seq.sv"
   `include "hawk_csqr_lib.sv"
   `include "hawk_trans_cseq.sv"
   `include "hawk_trans_item.sv"
   `include "hawk_types.sv"

endpackage : hawk_pkg


