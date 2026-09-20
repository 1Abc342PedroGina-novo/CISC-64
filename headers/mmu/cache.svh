// ============================================================================
// File: headers/mmu/cache.svh
// Project: x86_64 Hardware Architecture Implementation
// Author: Pedro Emanuel
// License: GPL-3.0-only
//
// Description: Package, interface, and module for controlling and interfacing
//              with the L1/L2 cache subsystem associated with the MMU (Intel 64 / AMD64).
// ============================================================================

`ifndef MMU_CACHE_SVH
`define MMU_CACHE_SVH

package mmu_cache_pkg;

    localparam int CACHE_LINE_SIZE = 64; // Bytes
    localparam int PHYS_ADDR_WIDTH = 52;

    typedef enum logic [1:0] {
        CACHE_READ  = 2'b00,
        CACHE_WRITE = 2'b01,
        CACHE_INVAL = 2'b10,
        CACHE_FLUSH = 2'b11
    } cache_op_e;

    typedef struct packed {
        logic         hit;
        logic         miss;
        logic         dirty;
        logic [511:0] data_line;
    } cache_response_t;

endpackage : mmu_cache_pkg


interface mmu_cache_if (
    input logic clk,
    input logic rst_n
);
    import mmu_cache_pkg::*;

    logic                     req_valid;
    cache_op_e                req_op;
    logic [PHYS_ADDR_WIDTH-1:0] paddr;
    logic [511:0]             wdata;
    cache_response_t          response;

    modport CacheUnit (
        input  clk, rst_n, req_valid, req_op, paddr, wdata,
        output response
    );

    modport MMU (
        input  clk, rst_n, response,
        output req_valid, req_op, paddr, wdata
    );

    modport Monitor (
        input clk, rst_n, req_valid, req_op, paddr, wdata, response
    );
endinterface : mmu_cache_if


module mmu_cache_controller (
    input  logic                             clk,
    input  logic                             rst_n,
    input  logic                             req_valid,
    input  mmu_cache_pkg::cache_op_e         req_op,
    input  logic [51:0]                      paddr,
    input  logic [511:0]                     wdata,
    output mmu_cache_pkg::cache_response_t   response
);
endmodule : mmu_cache_controller

`endif // MMU_CACHE_SVH
