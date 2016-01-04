// ***********************************************************************
// File:   global_macros.sv
// Author: bhunter
/* About:  Global Macros
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

`ifndef __GLOBAL_MACROS_SV__
 `define __GLOBAL_MACROS_SV__

   `include "uvm_macros.svh"

   //----------------------------------------------------------------------------------------
   // Includes

   //----------------------------------------------------------------------------------------
   // Group: Macros

   ////////////////////////////////////////////
   // macro: global_heartbeat
   // Called by registered monitors to indicate that the DUT is still alive
   `define global_heartbeat(str) begin global_pkg::env.heartbeat_mon.raise(this, str, `uvm_file, `uvm_line); end

   ////////////////////////////////////////////
   // macro: global_add_to_heartbeat_mon
   // Called by components to register themselves with the heartbeat monitor
   // t : A time field that indicates what the drain time is for this component
   `define global_add_to_heartbeat_mon(t) begin global_pkg::env.heartbeat_mon.register(this, t); end

`endif // __GLOBAL_MACROS_SV__
