// ===========================================================================
// File: headers/registers/rflags/ac.svh
// Project: x86_64 Hardware Architecture Implementation
// Author: Pedro Emanuel
// License: GPL-3.0-only
//
// Description: Declaration of packages, data types, bit structures,
// telemetry, interfaces and module signature for the logger
// RFLAGS, with special emphasis on the Alignment Check (AC) bit
// and state/control flags (Intel 64 / AMD64 Architecture).
// ===========================================================================

`ifndef RFLAGS_AC_SVH
`define RFLAGS_AC_SVH

package rflags_ac_pkg;

    // Posição exata do bit AC no registrador RFLAGS
    localparam int RFLAGS_AC_BIT_INDEX = 18;

    // Enumeração dos Tamanhos de Acesso à Memória para Verificação de Alinhamento
    typedef enum logic [2:0] {
        MEM_ACCESS_BYTE     = 3'b000, // 1 Byte  (Sempre alinhado)
        MEM_ACCESS_WORD     = 3'b001, // 2 Bytes (Alinhado em múltiplos de 2)
        MEM_ACCESS_DWORD    = 3'b010, // 4 Bytes (Alinhado em múltiplos de 4)
        MEM_ACCESS_QWORD    = 3'b011, // 8 Bytes (Alinhado em múltiplos de 8)
        MEM_ACCESS_DQWORD   = 3'b100  // 16 Bytes / XMM (Alinhado em múltiplos de 16)
    } mem_access_size_e;

    // Nível de Privilégio (CPL - Current Privilege Level)
    typedef enum logic [1:0] {
        RING_0 = 2'b00, // Kernel Mode
        RING_1 = 2'b01,
        RING_2 = 2'b10,
        RING_3 = 2'b11  // User Mode (O bit AC gera #AC apenas em Ring 3)
    } privilege_level_e;

    // Estrutura do Estado e Telemetria do Bit AC
    typedef struct packed {
        logic ac_bit_value;      // Valor atual do RFLAGS.AC (bit 18)
        logic alignment_check_en;// Ativado se (AC == 1) AND (CPL == Ring 3) AND (CR0.AM == 1)
        logic exception_ac_trigger; // Sinal de disparo imediato para a exceção #AC
    } ac_telemetry_t;

endpackage : rflags_ac_pkg


// ============================================================================
// Interface Exclusiva para Monitoramento e Checagem de Alinhamento (#AC)
// ============================================================================
interface rflags_ac_if (
    input logic clk,
    input logic rst_n
);
    import rflags_ac_pkg::*;

    // Sinais da Interface
    logic               ac_write_en;   // Habilita escrita direta no bit AC
    logic               ac_in;         // Valor a ser gravado em AC
    logic               ac_out;        // Valor atual lido de AC
    
    // Entradas do Sistema para Avaliação de Exceção #AC
    privilege_level_e   cpl;           // Nível de privilégio atual
    logic               cr0_am;        // Control Register 0 - Alignment Mask bit
    logic [63:0]        mem_addr;      // Endereço de memória sendo acessado
    mem_access_size_e   mem_size;      // Tamanho do acesso
    logic               mem_req;       // Sinal de requisição de memória
    
    // Saída de Exceção
    ac_telemetry_t      telemetry;

    // Modport para o Submódulo do Bit AC
    modport ACUnit (
        input  clk, rst_n, ac_write_en, ac_in, cpl, cr0_am, mem_addr, mem_size, mem_req,
        output ac_out, telemetry
    );

    // Modport para a Memory Management Unit (MMU) / Pipeline Controller
    modport Controller (
        input  clk, rst_n, ac_out, telemetry,
        output ac_write_en, ac_in, cpl, cr0_am, mem_addr, mem_size, mem_req
    );

    // Modport para Testbench e Monitoramento
    modport Monitor (
        input clk, rst_n, ac_write_en, ac_in, ac_out, cpl, cr0_am, mem_addr, mem_size, mem_req, telemetry
    );
endinterface : rflags_ac_if


// ============================================================================
// Declaração do Módulo do Bit AC (Sem Implementação Interna)
// ============================================================================
module rflags_ac_bit (
    input  logic                          clk,
    input  logic                          rst_n,
    input  logic                          ac_write_en,
    input  logic                          ac_in,
    input  rflags_ac_pkg::privilege_level_e cpl,
    input  logic                          cr0_am,
    input  logic [63:0]                   mem_addr,
    input  rflags_ac_pkg::mem_access_size_e mem_size,
    input  logic                          mem_req,
    output logic                          ac_out,
    output rflags_ac_pkg::ac_telemetry_t  telemetry
);
    // A lógica interna de verificação do desalinhamento de memória:
    // (ex: endereço ímpar em acesso WORD, endereço não múltiplo de 4 em DWORD, etc.)
    // e o disparo da exceção #AC serão implementados no arquivo .sv correspondente.
endmodule : rflags_ac_bit

`endif // RFLAGS_AC_SVH
