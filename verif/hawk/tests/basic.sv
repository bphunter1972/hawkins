
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

   ////////////////////////////////////////////
   // func: run_phase
   // Launch training sequence on PHY csqr of RX & TX agents Normally you
   // might simply put this launching in the phy_cseq,  however this example
   // is used to demonstrate that any sequence can run in parallel with the
   // chaining sequence
   virtual task run_phase(uvm_phase phase);
      hawk_pkg::phy_trn_seq_c rx_trn_seq, tx_trn_seq;
      super.run_phase(phase);

      rx_trn_seq = hawk_pkg::phy_trn_seq_c::type_id::create("rx_trn_seq");
      tx_trn_seq = hawk_pkg::phy_trn_seq_c::type_id::create("tx_trn_seq");
      fork
         rx_trn_seq.start(hawk_env.rx_agent.phy_csqr);
         tx_trn_seq.start(hawk_env.tx_agent.phy_csqr);
      join
   endtask : run_phase
endclass : basic_test_c

`endif // __BASIC_SV__

