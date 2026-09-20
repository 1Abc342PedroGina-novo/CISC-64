// ============================================================================
// File: headers/mmu/alloc.svh
// Project: x86_64 Hardware Architecture Implementation
// Author: Pedro Emanuel
// License: GPL-3.0-only
//
// Description: Package, interface, and module for the physical page allocation unit
//              (Physical Page Allocator) within the MMU ecosystem (Intel 64 / AMD64).
// ============================================================================

`ifndef MMU_ALLOC_SVH
`define MMU_ALLOC_SVH

package mmu_alloc_pkg;

    localparam int PHYS_ADDR_WIDTH = 52;
    localparam int PAGE_SIZE_4K    = 4096;

    typedef enum logic [1:0] {
        ALLOC_OP_IDLE     = 2'b00,
        ALLOC_OP_REQ_PAGE = 2'b01,
        ALLOC_OP_FREE_PAGE= 2'b10
    } alloc_op_e;

    typedef struct packed {
        logic                    success;
        logic [PHYS_ADDR_WIDTH-1:12] page_frame_num;
        logic                    out_of_memory;
    } alloc_status_t;

endpackage : mmu_alloc_pkg


interface mmu_alloc_if (
    input logic clk,
    input logic rst_n
);
    import mmu_alloc_pkg::*;

    logic                     req_valid;
    alloc_op_e                req_op;
    logic [PHYS_ADDR_WIDTH-1:12] req_pfn;
    alloc_status_t            status;

    modport Allocator (
        input  clk, rst_n, req_valid, req_op, req_pfn,
        output status
    );

    modport Controller (
        input  clk, rst_n, status,
        output req_valid, req_op, req_pfn
    );

    modport Monitor (
        input clk, rst_n, req_valid, req_op, req_pfn, status
    );
endinterface : mmu_alloc_if


module mmu_allocator (
    input  logic                            clk,
    input  logic                            rst_n,
    input  logic                            req_valid,
    input  mmu_alloc_pkg::alloc_op_e        req_op,
    input  logic [51:12]                    req_pfn,
    output mmu_alloc_pkg::alloc_status_t    status
);
endmodule : mmu_allocator

`endif // MMU_ALLOC_SVH
