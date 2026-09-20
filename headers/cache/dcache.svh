// ============================================================================
// File: headers/cache/dcache.svh
// Project: x86_64 Hardware Architecture Implementation
// Author: Pedro Emanuel
// License: GPL-3.0-only
//
// Description: Package, interface, and module for the high-speed L1 Data Cache
//              (DCache) directly connected to the execution/load-store pipeline.
// ============================================================================

`ifndef CACHE_DCACHE_SVH
`define CACHE_DCACHE_SVH

package cache_dcache_pkg;

    localparam int PHYS_ADDR_WIDTH = 52;
    localparam int DCACHE_LINE_BYTES = 64;

    typedef enum logic [1:0] {
        DCACHE_OP_READ  = 2'b00,
        DCACHE_OP_WRITE = 2'b01,
        DCACHE_OP_FLUSH = 2'b10,
        DCACHE_OP_INVAL = 2'b11
    } dcache_op_e;

    typedef struct packed {
        logic         hit;
        logic         miss;
        logic [511:0] rdata;
        logic         store_buffer_full;
    } dcache_resp_t;

endpackage : cache_dcache_pkg


interface cache_dcache_if (
    input logic clk,
    input logic rst_n
);
    import cache_dcache_pkg::*;

    logic                     req_valid;
    dcache_op_e               req_op;
    logic [PHYS_ADDR_WIDTH-1:0] paddr;
    logic [511:0]             wdata;
    logic [63:0]              wstrb;
    dcache_resp_t             resp;

    modport DCache (
        input  clk, rst_n, req_valid, req_op, paddr, wdata, wstrb,
        output resp
    );

    modport LoadStoreUnit (
        input  clk, rst_n, resp,
        output req_valid, req_op, paddr, wdata, wstrb
    );

    modport Monitor (
        input clk, rst_n, req_valid, req_op, paddr, wdata, wstrb, resp
    );
endinterface : cache_dcache_if


module cache_dcache_unit (
    input  logic                            clk,
    input  logic                            rst_n,
    input  logic                            req_valid,
    input  cache_dcache_pkg::dcache_op_e    req_op,
    input  logic [51:0]                     paddr,
    input  logic [511:0]                    wdata,
    input  logic [63:0]                     wstrb,
    output cache_dcache_pkg::dcache_resp_t  resp
);
endmodule : cache_dcache_unit

`endif // CACHE_DCACHE_SVH
