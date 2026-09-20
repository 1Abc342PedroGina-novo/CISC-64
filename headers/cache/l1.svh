// ============================================================================
// File: headers/cache/l1.svh
// Project: x86_64 Hardware Architecture Implementation
// Author: Pedro Emanuel
// License: GPL-3.0-only
//
// Description: Package, interface, and module for L1 Cache unification (ICache + DCache).
// ============================================================================
`ifndef CACHE_L1_SVH
`define CACHE_L1_SVH

package cache_l1_pkg;

    localparam int PHYS_ADDR_WIDTH = 52;

    typedef struct packed {
        logic icache_hit;
        logic dcache_hit;
        logic l1_stall;
    } l1_status_t;

endpackage : cache_l1_pkg


interface cache_l1_if (
    input logic clk,
    input logic rst_n
);
    import cache_l1_pkg::*;

    logic                     icache_req;
    logic [PHYS_ADDR_WIDTH-1:0] icache_paddr;
    logic                     dcache_req;
    logic [PHYS_ADDR_WIDTH-1:0] dcache_paddr;
    l1_status_t               status;

    modport L1Controller (
        input  clk, rst_n, icache_req, icache_paddr, dcache_req, dcache_paddr,
        output status
    );

    modport Pipeline (
        input  clk, rst_n, status,
        output icache_req, icache_paddr, dcache_req, dcache_paddr
    );

    modport Monitor (
        input clk, rst_n, icache_req, icache_paddr, dcache_req, dcache_paddr, status
    );
endinterface : cache_l1_if


module cache_l1_controller (
    input  logic                     clk,
    input  logic                     rst_n,
    input  logic                     icache_req,
    input  logic [51:0]              icache_paddr,
    input  logic                     dcache_req,
    input  logic [51:0]              dcache_paddr,
    output cache_l1_pkg::l1_status_t status
);
endmodule : cache_l1_controller

`endif // CACHE_L1_SVH
