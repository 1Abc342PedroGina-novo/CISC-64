// ============================================================================
// File: headers/cache/l4.svh
// Project: x86_64 Hardware Architecture Implementation
// Author: Pedro Emanuel
// License: GPL-3.0-only
//
// Description: Package, interface, and module for off-chip/eDRAM/High Bandwidth Memory (HBM) L4 cache.
// ============================================================================

`ifndef CACHE_L4_SVH
`define CACHE_L4_SVH

package cache_l4_pkg;

    localparam int PHYS_ADDR_WIDTH = 52;

    typedef struct packed {
        logic         hit;
        logic         miss;
        logic [511:0] line_data;
        logic         hbm_ready;
    } l4_resp_t;

endpackage : cache_l4_pkg


interface cache_l4_if (
    input logic clk,
    input logic rst_n
);
    import cache_l4_pkg::*;

    logic                     req_valid;
    logic [PHYS_ADDR_WIDTH-1:0] paddr;
    l4_resp_t                 resp;

    modport L4Cache (
        input  clk, rst_n, req_valid, paddr,
        output resp
    );

    modport SystemBus (
        input  clk, rst_n, resp,
        output req_valid, paddr
    );

    modport Monitor (
        input clk, rst_n, req_valid, paddr, resp
    );
endinterface : cache_l4_if


module cache_l4_unit (
    input  logic                        clk,
    input  logic                        rst_n,
    input  logic                        req_valid,
    input  logic [51:0]                 paddr,
    output cache_l4_pkg::l4_resp_t      resp
);
endmodule : cache_l4_unit

`endif // CACHE_L4_SVH
