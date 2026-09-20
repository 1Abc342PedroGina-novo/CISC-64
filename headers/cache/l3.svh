// ============================================================================
// File: headers/cache/l3.svh
// Project: x86_64 Hardware Architecture Implementation
// Author: Pedro Emanuel
// License: GPL-3.0-only
//
// Description: Package, interface, and module declaration for the Shared L3 Cache (LLC - Last Level Cache).
// ============================================================================

`ifndef CACHE_L3_SVH
`define CACHE_L3_SVH

package cache_l3_pkg;

    localparam int PHYS_ADDR_WIDTH = 52;

    typedef struct packed {
        logic         hit;
        logic         miss;
        logic [511:0] line_data;
        logic [3:0]   owning_core_id;
    } l3_resp_t;

endpackage : cache_l3_pkg


interface cache_l3_if (
    input logic clk,
    input logic rst_n
);
    import cache_l3_pkg::*;

    logic                     req_valid;
    logic [PHYS_ADDR_WIDTH-1:0] paddr;
    logic [3:0]               requestor_core_id;
    l3_resp_t                 resp;

    modport L3Cache (
        input  clk, rst_n, req_valid, paddr, requestor_core_id,
        output resp
    );

    modport Interconnect (
        input  clk, rst_n, resp,
        output req_valid, paddr, requestor_core_id
    );

    modport Monitor (
        input clk, rst_n, req_valid, paddr, requestor_core_id, resp
    );
endinterface : cache_l3_if


module cache_l3_unit (
    input  logic                        clk,
    input  logic                        rst_n,
    input  logic                        req_valid,
    input  logic [51:0]                 paddr,
    input  logic [3:0]                  requestor_core_id,
    output cache_l3_pkg::l3_resp_t      resp
);
endmodule : cache_l3_unit

`endif // CACHE_L3_SVH
