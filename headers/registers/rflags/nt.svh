// ============================================================================
// File: headers/registers/rflags/nt.svh
// Project: x86_64 Hardware Architecture Implementation
// Author: Pedro Emanuel
// License: GPL-3.0-only
//
// Description: Package, interface, and module dedicated exclusively to the
//              logic of the Nested Task (NT - RFLAGS[14]) bit. Used in Protected
//              Mode and Real Mode for task chaining via TSS (Task State Segment),
//              while being forced to 0 / ignored in Long Mode (64-bit).
// ============================================================================

`ifndef RFLAGS_NT_SVH
`define RFLAGS_NT_SVH

package rflags_nt_pkg;

    // Posição exata do bit NT no registrador RFLAGS
    localparam int RFLAGS_NT_BIT_INDEX = 14;

    // Modos de operação do processador referentes ao suporte do bit NT
    typedef enum logic [1:0] {
        CPU_MODE_REAL        = 2'b00, // Real Mode (Suporta troca de tarefas/NT)
        CPU_MODE_PROTECTED   = 2 meb01, // Protected Mode (Suporta encadeamento via TSS)
        CPU_MODE_COMPATIBILITY= 2'b10, // Compatibility Mode (32-bit em SO 64-bit)
        CPU_MODE_LONG        = 2'b11  // Long Mode 64-bit (Bit NT é inativo / desabilitado)
    } cpu_execution_mode_e;

    // Modos de atualização do bit NT
    typedef enum logic [1:0] {
        NT_OP_PASS  = 2'b00, // Mantém o valor atual do bit NT
        NT_OP_SET   = 2'b01, // Força NT em 1 (ex: chamada de Task Gate via CALL)
        NT_OP_CLEAR = 2'b10, // Zera NT (ex: retorno via IRET ou reset)
        NT_OP_WRITE = 2'b11  // Escrita direta (ex: restauração via POPF/POPFD em Real Mode)
    } nt_update_mode_e;

    // Estrutura de Telemetria e Diagnóstico do Bit NT
    typedef struct packed {
        logic nt_bit_value;      // Valor atual do RFLAGS.NT (bit 14)
        logic nested_iret_active;// Indicador de que a instrução IRET deve consultar o Back-link no TSS
        logic nt_ignored_longmode;// Sinaliza se o bit NT está inativo devido ao Long Mode
    } nt_telemetry_t;

endpackage : rflags_nt_pkg


// ============================================================================
// Interface Exclusiva para Monitoramento e Atualização do Nested Task Flag (NT)
// ============================================================================
interface rflags_nt_if (
    input logic clk,
    input logic rst_n
);
    import rflags_nt_pkg::*;

    // Sinais de Controle
    logic                 nt_write_en;   // Habilita escrita/atualização no bit NT
    nt_update_mode_e      update_mode;   // Modo de operação (Pass, Set, Clear, Write)
    logic                 nt_direct_in;  // Valor de escrita direta (ex: POPF)
    cpu_execution_mode_e  cpu_mode;      // Modo de execução do processador
    logic                 nt_out;        // Valor atual do bit NT
    
    // Telemetria do Estado da Unidade
    nt_telemetry_t        telemetry;

    // Modport para o Submódulo do Bit NT
    modport NTUnit (
        input  clk, rst_n, nt_write_en, update_mode, nt_direct_in, cpu_mode,
        output nt_out, telemetry
    );

    // Modport para o Gerenciador de Tarefas (Task Switch) / Decoder / Microcódigo
    modport Controller (
        input  clk, rst_n, nt_out, telemetry,
        output nt_write_en, update_mode, nt_direct_in, cpu_mode
    );

    // Modport para Testbench e Monitoramento
    modport Monitor (
        input clk, rst_n, nt_write_en, update_mode, nt_direct_in, cpu_mode, nt_out, telemetry
    );
endinterface : rflags_nt_if


// ============================================================================
// Declaração do Módulo do Bit NT (Sem Implementação Interna)
// ============================================================================
module rflags_nt_bit (
    input  logic                            clk,
    input  logic                            rst_n,
    input  logic                            nt_write_en,
    input  rflags_nt_pkg::nt_update_mode_e  update_mode,
    input  logic                            nt_direct_in,
    input  rflags_nt_pkg::cpu_execution_mode_e cpu_mode,
    output logic                            nt_out,
    output rflags_nt_pkg::nt_telemetry_t    telemetry
);
    // A lógica interna de controle do bit NT em Real/Protected Mode
    // e seu mascaramento/zeramento automático em Long Mode (64-bit)
    // serão implementadas no arquivo .sv correspondente.
endmodule : rflags_nt_bit

`endif // RFLAGS_NT_SVH
