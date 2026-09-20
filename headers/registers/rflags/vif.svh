// ============================================================================
// File: headers/registers/rflags/vif.svh
// Project: x86_64 Hardware Architecture Implementation
// Author: Pedro Emanuel
// License: GPL-3.0-only
//
// Description: Package, interface, and module dedicated exclusively to the
//              logic for the Virtual Interrupt Flag (VIF - RFLAGS[19]) bit,
//              used in Protected Mode Extensions (PME) and Virtual-8086 mode
//              for the virtualization of maskable interrupts (Intel 64 / AMD64).
// ============================================================================

`ifndef RFLAGS_VIF_SVH
`define RFLAGS_VIF_SVH

package rflags_vif_pkg;

    // Posição exata do bit VIF no registrador RFLAGS
    localparam int RFLAGS_VIF_BIT_INDEX = 19;

    // Modos de atualização do bit VIF
    typedef enum logic [1:0] {
        VIF_OP_PASS  = 2'b00, // Mantém o valor atual do bit VIF
        VIF_OP_SET   = 2'b01, // Força VIF em 1 (ex: instrução STI quando CR4.PVI/VME está ativo)
        VIF_OP_CLEAR = 2'b10, // Zera VIF (ex: instrução CLI quando CR4.PVI/VME está ativo)
        VIF_OP_WRITE = 2'b11  // Escrita direta (ex: restauração via POPF/POPFD/POPFQ ou IRET)
    } vif_update_mode_e;

    // Estrutura de Telemetria e Diagnóstico do Bit VIF
    typedef struct packed {
        logic vif_bit_value;          // Valor atual do RFLAGS.VIF (bit 19)
        logic virt_interrupt_enabled; // Status de interrupções virtuais habilitadas (VIF=1)
    } vif_telemetry_t;

endpackage : rflags_vif_pkg


// ============================================================================
// Interface Exclusiva para Monitoramento e Atualização do Virtual Interrupt Flag (VIF)
// ============================================================================
interface rflags_vif_if (
    input logic clk,
    input logic rst_n
);
    import rflags_vif_pkg::*;

    // Sinais de Controle
    logic               vif_write_en;   // Habilita escrita/atualização no bit VIF
    vif_update_mode_e   update_mode;    // Modo de operação (Pass, Set, Clear, Write)
    logic               vif_direct_in;  // Valor de escrita direta (ex: POPFQ/IRET)
    
    // Controles do Sistema
    logic               cr4_pvi;        // Protected-Mode Virtual Interrupts (CR4[1])
    logic               cr4_vme;        // Virtual-8086 Mode Extensions (CR4[0])
    
    // Saídas
    logic               vif_out;        // Valor atual do bit VIF
    vif_telemetry_t     telemetry;

    // Modport para o Submódulo do Bit VIF
    modport VIFUnit (
        input  clk, rst_n, vif_write_en, update_mode, vif_direct_in, cr4_pvi, cr4_vme,
        output vif_out, telemetry
    );

    // Modport para a Unidade de Controle / Microcódigo / Virtualização
    modport Controller (
        input  clk, rst_n, vif_out, telemetry,
        output vif_write_en, update_mode, vif_direct_in, cr4_pvi, cr4_vme
    );

    // Modport para Testbench e Monitoramento
    modport Monitor (
        input clk, rst_n, vif_write_en, update_mode, vif_direct_in, cr4_pvi, cr4_vme,
              vif_out, telemetry
    );
endinterface : rflags_vif_if


// ============================================================================
// Declaração do Módulo do Bit VIF (Sem Implementação Interna)
// ============================================================================
module rflags_vif_bit (
    input  logic                           clk,
    input  logic                           rst_n,
    input  logic                           vif_write_en,
    input  rflags_vif_pkg::vif_update_mode_e update_mode,
    input  logic                           vif_direct_in,
    input  logic                           cr4_pvi,
    input  logic                           cr4_vme,
    output logic                           vif_out,
    output rflags_vif_pkg::vif_telemetry_t telemetry
);
    // A lógica interna de modificação do bit VIF e checagem das extensões PVI/VME
    // do CR4 será implementada no arquivo .sv correspondente.
endmodule : rflags_vif_bit

`endif // RFLAGS_VIF_SVH
