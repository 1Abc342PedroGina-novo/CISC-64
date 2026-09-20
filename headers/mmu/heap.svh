// ============================================================================
// File: headers/mmu/heap.svh
// Project: x86_64 Hardware Architecture Implementation
// Author: Pedro Emanuel
// License: GPL-3.0-only
//
// Description: Package, interface, and module for bounds checking and
//              memory heap management within the MMU context.
// ============================================================================

`ifndef MMU_HEAP_SVH
`define MMU_HEAP_SVH

package mmu_heap_pkg;

    localparam int VIRT_ADDR_WIDTH = 48;

    typedef struct packed {
        logic [VIRT_ADDR_WIDTH-1:0] heap_start;
        logic [VIRT_ADDR_WIDTH-1:0] heap_break;
        logic [VIRT_ADDR_WIDTH-1:0] heap_max;
    } heap_bounds_t;

    typedef struct packed {
        logic in_bounds;
        logic heap_overflow;
    } heap_status_t;

endpackage : mmu_heap_pkg


interface mmu_heap_if (
    input logic clk,
    input logic rst_n
);
    import mmu_heap_pkg::*;

    logic [VIRT_ADDR_WIDTH-1:0] vaddr;
    heap_bounds_t               bounds;
    heap_status_t               status;

    modport HeapChecker (
        input  clk, rst_n, vaddr, bounds,
        output status
    );

    modport Controller (
        input  clk, rst_n, status,
        output vaddr, bounds
    );

    modport Monitor (
        input clk, rst_n, vaddr, bounds, status
    );
endinterface : mmu_heap_if


module mmu_heap_checker (
    input  logic                            clk,
    input  logic                            rst_n,
    input  logic [47:0]                     vaddr,
    input  mmu_heap_pkg::heap_bounds_t      bounds,
    output mmu_heap_pkg::heap_status_t      status
);
endmodule : mmu_heap_checker

`endif // MMU_HEAP_SVH
