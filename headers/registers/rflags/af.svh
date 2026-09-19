//============================================================================
// File: header/registers/af.svh
// Project: x86_64 Hardware Architecture Implementation
// Author: Pedro Emanuel
// License: GPL-3.0-only
//
// Description: Package, interface, and module dedicated exclusively to the
//              logic for the Auxiliary Carry Flag (AF - RFLAGS[4]) bit and
//              support for BCD / Nibble arithmetic operations (Intel 64 /
//              AMD64 Architecture).
// ============================================================================

`ifndef RFLAGS_AF_SVH
`define RFLAGS_AF_SVH

package rflags_af_pkg;

    // Posição exata do bit AF no registrador RFLAGS
    localparam int RFLAGS_AF_BIT_INDEX = 4;

    // Modos de atualização do bit AF pela ALU
    typedef enum logic [1:0] {
        AF_OP_PASS        = 2'b00, // Mantém o valor atual do bit AF
        AF_OP_SET         = 2'b01, // Força o bit AF em 1
        AF_OP_CLEAR       = 2'b10, // Zera o bit AF (0)
        AF_OP_UPDATE_ALU  = 2'b11  // Atualiza AF com base no carry/borrow do bit 3 (Nibble Carry)
    } af_update_mode_e;

    // Estrutura de Entrada da ALU para Cálculo de Nibble Carry (Bit 3 -> Bit 4)
    typedef struct packed {
        logic [3:0] operand_a; // 4 bits inferiores (nibble inferior) do Operando A
        logic [3:0] operand_b; // 4 bits inferiores (nibble inferior) do Operando B
        logic       sub_op;    // 0: Adição, 1: Subtração / Comparação
        logic       carry_in;  // Carry/Borrow de entrada do nibble (se aplicável)
    } af_alu_inputs_t;

    // Estrutura de Telemetria e Monitoramento do Bit AF
    typedef struct packed {
        logic af_bit_value;    // Valor atual do RFLAGS.AF (bit 4)
        logic nibble_carry;    // Carry gerado do bit 3 para o bit 4
        logic nibble_borrow;   // Borrow gerado na subtração do nibble
    } af_telemetry_t;

endpackage : rflags_af_pkg


// ============================================================================
// Interface Exclusiva para Monitoramento e Atualização do Auxiliary Flag (AF)
// ============================================================================
interface rflags_af_if (
    input logic clk,
    input logic rst_n
);
    import rflags_af_pkg::*;

    // Sinais de Controle
    logic               af_write_en;   // Habilita escrita direta/atualização no bit AF
    af_update_mode_e    update_mode;   // Modo de atualização (Set, Clear, Pass, ALU)
    logic               af_direct_in;  // Valor de escrita direta no bit AF (ex: via POPF)
    logic               af_out;        // Valor atual do bit AF
    
    // Interface com a ALU para cálculo automático de Nibble Carry
    af_alu_inputs_t     alu_inputs;
    
    // Telemetria
    af_telemetry_t      telemetry;

    // Modport para o Submódulo do Bit AF
    modport AFUnit (
        input  clk, rst_n, af_write_en, update_mode, af_direct_in, alu_inputs,
        output af_out, telemetry
    );

    // Modport para a ALU / Unidade de Microcódigo
    modport Controller (
        input  clk, rst_n, af_out, telemetry,
        output af_write_en, update_mode, af_direct_in, alu_inputs
    );

    // Modport para Testbench e Monitoramento
    modport Monitor (
        input clk, rst_n, af_write_en, update_mode, af_direct_in, af_out, alu_inputs, telemetry
    );
endinterface : rflags_af_if


// ============================================================================
// Declaração do Módulo do Bit AF (Sem Implementação Interna)
// ============================================================================
module rflags_af_bit (
    input  logic                          clk,
    input  logic                          rst_n,
    input  logic                          af_write_en,
    input  rflags_af_pkg::af_update_mode_e update_mode,
    input  logic                          af_direct_in,
    input  rflags_af_pkg::af_alu_inputs_t alu_inputs,
    output logic                          af_out,
    output rflags_af_pkg::af_telemetry_t  telemetry
);
    // A lógica interna de detecção de carry/borrow entre os bits 3 e 4
    // das operações da ALU e o registro do estado do bit AF
    // serão implementadas no arquivo .sv correspondente.
endmodule : rflags_af_bit

`endif // RFLAGS_AF_SVH
