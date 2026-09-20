// ============================================================================
// File: headers/mmu/ram.svh
// Project: x86_64 Hardware Architecture Implementation
// Author: Pedro Emanuel
// License: GPL-3.0-only
//
// Description: Package, interface, and module for physical RAM access
//              control (Physical Memory Interface) (Intel 64 / AMD64).
// ============================================================================

`ifndef MMU_RAM_SVH
`define MMU_RAM_SVH

package mmu_ram_pkg;

    localparam int PHYS_ADDR_WIDTH = 52;

    typedef enum logic [1:0] {
        RAM_OP_IDLE  = 2'b00,
        RAM_OP_READ  = 2'b01,
        RAM_OP_WRITE = 2'b10
    } ram_op_e;

    typedef struct packed {
        logic         ready;
        logic [64:0]  rdata; // Exemplo de barramento de dados base de 64 bits + paridade
        logic         ecc_error;
    } ram_response_t;

endpackage : mmu_ram_pkg


interface mmu_ram_if (
    input logic clk,
    input logic rst_n
);
    import mmu_ram_pkg::*;

    logic                     req_valid;
    ram_op_e                  req_op;
    logic [PHYS_ADDR_WIDTH-1:0] paddr;
    logic [63:0]              wdata;
    ram_response_t            response;

    modport RAMUnit (
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
endinterface : mmu_ram_if


module mmu_ram_controller (
    input  logic                           clk,
    input  logic                           rst_n,
    input  logic                           req_valid,
    input  mmu_ram_pkg::ram_op_e           req_op,
    input  logic [51:0]                    paddr,
    input  logic [63:0]                    wdata,
    output mmu_ram_pkg::ram_response_t     response
);
endmodule : mmu_ram_controller

`endif // MMU_RAM_SVH
