
// ***********************************************************************
// File:   hawk_phy_trn_seq.sv
// Author: bhunter
/* About:  Sends in training sequences every 2 us. Uses grab/ungrab
           because these run at the highest priority and must be
           consecutive.
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

`ifndef __HAWK_PHY_TRN_SEQ_SV__
   `define __HAWK_PHY_TRN_SEQ_SV__

`include "hawk_types.sv"
`include "hawk_phy_item.sv"

class phy_trn_seq_c extends uvm_sequence #(phy_item_c, phy_item_c);
   `uvm_object_utils(hawk_pkg::phy_trn_seq_c)

   //----------------------------------------------------------------------------------------
   // Group: Methods
   function new(string name="phy_trn_seq");
      super.new(name);
   endfunction : new

   ////////////////////////////////////////////
   // func: body
   virtual task body();
      phy_item_c trn_item;

      forever begin
         #(2us);
         grab();
         `cmn_info(("Sending Training Sequence"))
         repeat(4) begin
            `uvm_do_with(trn_item, {
               valid == 0;
               data == TRN;
            })
         end
         ungrab();
      end
   endtask : body
endclass : phy_trn_seq_c

`endif // __HAWK_PHY_TRN_SEQ_SV__

