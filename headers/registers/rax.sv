// =============================================================================
// SPDX License Indentifier: GPL-3.0
// Copyright (C) Pedro Emanuel
// file : headers/registers/rax.sv
// =============================================================================

ifndef __HEADERS_REGISTERS_RAX_SV__
`define __HEADERS_REGISTERS_RAX_SV__

package rax_pkg;

    // ------------------------------------------------------------------------
    // Mapeamento de Larguras e Modos de Acesso ao Registrador RAX
    // ------------------------------------------------------------------------
    typedef enum logic [2:0] {
        RAX_ACCESS_64BIT = 3'b000, // RAX: Acesso completo de 64 bits [63:0]
        RAX_ACCESS_32BIT = 3'b001, // EAX: Acesso aos 32 bits inferiores [31:0] (Zera bits [63:32])
        RAX_ACCESS_16BIT = 3'b010, // AX : Acesso aos 16 bits inferiores [15:0] (Preserva bits superiores)
        RAX_ACCESS_8BIT_H= 3'b011, // AH : Acesso ao byte superior de AX [15:8] (Preserva demais bits)
        RAX_ACCESS_8BIT_L= 3'b100  // AL : Acesso ao byte inferior de AX [7:0]   (Preserva demais bits)
    } rax_access_mode_e;

    // ------------------------------------------------------------------------
    // Definição das Mascaras de Controle de Escrita (Write Masks)
    // ------------------------------------------------------------------------
    localparam logic [63:0] RAX_MASK_64BIT  = 64'hFFFF_FFFF_FFFF_FFFF;
    localparam logic [63:0] RAX_MASK_32BIT  = 64'h0000_0000_FFFF_FFFF;
    localparam logic [63:0] RAX_MASK_16BIT  = 64'h0000_0000_0000_FFFF;
    localparam logic [63:0] RAX_MASK_8BIT_H = 64'h0000_0000_0000_FF00;
    localparam logic [63:0] RAX_MASK_8BIT_L = 64'h0000_0000_0000_00FF;

    // ------------------------------------------------------------------------
    // Estruturas de Mapeamento dos Registradores Internos
    // ------------------------------------------------------------------------
    typedef struct packed {
        logic [31:0] high_dword; // Bits [63:32] - Apenas acessível no modo de 64 bits
        logic [15:0] high_word;  // Bits [31:16] - Parte superior de EAX
        logic [7:0]  ah;         // Bits [15:8]  - Registrador AH
        logic [7:0]  al;         // Bits [7:0]   - Registrador AL
    } rax_fields_t;

    // Campos desagregados por bytes para análises específicas
    typedef struct packed {
        logic [7:0] byte7; // Bit [63:56]
        logic [7:0] byte6; // Bit [55:48]
        logic [7:0] byte5; // Bit [47:40]
        logic [7:0] byte4; // Bit [39:32]
        logic [7:0] byte3; // Bit [31:24]
        logic [7:0] byte2; // Bit [23:16]
        logic [7:0] ah;    // Bit [15:8]
        logic [7:0] al;    // Bit [7:0]
    } rax_byte_map_t;

    // Union principal para visualização flexível de RAX
    typedef union packed {
        logic [63:0]   rax;       // Visão completa de 64 bits
        logic [31:0]   eax;       // Visão de 32 bits (parte inferior)
        logic [15:0]   ax;        // Visão de 16 bits (parte inferior)
        rax_fields_t   fields;    // Visão campo a campo (high_dword, high_word, ah, al)
        rax_byte_map_t bytes;     // Visão mapeada por bytes individuais
    } rax_reg_u;

    // ------------------------------------------------------------------------
    // Estrutura de Telemetria e Status
    // ------------------------------------------------------------------------
    typedef struct packed {
        logic        is_zero;     // Alto se RAX for igual a 0
        logic        is_negative; // Alto se o bit de sinal [63] for 1
        logic [63:0] current_val; // Valor atual armazenado
    } rax_status_t;

endpackage : rax_pkg


// ============================================================================
// Interface Completa do Registrador RAX
// ============================================================================
interface rax_if (
    input logic clk,
    input logic rst_n
);
    import rax_pkg::*;

    // Sinais de Controle e Dados
    logic               wr_en;
    rax_access_mode_e   access_mode;
    logic [63:0]        din;
    logic [63:0]        dout;

    // Sinais de Monitoramento e Status
    rax_status_t        status;

    // Modport para o Módulo Registrador
    modport Register (
        input  clk,
        input  rst_n,
        input  wr_en,
        input  access_mode,
        input  din,
        output dout,
        output status
    );

    // Modport para a Unidade de Controle (CPU Core / Decoder)
    modport Controller (
        input  clk,
        input  rst_n,
        output wr_en,
        output access_mode,
        output din,
        input  dout,
        input  status
    );

    // Modport para Testbench / Monitor
    modport Monitor (
        input clk,
        input rst_n,
        input wr_en,
        input access_mode,
        input din,
        input dout,
        input status
    );
endinterface : rax_if


// ============================================================================
// Declaração do Módulo do Registrador RAX (Sem Implementação Interna)
// ============================================================================
module rax_register (
    input  logic                   clk,
    input  logic                   rst_n,
    input  logic                   wr_en,
    input  rax_pkg::rax_access_mode_e access_mode,
    input  logic [63:0]            din,
    output logic [63:0]            dout,
    output rax_pkg::rax_status_t   status
);
    // A implementação interna das regras de escrita (incluindo o zero-extension
    // do EAX) fica num arquivo .sv separado.
endmodule : rax_register


`endif // __HEADERS_REGISTERS_RAX_SV__
