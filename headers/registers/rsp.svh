`ifndef __HEADERS_REGISTERS_RSP_SV__
`define __HEADERS_REGISTERS_RSP_SV__
package rsp_pkg;

    // ------------------------------------------------------------------------
    // Mapeamento dos Modos de Acesso ao Registrador RSP
    // ------------------------------------------------------------------------
    typedef enum logic [2:0] {
        RSP_ACCESS_64BIT = 3'b000, // RSP : Acesso completo [63:0]
        RSP_ACCESS_32BIT = 3'b001, // ESP : Acesso aos 32 bits inferiores [31:0] (Zera bits [63:32])
        RSP_ACCESS_16BIT = 3'b010, // SP  : Acesso aos 16 bits inferiores [15:0] (Preserva bits superiores)
        RSP_ACCESS_8BIT_L= 3'b011  // SPL : Acesso ao byte inferior [7:0] (Via prefixo REX, preserva bits superiores)
    } rsp_access_mode_e;

    // ------------------------------------------------------------------------
    // Máscaras de Bits para Operações de Leitura/Escrita
    // ------------------------------------------------------------------------
    localparam logic [63:0] RSP_MASK_64BIT  = 64'hFFFF_FFFF_FFFF_FFFF;
    localparam logic [63:0] RSP_MASK_32BIT  = 64'h0000_0000_FFFF_FFFF;
    localparam logic [63:0] RSP_MASK_16BIT  = 64'h0000_0000_0000_FFFF;
    localparam logic [63:0] RSP_MASK_8BIT_L = 64'h0000_0000_0000_00FF;

    // ------------------------------------------------------------------------
    // Estruturas de Decomposição de Registradores (Layout x86_64)
    // ------------------------------------------------------------------------
    typedef struct packed {
        logic [31:0] high_dword; // Bits [63:32] - Acessível apenas em modo 64-bit
        logic [15:0] high_word;  // Bits [31:16] - Metade superior de ESP
        logic [7:0]  mid_byte;   // Bits [15:8]  - Bits superiores de SP
        logic [7:0]  spl;        // Bits [7:0]   - Registrador SPL
    } rsp_fields_t;

    // Mapeamento Byte a Byte para Depuração e Decodificação de Microcódigo
    typedef struct packed {
        logic [7:0] byte7; // Bits [63:56]
        logic [7:0] byte6; // Bits [55:48]
        logic [7:0] byte5; // Bits [47:40]
        logic [7:0] byte4; // Bits [39:32]
        logic [7:0] byte3; // Bits [31:24]
        logic [7:0] byte2; // Bits [23:16]
        logic [7:0] byte1; // Bits [15:8]
        logic [7:0] spl;   // Bits [7:0]
    } rsp_byte_map_t;

    // União para Múltiplas Visões de Memória do Registrador RSP
    typedef union packed {
        logic [63:0]   rsp;       // Visão 64 bits
        logic [31:0]   esp;       // Visão 32 bits
        logic [15:0]   sp;        // Visão 16 bits
        rsp_fields_t   fields;    // Visão por subdivisões
        rsp_byte_map_t bytes;     // Visão por bytes individuais
    } rsp_reg_u;

    // ------------------------------------------------------------------------
    // Estrutura de Telemetria e Monitoramento de Estado
    // ------------------------------------------------------------------------
    typedef struct packed {
        logic        is_zero;     // Indicador de valor zero
        logic        is_negative; // Bit de sinal [63]
        logic [63:0] value;       // Valor armazenado atual
    } rsp_status_t;

endpackage : rsp_pkg


// ============================================================================
// Interface SystemVerilog para o Registrador RSP
// ============================================================================
interface rsp_if (
    input logic clk,
    input logic rst_n
);
    import rsp_pkg::*;

    // Sinais da Interface
    logic               wr_en;
    rsp_access_mode_e   access_mode;
    logic [63:0]        din;
    logic [63:0]        dout;
    rsp_status_t        status;

    // Modport para a Unidade do Registrador
    modport Register (
        input  clk,
        input  rst_n,
        input  wr_en,
        input  access_mode,
        input  din,
        output dout,
        output status
    );

    // Modport para o Decodificador / Unidade Executora
    modport Controller (
        input  clk,
        input  rst_n,
        output wr_en,
        output access_mode,
        output din,
        input  dout,
        input  status
    );

    // Modport para Testbench e Telemetria
    modport Monitor (
        input clk,
        input rst_n,
        input wr_en,
        input access_mode,
        input din,
        input dout,
        input status
    );
endinterface : rsp_if


// ============================================================================
// Declaração do Módulo Principal (Sem Implementação Interna)
// ============================================================================
module rsp_register (
    input  logic                   clk,
    input  logic                   rst_n,
    input  logic                   wr_en,
    input  rsp_pkg::rsp_access_mode_e access_mode,
    input  logic [63:0]            din,
    output logic [63:0]            dout,
    output rsp_pkg::rsp_status_t   status
);
    // A implementação da lógica de controle de escrita e zero-extension 
    // deve ser mantida num arquivo separado (.sv).
endmodule : rsp_register

`endif // __HEADERS_REGISTERS_RSP_SV__
