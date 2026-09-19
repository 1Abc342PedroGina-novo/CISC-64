// ============================================================================
// File: headers/registers/rflags/iopl.svh
// Project: x86_64 Hardware Architecture Implementation
// Author: Pedro Emanuel
// License: GPL-3.0-only
//
// Description: Package, interface, and module dedicated exclusively to the
//              logic for the I/O Privilege Level (IOPL - RFLAGS[13:12]) field
//              and the control of I/O permissions and privileged instructions
//              (Intel 64 / AMD64).
// ============================================================================

`ifndef RFLAGS_IOPL_SVH
`define RFLAGS_IOPL_SVH

package rflags_iopl_pkg;

    // Posições e largura do campo IOPL no registrador RFLAGS
    localparam int RFLAGS_IOPL_LSB_INDEX = 12;
    localparam int RFLAGS_IOPL_MSB_INDEX = 13;
    localparam int RFLAGS_IOPL_WIDTH     = 2;

    // Modos de atualização do campo IOPL
    typedef enum logic [1:0] {
        IOPL_OP_PASS  = 2'b00, // Mantém o valor atual do campo IOPL
        IOPL_OP_WRITE = 2'b01, // Tenta escrever novo valor (ex: via POPF/POPFD/POPFQ ou IRET)
        IOPL_OP_CLEAR = 2'b10, // Zera o campo IOPL (Ring 0)
        IOPL_OP_SET_MAX = 2'b11// Força IOPL para Ring 3 (3)
    } iopl_update_mode_e;

    // Níveis de Privilégio do x86 (Rings 0 a 3)
    typedef enum logic [1:0] {
        RING_0 = 2'b00, // Kernel / Privilégio Máximo
        RING_1 = 2'b01, // Drivers de Dispositivo
        RING_2 = 2'b10, // Serviços do Sistema
        RING_3 = 2'b11  // Aplicação de Usuário / Menor Privilégio
    } privilege_level_e;

    // Estrutura de Telemetria e Verificação de Permissões de E/S
    typedef struct packed {
        logic [1:0]       iopl_value;         // Valor atual do RFLAGS.IOPL (bits 13:12)
        logic             io_access_allowed;  // 1: CPL <= IOPL (Permite instruções de I/O como IN/OUT, STI/CLI, CLI)
        privilege_level_e current_cpl;        // Nível de privilégio atual
    } iopl_telemetry_t;

endpackage : rflags_iopl_pkg


// ============================================================================
// Interface Exclusiva para Monitoramento e Atualização do IOPL (RFLAGS[13:12])
// ============================================================================
interface rflags_iopl_if (
    input logic clk,
    input logic rst_n
);
    import rflags_iopl_pkg::*;

    // Sinais de Controle
    logic                 iopl_write_en;   // Habilita tentativa de escrita no campo IOPL
    iopl_update_mode_e    update_mode;     // Modo de operação (Pass, Write, Clear, Set Max)
    logic [1:0]           iopl_direct_in;  // Valor de escrita direta (ex: POPFQ/IRET)
    privilege_level_e     cpl;             // Current Privilege Level do processador
    logic [1:0]           iopl_out;        // Valor atual do campo IOPL
    
    // Telemetria do Estado da Unidade
    iopl_telemetry_t      telemetry;

    // Modport para o Submódulo do Campo IOPL
    modport IOPLUnit (
        input  clk, rst_n, iopl_write_en, update_mode, iopl_direct_in, cpl,
        output iopl_out, telemetry
    );

    // Modport para o Decoder de Instruções / Unidade de Proteção / Microcódigo
    modport Controller (
        input  clk, rst_n, iopl_out, telemetry,
        output iopl_write_en, update_mode, iopl_direct_in, cpl
    );

    // Modport para Testbench e Monitoramento
    modport Monitor (
        input clk, rst_n, iopl_write_en, update_mode, iopl_direct_in, cpl, iopl_out, telemetry
    );
endinterface : rflags_iopl_if


// ============================================================================
// Declaração do Módulo do Campo IOPL (Sem Implementação Interna)
// ============================================================================
module rflags_iopl_bits (
    input  logic                            clk,
    input  logic                            rst_n,
    input  logic                            iopl_write_en,
    input  rflags_iopl_pkg::iopl_update_mode_e update_mode,
    input  logic [1:0]                      iopl_direct_in,
    input  rflags_iopl_pkg::privilege_level_e cpl,
    output logic [1:0]                      iopl_out,
    output rflags_iopl_pkg::iopl_telemetry_t  telemetry
);
    // A lógica interna de validação de modificação (IOPL só pode ser modificado
    // quando CPL = 0) e checagem de privilégios de I/O
    // serão implementadas no arquivo .sv correspondente.
endmodule : rflags_iopl_bits

`endif // RFLAGS_IOPL_SVH
