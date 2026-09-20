// ============================================================================
// File: headers/cache/cc.svh
// Project: x86_64 Hardware Architecture Implementation
// Author: Pedro Emanuel
// License: GPL-3.0-only
//
// Description: Package, interface, and module for the Cache Coherence
//              Controller (MESI/MOESI) within the x86_64 memory ecosystem.
// ============================================================================
`ifndef CACHE_CC_SVH
`define CACHE_CC_SVH

package cache_cc_pkg;

    localparam int PHYS_ADDR_WIDTH = 52;

    // Estados do Protocolo MOESI
    typedef enum logic [2:0] {
        MESI_INVALID   = 3'b000, // I
        MESI_SHARED    = 3'b001, // S
        MESI_EXCLUSIVE = 3'b010, // E
        MESI_MODIFIED  = 3'b011, // M
        MESI_OWNED     = 3 meb100  // O
    } cc_state_e;

    // Comandos de Snooping e Coerência no Barramento
    typedef enum logic [2:0] {
        CC_REQ_NOP      = 3'b000,
        CC_REQ_READ_SHR = 3'b001, // Read Shared (BusRd)
        CC_REQ_READ_OWN = 3'b010, // Read Invalidate (BusRdX)
        CC_REQ_UPGRADE  = 3'b011, // Upgrade (BusUpgr)
        CC_REQ_FLUSH    = 3'b100  // Flush to RAM
    } cc_bus_cmd_e;

    typedef struct packed {
        logic                    hit;
        cc_state_e               current_state;
        logic                    snoop_hit;
        logic                    data_forward;
    } cc_status_t;

endpackage : cache_cc_pkg


interface cache_cc_if (
    input logic clk,
    input logic rst_n
);
    import cache_cc_pkg::*;

    logic                     req_valid;
    cc_bus_cmd_e              bus_cmd;
    logic [PHYS_ADDR_WIDTH-1:6] line_paddr; // Endereço alinhado à linha de cache (64B)
    cc_status_t               status;

    modport CCUnit (
        input  clk, rst_n, req_valid, bus_cmd, line_paddr,
        output status
    );

    modport CacheController (
        input  clk, rst_n, status,
        output req_valid, bus_cmd, line_paddr
    );

    modport Monitor (
        input clk, rst_n, req_valid, bus_cmd, line_paddr, status
    );
endinterface : cache_cc_if


module cache_cc_controller (
    input  logic                            clk,
    input  logic                            rst_n,
    input  logic                            req_valid,
    input  cache_cc_pkg::cc_bus_cmd_e       bus_cmd,
    input  logic [51:6]                     line_paddr,
    output cache_cc_pkg::cc_status_t        status
);
endmodule : cache_cc_controller

`endif // CACHE_CC_SVH
