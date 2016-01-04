
// ***********************************************************************
// File:   cmn_clk_intf.sv
// Author: bhunter
/* About:  Common Clock Interface
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


`ifndef __CMN_CLK_INTF_SV__
   `define __CMN_CLK_INTF_SV__

// class: cmn_clk_intf
// A simple interface holding the clock wire, and it's ideal clock
interface cmn_clk_intf();

   //----------------------------------------------------------------------------------------
   // Group: Signals
   logic clk;

endinterface : cmn_clk_intf

`endif // __CMN_CLK_INTF_SV__
