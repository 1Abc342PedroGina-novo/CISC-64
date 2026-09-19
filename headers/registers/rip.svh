// ============================================================================
// File: headers/registers/rip.svh
// Project: x86_64 Hardware Architecture Implementation
// Author: Pedro Emanuel
// License: GPL-3.0-only
//
// Description: Declaration of packages, data types, structures, masks,
//              telemetry, interfaces, and module signature for the
//              Instruction Pointer (RIP) register (Intel 64 / AMD64 Architecture).
// ============================================================================

`ifndef __HEADERS_REGISTERS_RIP_SV__
`define __HEADERS_REGISTERS_RIP_SV__

package rip_pkg;

    // ------------------------------------------------------------------------
    // Mapeamento dos Modos de Acesso ao Registrador RIP
    // ------------------------------------------------------------------------
    typedef enum logic [1:0] {
        RIP_ACCESS_64BIT = 2'b00, // RIP : Acesso completo [63:0] (Long Mode)
        RIP_ACCESS_32BIT = 2'b01, // EIP : Acesso aos 32 bits inferiores [31:0] (Protected Mode / Compatibility Mode)
        RIP_ACCESS_16BIT = 2'b10  // IP  : Acesso aos 16 bits inferiores [15:0] (Real Mode / 16-bit)
    } rip_access_mode_e;

    // ------------------------------------------------------------------------
    // Máscaras de Bits para Operações de Atualização/Salto
    // ------------------------------------------------------------------------
    localparam logic [63:0] RIP_MASK_64BIT = 64'hFFFF_FFFF_FFFF_FFFF;
    localparam logic [63:0] RIP_MASK_32BIT = 64'h0000_0000_FFFF_FFFF;
    localparam logic [63:0] RIP_MASK_16BIT = 64'h0000_0000_0000_FFFF;

    // ------------------------------------------------------------------------
    // Estruturas de Decomposição do RIP (Layout x86_64)
    // ------------------------------------------------------------------------
    typedef struct packed {
        logic [31:0] high_dword; // Bits [63:32] - Ativo apenas em Long Mode (64-bit)
        logic [15:0] high_word;  // Bits [31:16] - Metade superior do EIP
        logic [15:0] ip;         // Bits [15:0]  - Endereço IP de 16 bits
    } rip_fields_t;

    // Mapeamento Byte a Byte para Depuração e Monitoramento do Pipeline
    typedef struct packed {
        logic [7:0] byte7; // Bits [63:56]
        logic [7:0] byte6; // Bits [55:48]
        logic [7:0] byte5; // Bits [47:40]
        logic [7:0] byte4; // Bits [39:32]
        logic [7:0] byte3; // Bits [31:24]
        logic [7:0] byte2; // Bits [23:16]
        logic [7:0] byte1; // Bits [15:8]
        logic [7:0] byte0; // Bits [7:0]
    } rip_byte_map_t;

    // União para Múltiplas Visões de Memória do Registrador RIP
    typedef union packed {
        logic [63:0]   rip;       // Visão 64 bits
        logic [31:0]   eip;       // Visão 32 bits
        logic [15:0]   ip;        // Visão 16 bits
        rip_fields_t   fields;    // Visão por subdivisões de arquitetura
        rip_byte_map_t bytes;     // Visão por bytes individuais
    } rip_reg_u;

    // ------------------------------------------------------------------------
    // Estrutura de Telemetria e Monitoramento de Estado do RIP
    // ------------------------------------------------------------------------
    typedef struct packed {
        logic        is_canonical; // Indica se o endereço no RIP está na forma canônica (x86_64 requirement)
        logic [63:0] value;        // Endereço de instrução atual
    } rip_status_t;

endpackage : rip_pkg


// ============================================================================
// Interface SystemVerilog para o Registrador RIP
// ============================================================================
interface rip_if (
    input logic clk,
    input logic rst_n
);
    import rip_pkg::*;

    // Sinais da Interface
    logic               wr_en;
    rip_access_mode_e   access_mode;
    logic [63:0]        din;
    logic [63:0]        dout;
    rip_status_t        status;

    // Modport para a Unidade do Registrador
    modport Register (
        input  clk,
        input  rst_n,
        input  wr_en,
        input  access_mode,
        input  din,
        output dout,
        output status
    );

    // Modport para a Unidade de Fetch / Branch Predictor / Sequenciador de Microcódigo
    modport FetchUnit (
        input  clk,
        input  rst_n,
        output wr_en,
        output access_mode,
        output din,
        input  dout,
        input  status
    );

    // Modport para Testbench e Monitor do Pipeline
    modport Monitor (
        input clk,
        input rst_n,
        input wr_en,
        input access_mode,
        input din,
        input dout,
        input status
    );
endinterface : rip_if


// ============================================================================
// Declaração do Módulo Principal (Sem Implementação Interna)
// ============================================================================
module rip_register (
    input  logic                   clk,
    input  logic                   rst_n,
    input  logic                   wr_en,
    input  rip_pkg::rip_access_mode_e access_mode,
    input  logic [63:0]            din,
    output logic [63:0]            dout,
    output rip_pkg::rip_status_t   status
);

endmodule : rip_register
`endif // __HEADERS_REGISTERS_RIP_SV__
