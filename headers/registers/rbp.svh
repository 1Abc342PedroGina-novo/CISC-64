// ============================================================================
// File: headers/registers/rbp.svh
// Project: x86_64 Hardware Architecture Implementation
// Author: Pedro Emanuel
// License: GPL-3.0-only
//
// Description: Declaration of packages, data types, structures, masks,
//              telemetry, interfaces, and module signature for the
//              Base Pointer RBP register (Intel 64 / AMD64 Architecture).
// ============================================================================

`ifndef HEADERS_REGISTERS_RBP_SV
`define HEADERS_REGISTERS_RBP_SV
package rbp_pkg;

    // ------------------------------------------------------------------------
    // Mapeamento dos Modos de Acesso ao Registrador RBP
    // ------------------------------------------------------------------------
    typedef enum logic [2:0] {
        RBP_ACCESS_64BIT = 3'b000, // RBP : Acesso completo [63:0]
        RBP_ACCESS_32BIT = 3'b001, // EBP : Acesso aos 32 bits inferiores [31:0] (Zera bits [63:32])
        RBP_ACCESS_16BIT = 3'b010, // BP  : Acesso aos 16 bits inferiores [15:0] (Preserva bits superiores)
        RBP_ACCESS_8BIT_L= 3'b011  // BPL : Acesso ao byte inferior [7:0] (Via prefixo REX, preserva bits superiores)
    } rbp_access_mode_e;

    // ------------------------------------------------------------------------
    // Máscaras de Bits para Operações de Leitura/Escrita
    // ------------------------------------------------------------------------
    localparam logic [63:0] RBP_MASK_64BIT  = 64'hFFFF_FFFF_FFFF_FFFF;
    localparam logic [63:0] RBP_MASK_32BIT  = 64'h0000_0000_FFFF_FFFF;
    localparam logic [63:0] RBP_MASK_16BIT  = 64'h0000_0000_0000_FFFF;
    localparam logic [63:0] RBP_MASK_8BIT_L = 64'h0000_0000_0000_00FF;

    // ------------------------------------------------------------------------
    // Estruturas de Decomposição de Registradores (Layout x86_64)
    // ------------------------------------------------------------------------
    typedef struct packed {
        logic [31:0] high_dword; // Bits [63:32] - Acessível apenas em modo 64-bit
        logic [15:0] high_word;  // Bits [31:16] - Metade superior de EBP
        logic [7:0]  mid_byte;   // Bits [15:8]  - Bits superiores de BP
        logic [7:0]  bpl;        // Bits [7:0]   - Registrador BPL
    } rbp_fields_t;

    // Mapeamento Byte a Byte para Depuração e Decodificação de Microcódigo
    typedef struct packed {
        logic [7:0] byte7; // Bits [63:56]
        logic [7:0] byte6; // Bits [55:48]
        logic [7:0] byte5; // Bits [47:40]
        logic [7:0] byte4; // Bits [39:32]
        logic [7:0] byte3; // Bits [31:24]
        logic [7:0] byte2; // Bits [23:16]
        logic [7:0] byte1; // Bits [15:8]
        logic [7:0] bpl;   // Bits [7:0]
    } rbp_byte_map_t;

    // União para Múltiplas Visões de Memória do Registrador RBP
    typedef union packed {
        logic [63:0]   rbp;       // Visão 64 bits
        logic [31:0]   ebp;       // Visão 32 bits
        logic [15:0]   bp;        // Visão 16 bits
        rbp_fields_t   fields;    // Visão por subdivisões
        rbp_byte_map_t bytes;     // Visão por bytes individuais
    } rbp_reg_u;

    // ------------------------------------------------------------------------
    // Estrutura de Telemetria e Monitoramento de Estado
    // ------------------------------------------------------------------------
    typedef struct packed {
        logic        is_zero;     // Indicador de valor zero
        logic        is_negative; // Bit de sinal [63]
        logic [63:0] value;       // Valor armazenado atual
    } rbp_status_t;

endpackage : rbp_pkg


// ============================================================================
// Interface SystemVerilog para o Registrador RBP
// ============================================================================
interface rbp_if (
    input logic clk,
    input logic rst_n
);
    import rbp_pkg::*;

    // Sinais da Interface
    logic               wr_en;
    rbp_access_mode_e   access_mode;
    logic [63:0]        din;
    logic [63:0]        dout;
    rbp_status_t        status;

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

    // Modport para o Decodificador / Unidade Executora
    modport Controller (
        input  clk,
        input  rst_n,
        output wr_en,
        output access_mode,
        output din,
        input  dout,
        input  status
    );

    // Modport para Testbench e Telemetria
    modport Monitor (
        input clk,
        input rst_n,
        input wr_en,
        input access_mode,
        input din,
        input dout,
        input status
    );
endinterface : rbp_if


// ============================================================================
// Declaração do Módulo Principal (Sem Implementação Interna)
// ============================================================================
module rbp_register (
    input  logic                   clk,
    input  logic                   rst_n,
    input  logic                   wr_en,
    input  rbp_pkg::rbp_access_mode_e access_mode,
    input  logic [63:0]            din,
    output logic [63:0]            dout,
    output rbp_pkg::rbp_status_t   status
);
    // A implementação da lógica de controle de escrita e zero-extension 
    // deve ser mantida num arquivo separado (.sv).
endmodule : rbp_register

`endif // HEADERS_REGISTERS_RBP_SV
