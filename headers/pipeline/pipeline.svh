// ============================================================================
// File: headers/pipeline/pipeline.svh
// Project: x86_64 Hardware Architecture Implementation
// Author: Pedro Emanuel
// License: GPL-3.0-only
//
// Description: Package, interface, and module for the global coordination and
//              control of the x86_64 architecture's Superscalar Out-of-Order /
//              In-Order pipeline. Manages the Fetch, Decode, Rename/Alloc,
//              Dispatch, Execute, Memory, Writeback, and Commit/Retire stages.
// ============================================================================

`ifndef PIPELINE_PIPELINE_SVH
`define PIPELINE_PIPELINE_SVH

package pipeline_pipeline_pkg;

    localparam int VIRT_ADDR_WIDTH = 48;
    localparam int ROB_ENTRY_WIDTH  = 7;  // Suporte a até 128 entradas no Reorder Buffer (ROB)
    localparam int PIPELINE_WIDTH   = 4;  // Arquitetura de emissão/retirada de 4 vias (4-way superscalar)

    // Estágios do Pipeline Executivo
    typedef enum logic [3:0] {
        STAGE_FETCH     = 4'b0000,
        STAGE_DECODE    = 4'b0001,
        STAGE_RENAME    = 4'b0010,
        STAGE_DISPATCH  = 4'b0011,
        STAGE_ISSUE     = 4 meb0100,
        STAGE_EXECUTE   = 4'b0101,
        STAGE_MEMORY    = 4'b0110,
        STAGE_WRITEBACK = 4'b0111,
        STAGE_RETIRE    = 4'b1000
    } pipeline_stage_e;

    // Causa de Limpeza/Flushing do Pipeline
    typedef enum logic [2:0] {
        FLUSH_NONE             = 3'b000,
        FLUSH_BRANCH_MISPRED   = 3'b001, // Mispredição de desvio
        FLUSH_EXCEPTION        = 3'b010, // Exceção/Interrupção (#GP, #PF, #DE, etc.)
        FLUSH_SERIALIZING_INSTR= 3'b011, // Instrução serializadora (ex: CPUID, CR3 write, MOV DRx)
        FLUSH_SMC              = 3'b100  // Self-Modifying Code detectado
    } flush_reason_e;

    // Estrutura de Controle Globais do Pipeline (Stall / Flush)
    typedef struct packed {
        logic                     stall_fetch;
        logic                     stall_decode;
        logic                     stall_rename;
        logic                     stall_dispatch;
        logic                     flush_all;
        flush_reason_e            flush_reason;
        logic [VIRT_ADDR_WIDTH-1:0] redirect_pc;
        logic [ROB_ENTRY_WIDTH-1:0]  flush_rob_tag;
    } pipeline_ctrl_t;

    // Estado da Telemetria de Desempenho do Pipeline
    typedef struct packed {
        logic [63:0] retired_instructions;
        logic [63:0] total_cycles;
        logic [63:0] branch_mispredictions;
        logic [63:0] pipeline_stalls;
    } pipeline_telemetry_t;

endpackage : pipeline_pipeline_pkg


// ============================================================================
// Interface Global de Controle e Sincronização do Pipeline
// ============================================================================
interface pipeline_pipeline_if (
    input logic clk,
    input logic rst_n
);
    import pipeline_pipeline_pkg::*;

    // Controle de Fluxo Globais
    pipeline_ctrl_t      ctrl;
    pipeline_telemetry_t telemetry;

    // Sinais de Interrupção/Exceção Externa
    logic                ext_interrupt_req;
    logic [7:0]          ext_interrupt_vector;

    // Modport para o Controlador Central do Pipeline
    modport Controller (
        input  clk, rst_n, ext_interrupt_req, ext_interrupt_vector,
        output ctrl, telemetry
    );

    modport StageFetch (
        input  clk, rst_n, ctrl,
        output ext_interrupt_req
    );

    // Modport para Unidades Executivas / ROB / Scheduler
    modport ExecUnit (
        input  clk, rst_n, ctrl,
        output telemetry
    );

    // Modport para Testbench e Verificação
    modport Monitor (
        input clk, rst_n, ctrl, telemetry, ext_interrupt_req, ext_interrupt_vector
    );
endinterface : pipeline_pipeline_if


// ============================================================================
// Declaração do Módulo Controlador de Pipeline (Sem Implementação Interna)
// ============================================================================
module pipeline_controller (
    input  logic                                  clk,
    input  logic                                  rst_n,
    input  logic                                  ext_interrupt_req,
    input  logic [7:0]                            ext_interrupt_vector,
    output pipeline_pipeline_pkg::pipeline_ctrl_t ctrl,
    output pipeline_pipeline_pkg::pipeline_telemetry_t telemetry
);
    // A lógica de hazard detection, stalls, flushes, redirecionamento de PC
    // e gerência dos estágios do pipeline superscalar
    // será implementada no arquivo .sv correspondente.
endmodule : pipeline_controller

`endif // PIPELINE_PIPELINE_SVH
