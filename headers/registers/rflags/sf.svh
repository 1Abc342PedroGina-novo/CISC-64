// ============================================================================
// File: headers/registers/rflags/sf.svh
// Project: x86_64 Hardware Architecture Implementation
// Author: Pedro Emanuel
// License: GPL-3.0-only
//
// Description: Package, interface, and module dedicated exclusively to the logic
//              of the Sign Flag bit (SF - RFLAGS[7]), responsible for reflecting
//              the most significant bit (MSB) of the result of an arithmetic
//              or logical operation in the ALU (Intel 64 / AMD64).
// ============================================================================

`ifndef RFLAGS_SF_SVH
`define RFLAGS_SF_SVH

package rflags_sf_pkg;

    // Posição exata do bit SF no registrador RFLAGS
    localparam int RFLAGS_SF_BIT_INDEX = 7;

    // Modos de atualização do bit SF
    typedef enum logic [1:0] {
        SF_OP_PASS  = 2'b00, // Mantém o valor atual do bit SF
        SF_OP_EVAL  = 2'b01, // Avalia e copia o bit MSB do resultado da ALU
        SF_OP_CLEAR = 2'b10, // Zera o bit SF
        SF_OP_WRITE = 2'b11  // Escrita direta (ex: restauração via POPF/POPFD/POPFQ ou SAHF/IRET)
    } sf_update_mode_e;

    // Largura do operando na ALU para extração correta do MSB
    typedef enum logic [1:0] {
        SF_SIZE_8BIT  = 2'b00,
        SF_SIZE_16BIT = 2'b01,
        SF_SIZE_32BIT = 2'b10,
        SF_SIZE_64BIT = 2'b11
    } operand_size_e;

    // Estrutura de Telemetria e Diagnóstico do Bit SF
    typedef struct packed {
        logic sf_bit_value;   // Valor atual do RFLAGS.SF (bit 7)
        logic is_negative;    // Indicador de que o último resultado foi negativo
    } sf_telemetry_t;

endpackage : rflags_sf_pkg


// ============================================================================
// Interface Exclusiva para Monitoramento e Atualização do Sign Flag (SF)
// ============================================================================
interface rflags_sf_if (
    input logic clk,
    input logic rst_n
);
    import rflags_sf_pkg::*;

    // Sinais de Controle e Entradas da ALU
    logic               sf_write_en;   // Habilita escrita/atualização no bit SF
    sf_update_mode_e    update_mode;   // Modo de operação
    operand_size_e      op_size;       // Tamanho do operando (8, 16, 32, 64 bits)
    logic               alu_msb;       // Bit MSB do resultado (calculado com base em op_size)
    logic               sf_direct_in;  // Valor de escrita direta (ex: POPFQ/SAHF)
    
    // Saídas
    logic               sf_out;        // Valor atual do bit SF
    sf_telemetry_t      telemetry;

    // Modport para o Submódulo do Bit SF
    modport SFUnit (
        input  clk, rst_n, sf_write_en, update_mode, op_size, alu_msb, sf_direct_in,
        output sf_out, telemetry
    );

    // Modport para a ALU / Control Unit
    modport Controller (
        input  clk, rst_n, sf_out, telemetry,
        output sf_write_en, update_mode, op_size, alu_msb, sf_direct_in
    );

    // Modport para Testbench e Monitoramento
    modport Monitor (
        input clk, rst_n, sf_write_en, update_mode, op_size, alu_msb, sf_direct_in,
              sf_out, telemetry
    );
endinterface : rflags_sf_if


// ============================================================================
// Declaração do Módulo do Bit SF (Sem Implementação Interna)
// ============================================================================
module rflags_sf_bit (
    input  logic                          clk,
    input  logic                          rst_n,
    input  logic                          sf_write_en,
    input  rflags_sf_pkg::sf_update_mode_e update_mode,
    input  rflags_sf_pkg::operand_size_e  op_size,
    input  logic                          alu_msb,
    input  logic                          sf_direct_in,
    output logic                          sf_out,
    output rflags_sf_pkg::sf_telemetry_t  telemetry
);
    // A lógica interna de atualização do Sign Flag (SF = alu_msb)
    // será implementada no arquivo .sv correspondente.
endmodule : rflags_sf_bit

`endif // RFLAGS_SF_SVH
