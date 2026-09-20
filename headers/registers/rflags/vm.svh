
// ============================================================================
// File: headers/registers/rflags/vm.svh
// Project: x86_64 Hardware Architecture Implementation
// Author: Pedro Emanuel
// License: GPL-3.0-only
//
// Description: Package, interface, and module dedicated exclusively to the
//              logic for the Virtual-8086 Mode bit (VM - RFLAGS[17]),
//              responsible for enabling 16-bit Real Mode emulation within
//              a protected task (Intel 64 / AMD64).
//
// ARCHITECTURAL NOTE: In Long Mode (64-bit), the VM bit is inactive and forced to 0.
// ============================================================================

`ifndef RFLAGS_VM_SVH
`define RFLAGS_VM_SVH

package rflags_vm_pkg;

    // Posição exata do bit VM no registrador RFLAGS
    localparam int RFLAGS_VM_BIT_INDEX = 17;

    // Modos de operação da CPU em relação ao suporte do Virtual-8086 Mode
    typedef enum logic [1:0] {
        CPU_MODE_PROTECTED    = 2'b00, // Modo Protegido (Permite ativação do VM)
        CPU_MODE_REAL         = 2'b01, // Modo Real (VM não aplicável)
        CPU_MODE_COMPATIBILITY= 2'b10, // Modo de Compatibilidade
        CPU_MODE_LONG         = 2'b11  // Long Mode 64-bit (VM é forçado a 0 e ignorado)
    } cpu_execution_mode_e;

    // Modos de atualização do bit VM (pode ser alterado via IRET ou Task Switch no Ring 0)
    typedef enum logic [1:0] {
        VM_OP_PASS  = 2'b00, // Mantém o valor atual do bit VM
        VM_OP_SET   = 2'b01, // Força VM em 1 (Ativa modo Virtual-8086 se CPL=0)
        VM_OP_CLEAR = 2'b10, // Zera VM (Retorna ao modo protegido normal)
        VM_OP_WRITE = 2'b11  // Escrita direta (ex: restauração via IRET no Ring 0)
    } vm_update_mode_e;

    // Estrutura de Telemetria e Diagnóstico do Bit VM
    typedef struct packed {
        logic vm_bit_value;        // Valor atual do RFLAGS.VM (bit 17)
        logic v8086_active;        // Indicador de que o modo Virtual-8086 está ativo
        logic vm_disabled_in_lm;   // Sinaliza que o modo VM está desabilitado por estar em Long Mode
    } vm_telemetry_t;

endpackage : rflags_vm_pkg


// ============================================================================
// Interface Exclusiva para Monitoramento e Atualização do Virtual-8086 Flag (VM)
// ============================================================================
interface rflags_vm_if (
    input logic clk,
    input logic rst_n
);
    import rflags_vm_pkg::*;

    // Sinais de Controle e Estado da CPU
    logic                 vm_write_en;   // Habilita escrita/atualização no bit VM
    vm_update_mode_e      update_mode;   // Modo de operação (Pass, Set, Clear, Write)
    logic                 vm_direct_in;  // Valor de escrita direta (ex: IRET stack frame)
    logic [1:0]           cpl;           // Current Privilege Level (Apenas CPL=0 pode alterar VM)
    cpu_execution_mode_e  cpu_mode;      // Modo de execução da CPU
    
    // Saídas
    logic                 vm_out;        // Valor atual do bit VM
    vm_telemetry_t        telemetry;

    // Modport para o Submódulo do Bit VM
    modport VMUnit (
        input  clk, rst_n, vm_write_en, update_mode, vm_direct_in, cpl, cpu_mode,
        output vm_out, telemetry
    );

    // Modport para a Unidade de Controle / Sequenciador de Microcódigo / Proteção
    modport Controller (
        input  clk, rst_n, vm_out, telemetry,
        output vm_write_en, update_mode, vm_direct_in, cpl, cpu_mode
    );

    // Modport para Testbench e Monitoramento
    modport Monitor (
        input clk, rst_n, vm_write_en, update_mode, vm_direct_in, cpl, cpu_mode,
              vm_out, telemetry
    );
endinterface : rflags_vm_if


// ============================================================================
// Declaração do Módulo do Bit VM (Sem Implementação Interna)
// ============================================================================
module rflags_vm_bit (
    input  logic                          clk,
    input  logic                          rst_n,
    input  logic                          vm_write_en,
    input  rflags_vm_pkg::vm_update_mode_e update_mode,
    input  logic                          vm_direct_in,
    input  logic [1:0]                    cpl,
    input  rflags_vm_pkg::cpu_execution_mode_e cpu_mode,
    output logic                          vm_out,
    output rflags_vm_pkg::vm_telemetry_t  telemetry
);
    // A lógica interna de validação de privilégio (somente CPL=0 pode modificar VM)
    // e o zeramento forçado quando em Long Mode (64-bit) serão implementados
    // no arquivo .sv correspondente.
endmodule : rflags_vm_bit

`endif // RFLAGS_VM_SVH
