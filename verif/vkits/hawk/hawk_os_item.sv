
// ***********************************************************************
// File:   hawk_os_item.sv
// Author: bhunter
/* About:  The Operating System level items that go into the transaction level
           These describe either a read or a write. They are intentionally
           generic.
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

`ifndef __HAWK_OS_ITEM_SV__
   `define __HAWK_OS_ITEM_SV__

// class: os_item_c
class os_item_c extends uvm_sequence_item;
   `uvm_object_utils_begin(hawk_pkg::os_item_c)
   `uvm_object_utils_end

   //----------------------------------------------------------------------------------------
   // Group: Fields

   // var: uid
   // Unique ID
   cmn_pkg::uid_c uid;

   // var: access
   // The command is either a read or a write
   rand uvm_access_e access;

   // constraint: access_cnstr
   // Set to read or write. No bursts.
   constraint access_cnstr {
      access inside {UVM_READ, UVM_WRITE};
   }

   // var: addr
   // The 64-bit address
   rand addr_t addr;

   // var: data
   // 64-bit data
   rand data_t data;

   //----------------------------------------------------------------------------------------
   // Group: Methods
   function new(string name="os");
      super.new(name);
      uid = new("OS");
   endfunction : new

   ////////////////////////////////////////////
   // func: convert2string
   // Single-line printing
   virtual function string convert2string();
      convert2string = $sformatf("%s %s ADDR:%016X DATA:%016X", uid.convert2string(), access.name(), addr, data);
   endfunction : convert2string

endclass : os_item_c

`endif // __HAWK_OS_ITEM_SV__


