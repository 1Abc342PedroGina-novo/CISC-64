// ============================================================================
// File: headers/registers/rflags/of.svh
// Project: x86_64 Hardware Architecture Implementation
// Author: Pedro Emanuel
// License: GPL-3.0-only
//
// Description: Package, interface, and module dedicated exclusively to the
//              logic for the Overflow Flag bit (OF - RFLAGS[11]), responsible
//              for signaling overflow in signed arithmetic operations
//              (Intel 64 / AMD64).
// ============================================================================

`ifndef RFLAGS_OF_SVH
`define RFLAGS_OF_SVH

package rflags_of_pkg;

    // Posição exata do bit OF no registrador RFLAGS
    localparam int RFLAGS_OF_BIT_INDEX = 11;

    // Modos de atualização do bit OF por operações da ALU ou controle direto
    typedef enum logic [2:0] {
        OF_OP_PASS  = 3'b000, // Mantém o valor atual do bit OF
        OF_OP_SET   = 3'b001, // Força o bit OF em 1 (ex: instrução STC não afeta OF, mas pode ser usado internamente)
        OF_OP_CLEAR = 3'b010, // Zera o bit OF (0) (ex: operações lógicas AND, OR, XOR forçam OF=0)
        OF_OP_EVAL  = 3'b011, // Atualiza OF com base no resultado da ALU (Aritmética com sinal)
        OF_OP_WRITE = 3'b100  // Escrita direta (ex: restauração via POPF/POPFD/POPFQ ou SAHF/IRET)
    } of_update_mode_e;

    // Largura do operando na ALU para cálculo de Overflow com sinal
    typedef enum logic [1:0] {
        OF_SIZE_8BIT  = 2'b00,
        OF_SIZE_16BIT = 2'b01,
        OF_SIZE_32BIT = 2'b10,
        OF_SIZE_64BIT = 2'b11
    } operand_size_e;

    // Estrutura de Telemetria e Diagnóstico do Bit OF
    typedef struct packed {
        logic of_bit_value;    // Valor atual do RFLAGS.OF (bit 11)
        logic overflow_detected;// Indicador de que a última operação causou estouro de sinal
    } of_telemetry_t;

endpackage : rflags_of_pkg


// ============================================================================
// Interface Exclusiva para Monitoramento e Atualização do Overflow Flag (OF)
// ============================================================================
interface rflags_of_if (
    input logic clk,
    input logic rst_n
);
    import rflags_of_pkg::*;

    // Sinais de Controle e Entradas da ALU
    logic               of_write_en;   // Habilita escrita/atualização no bit OF
    of_update_mode_e    update_mode;   // Modo de operação
    operand_size_e      op_size;       // Tamanho do operando (8, 16, 32, 64 bits)
    logic               msb_op1;       // Bit mais significativo do Operando 1
    logic               msb_op2;       // Bit mais significativo do Operando 2
    logic               msb_res;       // Bit mais significativo do Resultado
    logic               carry_into_msb;// Carry de entrada no bit MSB (para cálculo alternativo)
    logic               carry_out_msb; // Carry de saída do bit MSB
    logic               of_direct_in;  // Valor de escrita direta (ex: POPFQ)
    
    // Saídas
    logic               of_out;        // Valor atual do bit OF
    of_telemetry_t      telemetry;

    // Modport para o Submódulo do Bit OF
    modport OFUnit (
        input  clk, rst_n, of_write_en, update_mode, op_size,
               msb_op1, msb_op2, msb_res, carry_into_msb, carry_out_msb, of_direct_in,
        output of_out, telemetry
    );

    // Modport para a ALU / Control Unit
    modport Controller (
        input  clk, rst_n, of_out, telemetry,
        output of_write_en, update_mode, op_size,
               msb_op1, msb_op2, msb_res, carry_into_msb, carry_out_msb, of_direct_in
    );

    // Modport para Testbench e Monitoramento
    modport Monitor (
        input clk, rst_n, of_write_en, update_mode, op_size,
              msb_op1, msb_op2, msb_res, carry_into_msb, carry_out_msb, of_direct_in,
              of_out, telemetry
    );
endinterface : rflags_of_if


// ============================================================================
// Declaração do Módulo do Bit OF (Sem Implementação Interna)
// ============================================================================
module rflags_of_bit (
    input  logic                          clk,
    input  logic                          rst_n,
    input  logic                          of_write_en,
    input  rflags_of_pkg::of_update_mode_e update_mode,
    input  rflags_of_pkg::operand_size_e  op_size,
    input  logic                          msb_op1,
    input  logic                          msb_op2,
    input  logic                          msb_res,
    input  logic                          carry_into_msb,
    input  logic                          carry_out_msb,
    input  logic                          of_direct_in,
    output logic                          of_out,
    output rflags_of_pkg::of_telemetry_t  telemetry
);
    // A lógica interna de cálculo de Overflow (OF = carry_into_msb ^ carry_out_msb)
    // para adições e subtrações com sinal será implementada no arquivo .sv correspondente.
endmodule : rflags_of_bit

`endif // RFLAGS_OF_SVH
