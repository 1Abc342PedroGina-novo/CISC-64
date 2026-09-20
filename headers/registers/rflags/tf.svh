// ============================================================================
// File: headers/registers/rflags/tf.svh
// Project: x86_64 Hardware Architecture Implementation
// Author: Pedro Emanuel
// License: GPL-3.0-only
//
// Description: Package, interface, and module dedicated exclusively to the logic
//              of the Trap Flag bit (TF - RFLAGS[8]), responsible for enabling
//              single-step execution mode (single-step debugging) and
//              generating debug exceptions (#DB) for each instruction (Intel 64 / AMD64).
// ============================================================================

`ifndef RFLAGS_TF_SVH
`define RFLAGS_TF_SVH

package rflags_tf_pkg;

    // Posição exata do bit TF no registrador RFLAGS
    localparam int RFLAGS_TF_BIT_INDEX = 8;

    // Modos de atualização do bit TF
    typedef enum logic [1:0] {
        TF_OP_PASS  = 2'b00, // Mantém o valor atual do bit TF
        TF_OP_SET   = 2'b01, // Força TF em 1 (habilita modo single-step via POPF/IRET)
        TF_OP_CLEAR = 2'b10, // Zera TF (desabilita modo single-step)
        TF_OP_WRITE = 2'b11  // Escrita direta (ex: restauração via POPF/POPFD/POPFQ ou IRET)
    } tf_update_mode_e;

    // Estrutura de Telemetria e Diagnóstico do Bit TF
    typedef struct packed {
        logic tf_bit_value;        // Valor atual do RFLAGS.TF (bit 8)
        logic single_step_active;  // Indicador de que o modo single-step está ativo
        logic trap_fault_trigger;  // Sinal de disparo para a exceção de depuração (#DB) pós-instrução
    } tf_telemetry_t;

endpackage : rflags_tf_pkg


// ============================================================================
// Interface Exclusiva para Monitoramento e Atualização do Trap Flag (TF)
// ============================================================================
interface rflags_tf_if (
    input logic clk,
    input logic rst_n
);
    import rflags_tf_pkg::*;

    // Sinais de Controle
    logic               tf_write_en;        // Habilita escrita/atualização no bit TF
    tf_update_mode_e    update_mode;        // Modo de operação (Pass, Set, Clear, Write)
    logic               tf_direct_in;       // Valor de escrita direta (ex: POPFQ/IRET)
    logic               inst_executed_stb;  // Strobe indicando que uma instrução foi concluída com sucesso
    
    // Saídas
    logic               tf_out;             // Valor atual do bit TF
    tf_telemetry_t      telemetry;

    // Modport para o Submódulo do Bit TF
    modport TFUnit (
        input  clk, rst_n, tf_write_en, update_mode, tf_direct_in, inst_executed_stb,
        output tf_out, telemetry
    );

    // Modport para a Unidade de Controle / Unidade de Debug (#DB) / Pipeline
    modport Controller (
        input  clk, rst_n, tf_out, telemetry,
        output tf_write_en, update_mode, tf_direct_in, inst_executed_stb
    );

    // Modport para Testbench e Monitoramento
    modport Monitor (
        input clk, rst_n, tf_write_en, update_mode, tf_direct_in, inst_executed_stb,
              tf_out, telemetry
    );
endinterface : rflags_tf_if


// ============================================================================
// Declaração do Módulo do Bit TF (Sem Implementação Interna)
// ============================================================================
module rflags_tf_bit (
    input  logic                          clk,
    input  logic                          rst_n,
    input  logic                          tf_write_en,
    input  rflags_tf_pkg::tf_update_mode_e update_mode,
    input  logic                          tf_direct_in,
    input  logic                          inst_executed_stb,
    output logic                          tf_out,
    output rflags_tf_pkg::tf_telemetry_t  telemetry
);
    // A lógica interna de geração da exceção #DB após a conclusão
    // de cada instrução quando TF=1 será implementada no arquivo .sv correspondente.
endmodule : rflags_tf_bit

`endif // RFLAGS_TF_SVH
