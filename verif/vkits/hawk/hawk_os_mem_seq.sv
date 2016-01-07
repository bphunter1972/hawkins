//-*- mode: Verilog; verilog-indent-level: 3; indent-tabs-mode: nil; tab-width: 1 -*-
// vim: tabstop=3 expandtab shiftwidth=3 softtabstop=3

// **********************************************************************
// * CAVIUM CONFIDENTIAL AND PROPRIETARY NOTE
// *
// * This software contains information confidential and proprietary to
// * Cavium, Inc. It shall not be reproduced in whole or in part, or
// * transferred to other documents, or disclosed to third parties, or
// * used for any purpose other than that for which it was obtained,
// * without the prior written consent of Cavium, Inc.
// * Copyright 2016, Cavium, Inc.  All rights reserved.
// * (utg v1.3.2)
// ***********************************************************************
// File:   hawk_os_mem_seq.sv
// Author: bhunter
/* About:  Handles all memory reads, writes, and responses.
 *************************************************************************/

`ifndef __HAWK_OS_MEM_SEQ_SV__
   `define __HAWK_OS_MEM_SEQ_SV__

`include "hawk_os_item.sv"
`include "hawk_mem.sv"

typedef class os_sqr_c;

class os_mem_seq_c extends uvm_sequence #(os_item_c, os_item_c);
   `uvm_object_utils_begin(hawk_pkg::os_mem_seq_c)
   `uvm_object_utils_end
   `uvm_declare_p_sequencer(os_sqr_c)

   //----------------------------------------------------------------------------------------
   // Group: Fields

   // var: mem
   // The memory instance
   mem_c mem;

   //----------------------------------------------------------------------------------------
   // Group: Methods

   function new(string name="os_mem_seq");
      super.new(name);
   endfunction : new

   ////////////////////////////////////////////
   // func: body
   virtual task body();
      os_item_c rcvd_os_item;
      mem = p_sequencer.mem;

      forever begin
         p_sequencer.rcvd_os_item_fifo.get(rcvd_os_item);
         `cmn_dbg(200, ("RX: %s", rcvd_os_item.convert2string()))

         case(rcvd_os_item.cmd)
            WR  : begin
               mem.memory[rcvd_os_item.addr] = rcvd_os_item.data;
               `cmn_dbg(200, ("Wrote [%08X] = %016X", rcvd_os_item.addr, rcvd_os_item.data))
            end
            RD  : send_read_response(rcvd_os_item);
         endcase
      end
   endtask : body

   ////////////////////////////////////////////
   // func: send_read_response
   // Respond to a read
   virtual task send_read_response(os_item_c _read_request);
      os_item_c response_item;
      data_t rsp_data;

      if(!mem.memory.exists(_read_request.addr)) begin
         // return zeroes and emit a warning
         mem.memory[_read_request.addr] = 0;
         `cmn_warn(("Reading from uninitialized mem.memory location [%016X]", _read_request.addr))
      end

      rsp_data = mem.memory[_read_request.addr];

      `uvm_do_with(response_item, {
         cmd  == RESP;
         addr == _read_request.addr;  // this helps the transaction layer use the right tag
         data == rsp_data;
      })

      `cmn_dbg(200, ("Responding: %s", response_item.convert2string()))
   endtask : send_read_response

endclass : os_mem_seq_c

`endif // __HAWK_OS_MEM_SEQ_SV__

