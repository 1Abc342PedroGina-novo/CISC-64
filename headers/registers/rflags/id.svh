// ============================================================================
// File: headers/registers/rflags/id.svh
// Project: x86_64 Hardware Architecture Implementation
// Author: Pedro Emanuel
// License: GPL-3.0-only
//
// Description: Package, interface, and module dedicated exclusively to the
//              logic of the ID Flag bit (ID - RFLAGS[21]), used to identify
//              support for the CPUID instruction (Intel 64 / AMD64).
// ============================================================================

`ifndef RFLAGS_ID_SVH
`define RFLAGS_ID_SVH

package rflags_id_pkg;

    // Posição exata do bit ID no registrador RFLAGS
    localparam int RFLAGS_ID_BIT_INDEX = 21;

    // Modos de atualização do bit ID (alterado via POPFD/POPFQ ou PUSHF/POPF)
    typedef enum logic [1:0] {
        ID_OP_PASS  = 2'b00, // Mantém o valor atual do bit ID
        ID_OP_TOGGLE= 2'b01, // Inverte o bit ID (teste de alternância para detecção do CPUID)
        ID_OP_WRITE = 2'b10  // Escrita direta no bit ID (ex: restauração via POPFQ)
    } id_update_mode_e;

    // Estrutura de Telemetria e Diagnóstico do Bit ID
    typedef struct packed {
        logic id_bit_value;     // Valor atual do RFLAGS.ID (bit 21)
        logic cpuid_supported;  // 1: Se o bit ID pode ser modificado pelo software (suporte a CPUID)
    } id_telemetry_t;

endpackage : rflags_id_pkg


// ============================================================================
// Interface Exclusiva para Monitoramento e Atualização do ID Flag (ID)
// ============================================================================
interface rflags_id_if (
    input logic clk,
    input logic rst_n
);
    import rflags_id_pkg::*;

    // Sinais de Controle
    logic               id_write_en;   // Habilita escrita/atualização no bit ID
    id_update_mode_e    update_mode;   // Modo de operação (Pass, Toggle, Write)
    logic               id_direct_in;  // Valor de escrita direta no bit ID
    logic               id_out;        // Valor atual do bit ID
    
    // Telemetria do Estado da Unidade
    id_telemetry_t      telemetry;

    // Modport para o Submódulo do Bit ID
    modport IDUnit (
        input  clk, rst_n, id_write_en, update_mode, id_direct_in,
        output id_out, telemetry
    );

    // Modport para o Sequenciador do CPUID / Control Unit
    modport Controller (
        input  clk, rst_n, id_out, telemetry,
        output id_write_en, update_mode, id_direct_in
    );

    // Modport para Testbench e Monitoramento
    modport Monitor (
        input clk, rst_n, id_write_en, update_mode, id_direct_in, id_out, telemetry
    );
endinterface : rflags_id_if


// ============================================================================
// Declaração do Módulo do Bit ID (Sem Implementação Interna)
// ============================================================================
module rflags_id_bit (
    input  logic                          clk,
    input  logic                          rst_n,
    input  logic                          id_write_en,
    input  rflags_id_pkg::id_update_mode_e update_mode,
    input  logic                          id_direct_in,
    output logic                          id_out,
    output rflags_id_pkg::id_telemetry_t  telemetry
);
    // A lógica interna de escrita e verificação da capacidade de alternância
    // do bit ID para validar o suporte à instrução CPUID
    // será implementada no arquivo .sv correspondente.
endmodule : rflags_id_bit

`endif // RFLAGS_ID_SVH
