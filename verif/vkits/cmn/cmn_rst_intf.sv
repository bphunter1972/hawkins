
// ***********************************************************************
// File:   cmn_rst_intf.sv
// Author: bhunter
/* About:  Common Reset Interface
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


`ifndef __CMN_RST_INTF_SV__
   `define __CMN_RST_INTF_SV__

// class: cmn_rst_intf
interface cmn_rst_intf(input logic clk);

   //----------------------------------------------------------------------------------------
   // Group: Signals

   logic rst_n;

   //----------------------------------------------------------------------------------------
   // Group: Clocking blocks
   clocking cb @(posedge clk);
      output     rst_n;
   endclocking : cb

endinterface : cmn_rst_intf

`endif // __CMN_RST_INTF_SV__
