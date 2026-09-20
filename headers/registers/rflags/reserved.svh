// ============================================================================
// File: headers/registers/rflags/reserved.svh
// Project: x86_64 Hardware Architecture Implementation
// Author: Pedro Emanuel / Modified for x86_64 mask accuracy
// License: GPL-3.0-only
//
// Description: Package, interface, and module for handling the reserved and
//              unused bits of the RFLAGS register (Intel 64 / AMD64).
//              Ensures that fixed bits are maintained correctly (e.g., bit 1 is
//              always 1) and that unallocated bits return 0 upon reading.
// ============================================================================

`ifndef RFLAGS_RESERVED_SVH
`define RFLAGS_RESERVED_SVH

package rflags_reserved_pkg;

    // Bit 1: Sempre 1 por especificação arquitetural da Intel/AMD (Legado do 8086)
    localparam logic [63:0] RFLAGS_ALWAYS_ONE_MASK  = 64'h0000_0000_0000_0002;

    // Máscara com '1' em todas as posições de flags arquiteturais válidas na arquitetura x86_64:
    // [0]=CF, [2]=PF, [4]=AF, [6]=ZF, [7]=SF, [8]=TF, [9]=IF, [10]=DF, [11]=OF,
    // [13:12]=IOPL, [14]=NT, [16]=RF, [17]=VM, [18]=AC, [19]=VIF, [20]=VIP, [21]=ID.
    localparam logic [63:0] RFLAGS_VALID_FLAGS_MASK = 64'h0000_0000_003F_7FD5;

    // Bits reservados que devem SEMPRE ser forçados a 0 na escrita/leitura.
    // Resulta em 64'hFFFF_FFFF_FFC0_8028 através do complemento lógico das flags e do bit 1 estável.
    localparam logic [63:0] RFLAGS_RESERVED_ZERO_MASK = ~(RFLAGS_VALID_FLAGS_MASK | RFLAGS_ALWAYS_ONE_MASK);

    typedef struct packed {
        logic        reserved_violation; // Sinaliza se uma tentativa de escrita tentou alterar bits reservados imutáveis
        logic [63:0] sanitized_val;      // Valor do RFLAGS com a máscara de bits reservados devidamente aplicada
    } reserved_status_t;

endpackage : rflags_reserved_pkg


// ============================================================================
// Interface para Validação e Sanitização dos Bits Reservados do RFLAGS
// ============================================================================
interface rflags_reserved_if (
    input logic clk,
    input logic rst_n
);
    import rflags_reserved_pkg::*;

    logic [63:0]      raw_rflags_in;    // Valor bruto tentando ser escrito (ex: via POPFQ, WRMSR, IRET)
    logic [63:0]      sanitized_rflags; // Valor corrigido respeitando as regras de bits reservados
    reserved_status_t status;           // Status de telemetria/validação

    modport Sanitizer (
        input  clk, rst_n, raw_rflags_in,
        output sanitized_rflags, status
    );

    modport Controller (
        input  clk, rst_n, sanitized_rflags, status,
        output raw_rflags_in
    );

    modport Monitor (
        input clk, rst_n, raw_rflags_in, sanitized_rflags, status
    );
endinterface : rflags_reserved_if


// ============================================================================
// Declaração do Módulo de Bits Reservados (Sem Implementação Interna)
// ============================================================================
module rflags_reserved_checker (
    input  logic                                  clk,
    input  logic                                  rst_n,
    input  logic [63:0]                           raw_rflags_in,
    output logic [63:0]                           sanitized_rflags,
    output rflags_reserved_pkg::reserved_status_t status
);
    // A lógica de aplicação de máscaras bitwise e validação de regras de arquitetura
    // será implementada no arquivo .sv correspondente.
endmodule : rflags_reserved_checker

`endif // RFLAGS_RESERVED_SVH
