
// ***********************************************************************
// File:   base_test.sv
// Author: bhunter
/* About:  Base test for hawkins testbench.
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

`ifndef __BASE_TEST_SV__
   `define __BASE_TEST_SV__

// class: base_test_c
class base_test_c extends uvm_test;
   `uvm_component_utils_begin(base_test_c)
      `uvm_field_object(cfg, UVM_DEFAULT)
   `uvm_component_utils_end

   //----------------------------------------------------------------------------------------
   // Group: Configuration Fields

   // var: cfg
   // The hawk cfg class
   rand hawk_pkg::cfg_c cfg;

   //----------------------------------------------------------------------------------------
   // Group: Fields

   // var: hawk_env
   // The Hawk Environment creates an RX and TX agent
   hawk_pkg::env_c hawk_env;

   // var: tb_clk_drv
   // The hawk clock driver
   cmn_pkg::clk_drv_c tb_clk_drv;

   // var: tb_rst_drv
   // The hawk reset driver
   cmn_pkg::rst_drv_c tb_rst_drv;

   //----------------------------------------------------------------------------------------
   // Group: Methods
   function new(string name="hawk",
                uvm_component parent=null);
      super.new(name, parent);
   endfunction : new

   ////////////////////////////////////////////
   // func: build_phase
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      // Create the global environment
      global_pkg::env = global_pkg::env_c::type_id::create("global_env", this);

      // create the random configurations
      cfg = hawk_pkg::cfg_c::type_id::create("cfg");

      // This hawk has no reg_block

      // randomize the cfg and CSR fields
      randomize_cfg();

      // create hawkins environment and pass the now-randomized cfg object
      hawk_env = hawk_pkg::env_c::type_id::create("hawk_env", this);
      uvm_config_db#(uvm_object)::set(this, "hawk_env", "cfg", cfg);

      // Not randomized by default.  Derived tests can randomize in end_of_elaboration_phase.
      // Create the clock driver
      uvm_config_db#(string)::set(this, "tb_clk_drv", "intf_name", "tb_clk_vi");
      uvm_config_db#(int)::set(this, "tb_clk_drv", "period_ps", 2000);
      tb_clk_drv = cmn_pkg::clk_drv_c::type_id::create("tb_clk_drv", this);

      // Create the reset driver
      uvm_config_db#(string)::set(this,"tb_rst_drv", "intf_name", "tb_rst_vi");
      uvm_config_db#(int)::set(this, "tb_rst_drv", "reset_time_ps", 20000);
      tb_rst_drv = cmn_pkg::rst_drv_c::type_id::create("tb_rst_drv", this);

      uvm_config_db#(string)::set(this, "hawk_env.tx_agent.drv", "intf_name", "hawk_tx_vi");
      uvm_config_db#(string)::set(this, "hawk_env.tx_agent.mon", "intf_name", "hawk_rx_vi");
      uvm_config_db#(string)::set(this, "hawk_env.rx_agent.drv", "intf_name", "hawk_rx_vi");
      uvm_config_db#(string)::set(this, "hawk_env.rx_agent.mon", "intf_name", "hawk_tx_vi");

      uvm_config_db#(uvm_object_wrapper)::set(this, "hawk_env.*_agent.os_sqr.main_phase", "default_sequence", hawk_pkg::os_main_seq_c::type_id::get());

      // set up chaining sequences
      uvm_config_db#(uvm_object_wrapper)::set(this, "hawk_env.*_agent.phy_csqr.run_phase", "default_sequence", hawk_pkg::phy_cseq_c::type_id::get());
      uvm_config_db#(uvm_object_wrapper)::set(this, "hawk_env.*_agent.link_csqr.run_phase", "default_sequence", hawk_pkg::link_cseq_c::type_id::get());
      uvm_config_db#(uvm_object_wrapper)::set(this, "hawk_env.*_agent.trans_csqr.run_phase", "default_sequence", hawk_pkg::trans_cseq_c::type_id::get());
   endfunction : build_phase

   ////////////////////////////////////////////
   // func: connect_phase
   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      global_pkg::env.set_stats_clk(tb_clk_drv);
   endfunction : connect_phase

   ////////////////////////////////////////////
   // func: run_phase
   // Launch training sequence on PHY csqr of RX & TX agents
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

   ////////////////////////////////////////////
   // func: randomize_cfg
   // Descendent test classes can override this method to disable constraints, etc.
   virtual function void randomize_cfg();
      assert(randomize()) else
         `cmn_fatal(("Unable to randomize hawk"))
      cfg.sample_cg();
   endfunction : randomize_cfg
endclass : base_test_c

`endif // __BASE_TEST_SV__

