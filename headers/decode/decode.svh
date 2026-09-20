// ============================================================================
// File: headers/decode/decode.svh
// Project: x86_64 Hardware Architecture Implementation
// Author: Pedro Emanuel
// License: GPL-3.0-only
//
// Description: Package, interface, and module for the x86_64 / IA-32
//              main instruction decoding unit (Instruction Decoder).
// ============================================================================

`ifndef DECODE_DECODE_SVH
`define DECODE_DECODE_SVH

package decode_decode_pkg;

    localparam int INSTRUCTION_MAX_BYTES = 15;

    typedef enum logic [2:0] {
        DECODE_MODE_16BIT = 3'b000,
        DECODE_MODE_32BIT = 3'b001,
        DECODE_MODE_64BIT = 3'b010
    } decode_mode_e;

    typedef struct packed {
        logic [3:0]  num_prefixes;
        logic        has_rex;
        logic [7:0]  rex_prefix;
        logic        has_vex;
        logic        has_evex;
        logic [23:0] opcode;
        logic        has_modrm;
        logic [7:0]  modrm;
        logic        has_sib;
        logic [7:0]  sib;
        logic [3:0]  disp_bytes;
        logic [3:0]  imm_bytes;
        logic [3:0]  instr_length; // 1 a 15 bytes
    } decoded_instruction_t;

    typedef struct packed {
        logic illegal_instruction; // #UD - Undefined Opcode
        logic max_length_exceeded;  // Instrução maior que 15 bytes
        logic decode_valid;
    } decode_status_t;

endpackage : decode_decode_pkg


// ============================================================================
// Interface Principal do Decodificador
// ============================================================================
interface decode_decode_if (
    input logic clk,
    input logic rst_n
);
    import decode_decode_pkg::*;

    logic [7:0]                  instr_bytes [INSTRUCTION_MAX_BYTES-1:0];
    logic                        fetch_valid;
    decode_mode_e                op_mode;
    decoded_instruction_t        decoded_instr;
    decode_status_t              status;

    modport Decoder (
        input  clk, rst_n, instr_bytes, fetch_valid, op_mode,
        output decoded_instr, status
    );

    modport FetchUnit (
        input  clk, rst_n, decoded_instr, status,
        output instr_bytes, fetch_valid, op_mode
    );

    modport Monitor (
        input clk, rst_n, instr_bytes, fetch_valid, op_mode,
              decoded_instr, status
    );
endinterface : decode_decode_if


// ============================================================================
// Declaração do Módulo Decodificador (Sem Implementação Interna)
// ============================================================================
module decode_decoder (
    input  logic                                 clk,
    input  logic                                 rst_n,
    input  logic [7:0]                           instr_bytes [14:0],
    input  logic                                 fetch_valid,
    input  decode_decode_pkg::decode_mode_e     op_mode,
    output decode_decode_pkg::decoded_instruction_t decoded_instr,
    output decode_decode_pkg::decode_status_t   status
);
    // A lógica de extração de prefixos, opex, modrm, sib e tamanho de instrução
    // será implementada no arquivo .sv correspondente.
endmodule : decode_decoder

`endif // DECODE_DECODE_SVH
