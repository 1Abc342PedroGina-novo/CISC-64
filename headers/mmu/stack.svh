// ============================================================================
// File: headers/mmu/stack.svh
// Project: x86_64 Hardware Architecture Implementation
// Author: Pedro Emanuel
// License: GPL-3.0-only
//
// Description: Package, interface, and module for bounds validation and
//              protection of the execution stack (Stack Limit / RSP Validation / Shadow Stack).
// ============================================================================

`ifndef MMU_STACK_SVH
`define MMU_STACK_SVH

package mmu_stack_pkg;

    localparam int VIRT_ADDR_WIDTH = 48;

    typedef struct packed {
        logic [VIRT_ADDR_WIDTH-1:0] stack_base;
        logic [VIRT_ADDR_WIDTH-1:0] stack_limit;
    } stack_bounds_t;

    typedef struct packed {
        logic stack_overflow;
        logic stack_underflow;
        logic page_fault_trigger;
    } stack_status_t;

endpackage : mmu_stack_pkg


interface mmu_stack_if (
    input logic clk,
    input logic rst_n
);
    import mmu_stack_pkg::*;

    logic [VIRT_ADDR_WIDTH-1:0] rsp_val;
    stack_bounds_t              bounds;
    stack_status_t              status;

    modport StackChecker (
        input  clk, rst_n, rsp_val, bounds,
        output status
    );

    modport Core (
        input  clk, rst_n, status,
        output rsp_val, bounds
    );

    modport Monitor (
        input clk, rst_n, rsp_val, bounds, status
    );
endinterface : mmu_stack_if


module mmu_stack_checker (
    input  logic                            clk,
    input  logic                            rst_n,
    input  logic [47:0]                     rsp_val,
    input  mmu_stack_pkg::stack_bounds_t    bounds,
    output mmu_stack_pkg::stack_status_t    status
);
endmodule : mmu_stack_checker

`endif // MMU_STACK_SVH
