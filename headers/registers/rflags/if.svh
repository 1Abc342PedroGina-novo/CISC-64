// ============================================================================
// File: headers/registers/rflags/if.svh
// Project: x86_64 Hardware Architecture Implementation
// Author: Pedro Emanuel
// License: GPL-3.0-only
//
// Description: Package, interface, and module dedicated exclusively to the
//              logic for the Interrupt Enable Flag (IF - RFLAGS[9]) bit and
//              control of maskable interrupts / APIC (Intel 64 / AMD64).
// ============================================================================

`ifndef RFLAGS_IF_SVH
`define RFLAGS_IF_SVH

package rflags_if_pkg;

    // Posição exata do bit IF no registrador RFLAGS
    localparam int RFLAGS_IF_BIT_INDEX = 9;

    // Modos de atualização do bit IF por instruções dedicadas (STI, CLI) ou controle
    typedef enum logic [1:0] {
        IF_OP_PASS  = 2'b00, // Mantém o valor atual do bit IF
        IF_OP_SET   = 2 meb01, // Força o bit IF em 1 (ex: instrução STI - habilita interrupções)
        IF_OP_CLEAR = 2'b10, // Zera o bit IF (0) (ex: instrução CLI - desabilita interrupções)
        IF_OP_WRITE = 2'b11  // Escrita direta (ex: restauração via POPF/POPFD/POPFQ ou IRET)
    } if_update_mode_e;

    // Nível de Privilégio (CPL vs IOPL)
    typedef enum logic [1:0] {
        RING_0 = 2'b00,
        RING_1 = 2'b01,
        RING_2 = 2'b10,
        RING_3 = 2'b11
    } privilege_level_e;

    // Estrutura de Telemetria e Status do Controle de Interrupções
    typedef struct packed {
        logic if_bit_value;        // Valor atual do RFLAGS.IF (bit 9)
        logic interrupts_enabled;  // Status de habilitação das interrupções mascaráveis (INTR)
        logic gpf_fault_trigger;   // Disparo de General Protection Fault (#GP) se CPL > IOPL ao executar STI/CLI
    } if_telemetry_t;

endpackage : rflags_if_pkg


// ============================================================================
// Interface Exclusiva para Monitoramento e Atualização do Interrupt Flag (IF)
// ============================================================================
interface rflags_if_ctrl_if (
    input logic clk,
    input logic rst_n
);
    import rflags_if_pkg::*;

    // Sinais de Controle
    logic               if_write_en;   // Habilita escrita/atualização no bit IF
    if_update_mode_e    update_mode;   // Modo de operação (Set, Clear, Pass, Write)
    logic               if_direct_in;  // Valor de escrita direta (ex: POPF/IRET)
    privilege_level_e   cpl;           // Current Privilege Level
    logic [1:0]         iopl;          // I/O Privilege Level (RFLAGS[13:12])
    logic               if_out;        // Valor atual do bit IF
    
    // Telemetria do Estado da Unidade
    if_telemetry_t      telemetry;

    // Modport para o Submódulo do Bit IF
    modport IFUnit (
        input  clk, rst_n, if_write_en, update_mode, if_direct_in, cpl, iopl,
        output if_out, telemetry
    );

    // Modport para o Interrupt Controller / APIC / Sequenciador de Microcódigo
    modport Controller (
        input  clk, rst_n, if_out, telemetry,
        output if_write_en, update_mode, if_direct_in, cpl, iopl
    );

    // Modport para Testbench e Monitoramento
    modport Monitor (
        input clk, rst_n, if_write_en, update_mode, if_direct_in, cpl, iopl, if_out, telemetry
    );
endinterface : rflags_if_ctrl_if


// ============================================================================
// Declaração do Módulo do Bit IF (Sem Implementação Interna)
// ============================================================================
module rflags_if_bit (
    input  logic                          clk,
    input  logic                          rst_n,
    input  logic                          if_write_en,
    input  rflags_if_pkg::if_update_mode_e update_mode,
    input  logic                          if_direct_in,
    input  rflags_if_pkg::privilege_level_e cpl,
    input  logic [1:0]                    iopl,
    output logic                          if_out,
    output rflags_if_pkg::if_telemetry_t  telemetry
);
    // A lógica interna de validação de privilégio (CPL <= IOPL) para instruções
    // STI/CLI e mascaramento de interrupções físicas de hardware
    // será implementada no arquivo .sv correspondente.
endmodule : rflags_if_bit

`endif // RFLAGS_IF_SVH
