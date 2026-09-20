// ============================================================================
// File: headers/registers/rflags/pf.svh
// Project: x86_64 Hardware Architecture Implementation
// Author: Pedro Emanuel
// License: GPL-3.0-only
//
// Description: Package, interface, and module dedicated exclusively to the logic
//              of the Parity Flag bit (PF - RFLAGS[2]), responsible for signaling
//              whether the least significant byte (LSB) of the result has an
//              even number of set bits (even parity).
// ============================================================================

`ifndef RFLAGS_PF_SVH
`define RFLAGS_PF_SVH

package rflags_pf_pkg;

    // Posição exata do bit PF no registrador RFLAGS
    localparam int RFLAGS_PF_BIT_INDEX = 2;

    // Modos de atualização do bit PF
    typedef enum logic [1:0] {
        PF_OP_PASS  = 2'b00, // Mantém o valor atual do bit PF
        PF_OP_EVAL  = 2'b01, // Calcula a paridade a partir dos 8 bits inferiores (LSB) do resultado
        PF_OP_CLEAR = 2'b10, // Zera o bit PF
        PF_OP_WRITE = 2'b11  // Escrita direta (ex: restauração via POPF/POPFD/POPFQ ou SAHF/IRET)
    } pf_update_mode_e;

    // Estrutura de Telemetria e Diagnóstico do Bit PF
    typedef struct packed {
        logic pf_bit_value;   // Valor atual do RFLAGS.PF (bit 2)
        logic parity_even;    // Indicador de que os 8 bits inferiores possuem paridade par
    } pf_telemetry_t;

endpackage : rflags_pf_pkg


// ============================================================================
// Interface Exclusiva para Monitoramento e Atualização do Parity Flag (PF)
// ============================================================================
interface rflags_pf_if (
    input logic clk,
    input logic rst_n
);
    import rflags_pf_pkg::*;

    // Sinais de Controle e Entradas da ALU
    logic               pf_write_en;   // Habilita escrita/atualização no bit PF
    pf_update_mode_e    update_mode;   // Modo de operação
    logic [7:0]         alu_result_lsb;// Byte menos significativo (LSB) do resultado da ALU
    logic               pf_direct_in;  // Valor de escrita direta (ex: POPFQ/SAHF)
    
    // Saídas
    logic               pf_out;        // Valor atual do bit PF
    pf_telemetry_t      telemetry;

    // Modport para o Submódulo do Bit PF
    modport PFUnit (
        input  clk, rst_n, pf_write_en, update_mode, alu_result_lsb, pf_direct_in,
        output pf_out, telemetry
    );

    // Modport para a ALU / Control Unit
    modport Controller (
        input  clk, rst_n, pf_out, telemetry,
        output pf_write_en, update_mode, alu_result_lsb, pf_direct_in
    );

    // Modport para Testbench e Monitoramento
    modport Monitor (
        input clk, rst_n, pf_write_en, update_mode, alu_result_lsb, pf_direct_in,
              pf_out, telemetry
    );
endinterface : rflags_pf_if


// ============================================================================
// Declaração do Módulo do Bit PF (Sem Implementação Interna)
// ============================================================================
module rflags_pf_bit (
    input  logic                          clk,
    input  logic                          rst_n,
    input  logic                          pf_write_en,
    input  rflags_pf_pkg::pf_update_mode_e update_mode,
    input  logic [7:0]                    alu_result_lsb,
    input  logic                          pf_direct_in,
    output logic                          pf_out,
    output rflags_pf_pkg::pf_telemetry_t  telemetry
);
    // A lógica interna de cálculo de paridade (PF = ~^alu_result_lsb)
    // será implementada no arquivo .sv correspondente.
endmodule : rflags_pf_bit

`endif // RFLAGS_PF_SVH
