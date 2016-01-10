
// ***********************************************************************
// File:   basic.sv
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

`ifndef __BASIC_SV__
   `define __BASIC_SV__

   `include "base_test.sv"

// class: basic_test_c
class basic_test_c extends base_test_c;
   `uvm_component_utils_begin(basic_test_c)
   `uvm_component_utils_end

   //----------------------------------------------------------------------------------------
   // Group: Methods
   function new(string name="<name>",
                uvm_component parent=null);
      super.new(name, parent);
   endfunction : new
endclass : basic_test_c

`endif // __BASIC_SV__

