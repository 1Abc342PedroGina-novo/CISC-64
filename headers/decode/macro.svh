// ============================================================================
// File: decode/macro.svh
// Project: x86_64 Hardware Architecture Implementation
// Author: Pedro Emanuel
// License: GPL-3.0-only
//
// Description: Package, interface, and module for macro-operation expansion
//              and decoding (Macro-Op Fusion / Macro-Instruction Expansion)
//              in the x86_64 execution pipeline.
// ============================================================================

`ifndef DECODE_MACRO_SVH
`define DECODE_MACRO_SVH

package decode_macro_pkg;

    typedef enum logic [2:0] {
        MACRO_TYPE_NONE    = 3'b000,
        MACRO_TYPE_CMP_JCC = 3'b001, // Fusão CMP + Jcc
        MACRO_TYPE_TEST_JCC= 3'b010, // Fusão TEST + Jcc
        MACRO_TYPE_ADD_JCC = 3'b011, // Fusão ADD/SUB + Jcc
        MACRO_TYPE_COMPLEX = 3'b100  // Macro-instrução complexa (ex: PUSH, POP, CALL)
    } macro_type_e;

    typedef struct packed {
        logic         fused;          // Indica se ocorreu fusão de macro-ops
        macro_type_e  type_op;        // Tipo da macro-op resultante
        logic [15:0]  uop_count;      // Quantidade de micro-ops (uOps) geradas
        logic         requires_ucode; // Redireciona para o sequenciador de Microcódigo (ROM)
    } macro_status_t;

endpackage : decode_macro_pkg


// ============================================================================
// Interface para o Sequenciador de Macro-Instruções
// ============================================================================
interface decode_macro_if (
    input logic clk,
    input logic rst_n
);
    import decode_macro_pkg::*;
    import decode_decode_pkg::decoded_instruction_t;

    decoded_instruction_t instr_0;
    decoded_instruction_t instr_1;
    logic                 valid_in;

    macro_status_t        status;
    logic                 fusion_possible;

    modport FusionUnit (
        input  clk, rst_n, instr_0, instr_1, valid_in,
        output status, fusion_possible
    );

    modport PipelineController (
        input  clk, rst_n, status, fusion_possible,
        output instr_0, instr_1, valid_in
    );

    modport Monitor (
        input clk, rst_n, instr_0, instr_1, valid_in, status, fusion_possible
    );
endinterface : decode_macro_if


// ============================================================================
// Declaração do Módulo de Macro-Op Fusion (Sem Implementação Interna)
// ============================================================================
module decode_macro_expander (
    input  logic                                      clk,
    input  logic                                      rst_n,
    input  decode_decode_pkg::decoded_instruction_t   instr_0,
    input  decode_decode_pkg::decoded_instruction_t   instr_1,
    input  logic                                      valid_in,
    output decode_macro_pkg::macro_status_t           status,
    output logic                                      fusion_possible
);
    // A lógica de detecção de oportunidades de fusão de instruções e
    // sequenciamento de macro-ops será implementada no arquivo .sv correspondente.
endmodule : decode_macro_expander

`endif // DECODE_MACRO_SVH
