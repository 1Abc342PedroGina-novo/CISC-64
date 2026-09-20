// ============================================================================
// File: headers/registers/rflags/vip.svh
// Project: x86_64 Hardware Architecture Implementation
// Author: Pedro Emanuel
// License: GPL-3.0-only
//
// Description: Package, interface, and module dedicated exclusively to the
//              logic for the Virtual Interrupt Pending bit (VIP - RFLAGS[20]),
//              used in protected mode extensions (PME) and Virtual-8086 mode
//              to signal that a virtual interrupt is pending (Intel 64 / AMD64).
// ============================================================================

`ifndef RFLAGS_VIP_SVH
`define RFLAGS_VIP_SVH

package rflags_vip_pkg;

    // Posição exata do bit VIP no registrador RFLAGS
    localparam int RFLAGS_VIP_BIT_INDEX = 20;

    // Modos de atualização do bit VIP
    typedef enum logic [1:0] {
        VIP_OP_PASS  = 2'b00, // Mantém o valor atual do bit VIP
        VIP_OP_SET   = 2'b01, // Força VIP em 1 (sinaliza interrupção virtual pendente)
        VIP_OP_CLEAR = 2'b10, // Zera VIP (interrupção tratada / limpa pelo SO)
        VIP_OP_WRITE = 2'b11  // Escrita direta (ex: restauração via POPF/POPFD/POPFQ ou IRET)
    } vip_update_mode_e;

    // Estrutura de Telemetria e Diagnóstico do Bit VIP
    typedef struct packed {
        logic vip_bit_value;          // Valor atual do RFLAGS.VIP (bit 20)
        logic virt_interrupt_pending; // Indicador de interrupção virtual pendente (VIP=1)
        logic gpf_fault_trigger;      // Sinaliza disparo de #GP se STI for executado com VIP=1 e VIF=0 em modo virtual
    } vip_telemetry_t;

endpackage : rflags_vip_pkg


// ============================================================================
// Interface Exclusiva para Monitoramento e Atualização do Virtual Interrupt Pending (VIP)
// ============================================================================
interface rflags_vip_if (
    input logic clk,
    input logic rst_n
);
    import rflags_vip_pkg::*;

    // Sinais de Controle
    logic               vip_write_en;   // Habilita escrita/atualização no bit VIP
    vip_update_mode_e   update_mode;    // Modo de operação (Pass, Set, Clear, Write)
    logic               vip_direct_in;  // Valor de escrita direta (ex: POPFQ/IRET)
    
    // Controles do Sistema e Estado da CPU
    logic               cr4_pvi;        // Protected-Mode Virtual Interrupts (CR4[1])
    logic               cr4_vme;        // Virtual-8086 Mode Extensions (CR4[0])
    logic               vif_val;        // Valor atual do bit VIF (RFLAGS[19])
    
    // Saídas
    logic               vip_out;        // Valor atual do bit VIP
    vip_telemetry_t     telemetry;

    // Modport para o Submódulo do Bit VIP
    modport VIPUnit (
        input  clk, rst_n, vip_write_en, update_mode, vip_direct_in, cr4_pvi, cr4_vme, vif_val,
        output vip_out, telemetry
    );

    // Modport para a Unidade de Controle / Microcódigo / Virtualização
    modport Controller (
        input  clk, rst_n, vip_out, telemetry,
        output vip_write_en, update_mode, vip_direct_in, cr4_pvi, cr4_vme, vif_val
    );

    // Modport para Testbench e Monitoramento
    modport Monitor (
        input clk, rst_n, vip_write_en, update_mode, vip_direct_in, cr4_pvi, cr4_vme, vif_val,
              vip_out, telemetry
    );
endinterface : rflags_vip_if


// ============================================================================
// Declaração do Módulo do Bit VIP (Sem Implementação Interna)
// ============================================================================
module rflags_vip_bit (
    input  logic                           clk,
    input  logic                           rst_n,
    input  logic                           vip_write_en,
    input  rflags_vip_pkg::vip_update_mode_e update_mode,
    input  logic                           vip_direct_in,
    input  logic                           cr4_pvi,
    input  logic                           cr4_vme,
    input  logic                           vif_val,
    output logic                           vip_out,
    output rflags_vip_pkg::vip_telemetry_t telemetry
);
    // A lógica interna de gerenciamento do bit VIP, checagem de exceção #GP
    // e interação com o VIF/CR4 será implementada no arquivo .sv correspondente.
endmodule : rflags_vip_bit

`endif // RFLAGS_VIP_SVH
