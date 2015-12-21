// ***********************************************************************
// File:   global_pkg.sv
// Author: bhunter
/* About:  Global Package
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


`include "uvm_macros.svh"
`include "cmn_macros.sv"
`include "global_macros.sv"

package global_pkg;

   //--------------------------------------------------------------------------
   // Group: Imports
   import uvm_pkg::*;

   //--------------------------------------------------------------------------
   // Group: Includes
`include "global_heartbeat_mon.sv"
`include "global_watchdog.sv"
`include "global_env.sv"

endpackage : global_pkg


