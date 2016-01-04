
// ***********************************************************************
// File:   hawk_phy_item.sv
// Author: bhunter
/* About:  Delivered directly to the driver from the PHY chaining sequence
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

`ifndef __HAWK_PHY_ITEM_SV__
   `define __HAWK_PHY_ITEM_SV__

`include "hawk_types.sv"

// class: phy_item_c
class phy_item_c extends uvm_sequence_item;
   `uvm_object_utils_begin(hawk_pkg::phy_item_c)
      `uvm_field_int(valid, UVM_DEFAULT)
      `uvm_field_int(data, UVM_DEFAULT | UVM_HEX)
   `uvm_object_utils_end

   //----------------------------------------------------------------------------------------
   // Group: Fields

   // var: uid
   // Unique Identifier
   cmn_pkg::uid_c uid;

   // var: valid
   // Valid signal
   rand bit valid;

   // var: data
   // Data signal
   rand byte unsigned data;

   // var: seed_item
   // When set, this bit indicates that the driver should use this
   // sequence's id info to re-route all responses
   bit seed_item=0;

   //----------------------------------------------------------------------------------------
   // Group: Methods
   function new(string name="phy");
      super.new(name);
      uid = new("PHY");
   endfunction : new

   ////////////////////////////////////////////
   // func: convert2string
   // Single-line printing
   virtual function string convert2string();
      convert2string = uid.convert2string();
      if(valid)
         convert2string = $sformatf("%s PKT D:%02X", convert2string, data);
      else if(data inside {ACK, NAK, TRN, EOP}) begin
         phy_char_e pchar = phy_char_e'(data);
         convert2string = {convert2string, " ", pchar.name()};
      end else
         convert2string = "IDLE";
   endfunction : convert2string

   ////////////////////////////////////////////
   // func: is_idle_or_trn
   // Returns 1 if this is either an IDLE or a training
   virtual function bit is_idle_or_trn();
      return(valid == 0 && !(data inside {ACK, NAK, EOP}));
   endfunction : is_idle_or_trn
endclass : phy_item_c

`endif // __HAWK_PHY_ITEM_SV__


