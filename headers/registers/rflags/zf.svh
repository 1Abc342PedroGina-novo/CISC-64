// ============================================================================
// File: headers/registers/rflags/zf.svh
// Project: x86_64 Hardware Architecture Implementation
// Author: Pedro Emanuel
// License: GPL-3.0-only
//
// Description: Package, interface, and module dedicated exclusively to the
//              logic for the Zero Flag bit (ZF - RFLAGS[6]), responsible for
//              indicating whether the result of an arithmetic/logical
//              operation was zero (Intel 64 / AMD64).
// ============================================================================

`ifndef RFLAGS_ZF_SVH
`define RFLAGS_ZF_SVH

package rflags_zf_pkg;

    // Posição exata do bit ZF no registrador RFLAGS
    localparam int RFLAGS_ZF_BIT_INDEX = 6;

    // Modos de atualização do bit ZF
    typedef enum logic [1:0] {
        ZF_OP_PASS  = 2'b00, // Mantém o valor atual do bit ZF
        ZF_OP_SET   = 2'b01, // Força ZF em 1 (Resultado da ALU foi zero)
        ZF_OP_CLEAR = 2'b10, // Zera ZF (Resultado da ALU foi diferente de zero)
        ZF_OP_WRITE = 2'b11  // Escrita direta (ex: restauração via POPF/POPFD/POPFQ ou IRET)
    } zf_update_mode_e;

    // Estrutura de Telemetria e Diagnóstico do Bit ZF
    typedef struct packed {
        logic zf_bit_value;        // Valor atual do RFLAGS.ZF (bit 6)
        logic is_zero_result;      // Indicador de resultado igual a zero
    } zf_telemetry_t;

endpackage : rflags_zf_pkg


// ============================================================================
// Interface Exclusiva para Monitoramento e Atualização do Zero Flag (ZF)
// ============================================================================
interface rflags_zf_if (
    input logic clk,
    input logic rst_n
);
    import rflags_zf_pkg::*;

    // Sinais de Controle
    logic               zf_write_en;   // Habilita escrita/atualização no bit ZF
    zf_update_mode_e    update_mode;   // Modo de operação (Pass, Set, Clear, Write)
    logic               zf_direct_in;  // Valor de escrita direta (ex: POPFQ/IRET)
    
    // Saídas
    logic               zf_out;        // Valor atual do bit ZF
    zf_telemetry_t      telemetry;

    // Modport para o Submódulo do Bit ZF
    modport ZFUnit (
        input  clk, rst_n, zf_write_en, update_mode, zf_direct_in,
        output zf_out, telemetry
    );

    // Modport para a Unidade de Controle / ULA / Execução
    modport Controller (
        input  clk, rst_n, zf_out, telemetry,
        output zf_write_en, update_mode, zf_direct_in
    );

    // Modport para Testbench e Monitoramento
    modport Monitor (
        input clk, rst_n, zf_write_en, update_mode, zf_direct_in,
              zf_out, telemetry
    );
endinterface : rflags_zf_if


// ============================================================================
// Declaração do Módulo do Bit ZF (Sem Implementação Interna)
// ============================================================================
module rflags_zf_bit (
    input  logic                          clk,
    input  logic                          rst_n,
    input  logic                          zf_write_en,
    input  rflags_zf_pkg::zf_update_mode_e update_mode,
    input  logic                          zf_direct_in,
    output logic                          zf_out,
    output rflags_zf_pkg::zf_telemetry_t  telemetry
);
    // A lógica interna de atualização baseada nos resultados da ULA
    // e no caminho de dados será implementada no arquivo .sv correspondente.
endmodule : rflags_zf_bit

`endif // RFLAGS_ZF_SVH
