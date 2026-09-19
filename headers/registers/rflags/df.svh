// ============================================================================
// File: headers/registers/rflags/df.svh
// Project: x86_64 Hardware Architecture Implementation
// Author: Pedro Emanuel
// License: GPL-3.0-only
//
// Description: Package, interface, and module dedicated exclusively to the
//              logic for the Direction Flag (DF - RFLAGS[10]) bit and control
//              of the auto-increment/auto-decrement direction in string
//              instructions (Intel 64 / AMD64).
// ============================================================================

`ifndef RFLAGS_DF_SVH
`define RFLAGS_DF_SVH

package rflags_df_pkg;

    // Posição exata do bit DF no registrador RFLAGS
    localparam int RFLAGS_DF_BIT_INDEX = 10;

    // Modos de atualização do bit DF por instruções dedicadas (STD, CLD) ou controle
    typedef enum logic [1:0] {
        DF_OP_PASS  = 2'b00, // Mantém o valor atual do bit DF
        DF_OP_SET   = 2'b01, // Força o bit DF em 1 (ex: instrução STD - autodecremento de ponteiros)
        DF_OP_CLEAR = 2'b10, // Zera o bit DF (0) (ex: instrução CLD - autoincremento de ponteiros)
        DF_OP_WRITE = 2'b11  // Escrita direta do bit (ex: restauração via POPF/POPFD/POPFQ)
    } df_update_mode_e;

    // Estrutura de Telemetria e Direção de Processamento de String (MOVS, STOS, LODS, CMPS, SCAS)
    typedef struct packed {
        logic df_bit_value;      // Valor atual do RFLAGS.DF (bit 10)
        logic is_decrementing;   // 1: Endereços RDI/RSI decrementam (DF=1), 0: Endereços incrementam (DF=0)
    } df_telemetry_t;

endpackage : rflags_df_pkg


// ============================================================================
// Interface Exclusiva para Monitoramento e Atualização do Direction Flag (DF)
// ============================================================================
interface rflags_df_if (
    input logic clk,
    input logic rst_n
);
    import rflags_df_pkg::*;

    // Sinais de Controle
    logic               df_write_en;   // Habilita escrita/atualização no bit DF
    df_update_mode_e    update_mode;   // Modo de operação (Set, Clear, Pass, Write)
    logic               df_direct_in;  // Valor para escrita direta (ex: POPF)
    logic               df_out;        // Valor atual do bit DF
    
    // Telemetria do Estado da Unidade
    df_telemetry_t      telemetry;

    // Modport para o Submódulo do Bit DF
    modport DFUnit (
        input  clk, rst_n, df_write_en, update_mode, df_direct_in,
        output df_out, telemetry
    );

    // Modport para a Unidade de Instruções de String / Sequenciador de Microcódigo
    modport Controller (
        input  clk, rst_n, df_out, telemetry,
        output df_write_en, update_mode, df_direct_in
    );

    // Modport para Testbench e Monitoramento
    modport Monitor (
        input clk, rst_n, df_write_en, update_mode, df_direct_in, df_out, telemetry
    );
endinterface : rflags_df_if


// ============================================================================
// Declaração do Módulo do Bit DF (Sem Implementação Interna)
// ============================================================================
module rflags_df_bit (
    input  logic                          clk,
    input  logic                          rst_n,
    input  logic                          df_write_en,
    input  rflags_df_pkg::df_update_mode_e update_mode,
    input  logic                          df_direct_in,
    output logic                          df_out,
    output rflags_df_pkg::df_telemetry_t  telemetry
);
    // A lógica interna de armazenamento e controle do bit DF para instruções
    // de manipulação de memória (STD/CLD/POPF) será implementada no arquivo .sv correspondente.
endmodule : rflags_df_bit

`endif // RFLAGS_DF_SVH
