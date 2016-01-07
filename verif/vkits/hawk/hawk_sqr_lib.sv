
// ***********************************************************************
// File:   hawk_sqr_lib.sv
// Author: bhunter
/* About:  Contains types of chained sequencers used by the hawkins
           package.

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

`ifndef __HAWK_SQR_LIB_SV__
   `define __HAWK_SQR_LIB_SV__

typedef class link_item_c;
typedef class phy_item_c;
typedef class trans_item_c;
typedef class os_item_c;
typedef class cfg_c;

//****************************************************************************************
// class: phy_csqr_c
// A chaining sequencer that operates at the PHY level
class phy_csqr_c extends cmn_pkg::csqr_c#(link_item_c, link_item_c,
                                         phy_item_c, phy_item_c);
   `uvm_component_utils(hawk_pkg::phy_csqr_c)

   //----------------------------------------------------------------------------------------
   // Group: Methods
   function new(string name="phy_csqr",
                uvm_component parent=null);
      super.new(name, parent);
   endfunction : new
endclass : phy_csqr_c

//****************************************************************************************
// class: link_csqr_c
// A chaining sequencer that operates at the LINK level
class link_csqr_c extends cmn_pkg::csqr_c#(trans_item_c, trans_item_c,
                                          link_item_c, link_item_c);
   `uvm_component_utils_begin(hawk_pkg::link_csqr_c)
      `uvm_field_object(cfg, UVM_DEFAULT)
   `uvm_component_utils_end

   //----------------------------------------------------------------------------------------
   // Group: Fields

   // var: cfg
   // The cfg class
   cfg_c cfg;

   //----------------------------------------------------------------------------------------
   // Group: Methods
   function new(string name="link_csqr",
                uvm_component parent=null);
      super.new(name, parent);
   endfunction : new

   ////////////////////////////////////////////
   // func: down_traffic_user_task
   // When the PHY level is disabled, a random delay between 5 and 30ns is added to
   // simulate phy-level activity
   virtual task down_traffic_user_task(ref DOWN_TRAFFIC _down_traffic);
      int unsigned delay_ns;
      std::randomize(delay_ns) with { delay_ns inside {[5:30]}; };
      #(delay_ns * 1ns);
   endtask : down_traffic_user_task
endclass : link_csqr_c

//****************************************************************************************
// class: trans_csqr_c
// A chaining sequencer that operates at the TRANS level
class trans_csqr_c extends cmn_pkg::csqr_c#(os_item_c, os_item_c,
                                         trans_item_c, trans_item_c);
   `uvm_component_utils(hawk_pkg::trans_csqr_c)

   //----------------------------------------------------------------------------------------
   // Group: Methods
   function new(string name="trans_csqr",
                uvm_component parent=null);
      super.new(name, parent);
   endfunction : new
endclass : trans_csqr_c

//****************************************************************************************
// class: os_sqr_c
// A chaining sequencer that operates at the OS level
class os_sqr_c extends uvm_sequencer#(os_item_c, os_item_c);
   `uvm_component_utils(hawk_pkg::os_sqr_c)

   //----------------------------------------------------------------------------------------
   // Group: Methods
   function new(string name="os_vsqr",
                uvm_component parent=null);
      super.new(name, parent);
   endfunction : new
endclass : os_sqr_c

`endif // __HAWK_SQR_LIB_SV__

