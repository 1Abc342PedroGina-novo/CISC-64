// ============================================================================
// File: headers/registers/rflags/rf.svh
// Project: x86_64 Hardware Architecture Implementation
// Author: Pedro Emanuel
// License: GPL-3.0-only
// Description: Package, interface, and module dedicated exclusively to the logic
//              of the Resume Flag bit (RF - RFLAGS[16]), responsible for suppressing
//              the generation of instruction breakpoint exceptions (#DB) after
//              returning from an interrupt handler (Intel 64 / AMD64).
// ============================================================================
`ifndef RFLAGS_RF_SVH
`define RFLAGS_RF_SVH

package rflags_rf_pkg;

    // Posição exata do bit RF no registrador RFLAGS
    localparam int RFLAGS_RF_BIT_INDEX = 16;

    // Modos de atualização do bit RF
    typedef enum logic [1:0] {
        RF_OP_PASS  = 2'b00, // Mantém o valor atual do bit RF
        RF_OP_SET   = 2'b01, // Força RF em 1 (ex: ao tratar exceção #DB ou via POPF/IRET)
        RF_OP_CLEAR = 2'b10, // Zera RF automaticamente após a execução bem-sucedida de uma instrução
        RF_OP_WRITE = 2'b11  // Escrita direta (ex: restauração via POPF/POPFD/POPFQ ou IRET)
    } rf_update_mode_e;

    // Estrutura de Telemetria e Diagnóstico do Bit RF
    typedef struct packed {
        logic rf_bit_value;         // Valor atual do RFLAGS.RF (bit 16)
        logic debug_exception_mask; // Indicador de que exceções de breakpoint (#DB) devem ser suprimidas
    } rf_telemetry_t;

endpackage : rflags_rf_pkg


// ============================================================================
// Interface Exclusiva para Monitoramento e Atualização do Resume Flag (RF)
// ============================================================================
interface rflags_rf_if (
    input logic clk,
    input logic rst_n
);
    import rflags_rf_pkg::*;

    // Sinais de Controle
    logic               rf_write_en;   // Habilita escrita/atualização no bit RF
    rf_update_mode_e    update_mode;   // Modo de operação (Pass, Set, Clear, Write)
    logic               rf_direct_in;  // Valor de escrita direta (ex: POPFQ/IRET)
    
    // Saídas
    logic               rf_out;        // Valor atual do bit RF
    rf_telemetry_t      telemetry;

    // Modport para o Submódulo do Bit RF
    modport RFUnit (
        input  clk, rst_n, rf_write_en, update_mode, rf_direct_in,
        output rf_out, telemetry
    );

    // Modport para a Unidade de Decodificação / Controle de Debug (#DB)
    modport Controller (
        input  clk, rst_n, rf_out, telemetry,
        output rf_write_en, update_mode, rf_direct_in
    );

    // Modport para Testbench e Monitoramento
    modport Monitor (
        input clk, rst_n, rf_write_en, update_mode, rf_direct_in, rf_out, telemetry
    );
endinterface : rflags_rf_if


// ============================================================================
// Declaração do Módulo do Bit RF (Sem Implementação Interna)
// ============================================================================
module rflags_rf_bit (
    input  logic                          clk,
    input  logic                          rst_n,
    input  logic                          rf_write_en,
    input  rflags_rf_pkg::rf_update_mode_e update_mode,
    input  logic                          rf_direct_in,
    output logic                          rf_out,
    output rflags_rf_pkg::rf_telemetry_t  telemetry
);
    // A lógica interna de controle do bit RF e o seu zeramento automático
    // pós-execução de instrução serão implementadas no arquivo .sv correspondente.
endmodule : rflags_rf_bit

`endif // RFLAGS_RF_SVH
