// ============================================================================
// File: headers/cache/l2.svh
// Project: x86_64 Hardware Architecture Implementation
// Author: Pedro Emanuel
// License: GPL-3.0-only
//
// Description: Package, interface, and module for the Unified L2 Cache (Instruction/Data)
//              per core.
// ============================================================================

`ifndef CACHE_L2_SVH
`define CACHE_L2_SVH

package cache_l2_pkg;

    localparam int PHYS_ADDR_WIDTH = 52;

    typedef enum logic [1:0] {
        L2_READ  = 2'b00,
        L2_WRITE = 2'b01,
        L2_INVAL = 2'b10
    } l2_op_e;

    typedef struct packed {
        logic         hit;
        logic         miss;
        logic [511:0] line_data;
    } l2_resp_t;

endpackage : cache_l2_pkg


interface cache_l2_if (
    input logic clk,
    input logic rst_n
);
    import cache_l2_pkg::*;

    logic                     req_valid;
    l2_op_e                   req_op;
    logic [PHYS_ADDR_WIDTH-1:0] paddr;
    logic [511:0]             wdata;
    l2_resp_t                 resp;

    modport L2Cache (
        input  clk, rst_n, req_valid, req_op, paddr, wdata,
        output resp
    );

    modport L1Master (
        input  clk, rst_n, resp,
        output req_valid, req_op, paddr, wdata
    );

    modport Monitor (
        input clk, rst_n, req_valid, req_op, paddr, wdata, resp
    );
endinterface : cache_l2_if


module cache_l2_unit (
    input  logic                        clk,
    input  logic                        rst_n,
    input  logic                        req_valid,
    input  cache_l2_pkg::l2_op_e        req_op,
    input  logic [51:0]                 paddr,
    input  logic [511:0]                wdata,
    output cache_l2_pkg::l2_resp_t      resp
);
endmodule : cache_l2_unit

`endif // CACHE_L2_SVH
