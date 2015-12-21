
// ***********************************************************************
// File:   cmn_cseq.sv
// Author: bhunter
/* About:  Chaining Sequence Base Class
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

`ifndef __CMN_CSEQ_SV__
   `define __CMN_CSEQ_SV__

`include "cmn_csqr.sv"

class cseq_c#(type DOWN_REQ=uvm_sequence_item,
              DOWN_RSP=DOWN_REQ,
              UP_REQ=DOWN_REQ,
              UP_RSP=DOWN_REQ,
              CSQR=cmn_pkg::csqr_c)
              extends uvm_sequence#(DOWN_REQ, DOWN_RSP);

   `uvm_object_utils_begin(cmn_pkg::cseq_c)
   `uvm_object_utils_end
   `uvm_declare_p_sequencer(CSQR)

   //----------------------------------------------------------------------------------------
   // Group: Fields

   //----------------------------------------------------------------------------------------
   // Group: Methods
   function new(string name="cseq_seq");
      super.new(name);
   endfunction : new

   ////////////////////////////////////////////
   // func: body
   virtual task body();
      fork
         handle_up_items();
         handle_down_rsp();
      join
   endtask : body

   ////////////////////////////////////////////
   // func: handle_up_items
   // Get items from the upstream chained sequencer and send them as downstream items
   virtual task handle_up_items();
      UP_REQ up_req_item;
      DOWN_REQ down_req_item;

      forever begin
         p_sequencer.get_up_item(up_req_item);
         `uvm_create(down_req_item)
         make_down_req(down_req_item, up_req_item);
         `uvm_send(down_req_item)
      end
   endtask : handle_up_items

   ////////////////////////////////////////////
   // func: handle_down_rsp
   // Get responses from downstream and push them upstream
   virtual task handle_down_rsp();
      DOWN_RSP down_rsp_item;
      UP_RSP up_rsp_item;

      forever begin
         get_response(down_rsp_item);
         up_rsp_item = create_up_rsp(down_rsp_item);
         p_sequencer.put_up_response(up_rsp_item);
      end
   endtask : handle_down_rsp

   ////////////////////////////////////////////
   // func: make_down_req
   // make a downstream request from an upstream request item
   virtual function DOWN_REQ make_down_req(ref DOWN_REQ _down_req_item,
                                               UP_REQ _up_req_item);
   endfunction : make_down_req

   ////////////////////////////////////////////
   // func: create_up_rsp
   // Create an upstream response item from the downstream request
   virtual function UP_RSP create_up_rsp(ref DOWN_RSP _down_rsp_item);
   endfunction : create_up_rsp

endclass : cseq_c

`endif // __CMN_CSEQ_SV__

