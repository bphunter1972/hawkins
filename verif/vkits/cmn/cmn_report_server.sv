
// ***********************************************************************
// File:   cmn_report_server.sv
// Author: bhunter
/* About:  Basic test extends the base test and starts a training sequence
           on both the RX and TX agent. This is done here to show that
           numerous sequences can be started independently on a chaining
           sequencer.
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

`ifndef __CMN_REPORT_SERVER_SV__
   `define __CMN_REPORT_SERVER_SV__

`ifdef UVM_MAJOR_VERSION_1_1
   `include "cmn_report_server_1_1.sv"
`endif // UVM_MAJOR_VERSION_1_1

`ifdef UVM_MAJOR_VERSION_1_2
   `include "cmn_report_server_1_2.sv"
`endif // UVM_MAJOR_VERSION_1_2

`endif // __CMN_REPORT_SERVER_SV__
