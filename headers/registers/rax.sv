// =============================================================================
// SPDX License Indentifier: GPL-3.0
// Copyright (C) Pedro Emanuel
// file : headers/registers/rax.sv
// =============================================================================

ifndef __HEADERS_REGISTERS_RAX_SV__
`define __HEADERS_REGISTERS_RAX_SV__

package rax_pkg;

    // Definição da estrutura interna do RAX respeitando a hierarquia x86_64
    typedef union packed {
        logic [63:0] rax; // Registrador completo de 64 bits (Modo Longo)
        
        struct packed {
            logic [31:0] reserved_high; // Parte alta não acessível diretamente por sub-nomes
            logic [31:0] eax;           // Extensão de 32 bits (Modo Protegido)
        } bits32;

        struct packed {
            logic [47:0] reserved_ax;
            logic [15:0] ax;            // Registrador clássico de 16 bits
        } bits16;

        struct packed {
            logic [47:0] reserved_bytes;
            logic [7:0]  ah;            // Byte Alto (Bits 15:8)
            logic [7:0]  al;            // Byte Baixo (Bits 7:0)
        } bits8;
    } rax_reg_t;

    // Enumeração para controle de mascaramento de tamanho de operando (Philosophy-Like)
    typedef enum logic [1:0] {
        OPSIZE_8   = 2'b00,
        OPSIZE_16  = 2'b01,
        OPSIZE_32  = 2'b10,
        OPSIZE_64  = 2'b11
    } operand_size_e;

    // Estrutura de Contexto de Exceção Arquitetural do Registrador
    typedef struct packed {
        logic        page_fault_status;
        logic        alignment_check_fail;
        logic [2:0]  privilege_level; // CPL (Current Privilege Level) simulado
    } rax_status_t;

    // Prototipação de funções arquiteturais (Definições de assinaturas de API)
    // Nota: Em SystemVerilog, funções dentro de pacotes que atuam como interfaces 
    // virtuais de hardware são declaradas como "extern" quando implementadas em outra camada.
    extern function automatic logic [63:0] filter_operand_mask(input logic [63:0] value, input operand_size_e size);
    extern function automatic logic check_canonical_address(input logic [63:0] address);

endpackage : rax_pkg


// =============================================================================
// Declaração da Interface de Conectividade do Registrador RAX
// =============================================================================
interface rax_bus_if (input logic clk, input logic rst_n);
    import rax_pkg::*;

    // Sinais de Controle e Dados
    logic [63:0]        wdata;
    logic [63:0]        rdata;
    operand_size_e      op_size;
    logic               write_en;
    logic               read_en;
    rax_status_t        arch_status;

    // Modports para isolamento de privilégio de acesso (Execution Core vs Register File)
    modport exec_core (
        output wdata, op_size, write_en, read_en,
        input  rdata, arch_status
    );

    modport reg_file (
        input  wdata, op_size, write_en, read_en,
        output rdata, arch_status
    );
endinterface : rax_bus_if


// =============================================================================
// Declaração do Módulo Arquitetural RAX (Módulo Caixa-Preta / Sem Implementação)
// =============================================================================
module rax_register_subsystem (
    rax_bus_if.reg_file bus,
    input logic               flush_pipeline,
    input logic               speculative_mode,
    output logic              rax_ready
);
    // O escopo interno permanece vazio ou apenas com asserções formais de barramento.
    // A lógica de controle Intel/AMD-Like (como o comportamento de zerar a parte alta 
    // de 64 bits quando o EAX de 32 bits é escrito) será codificada no arquivo de implementação (.sv).

    // Exemplo de Asserção de Interface (Propriedade Arquitetural Pre-definida)
    property p_no_simultaneous_read_write;
        @(posedge bus.clk) disable iff (!bus.rst_n)
        !(bus.write_en && bus.read_en);
    endproperty
    assert property (p_no_simultaneous_read_write);

endmodule : rax_register_subsystem

`endif // __HEADERS_REGISTERS_RAX_SV__
