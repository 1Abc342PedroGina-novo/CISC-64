`ifndef ZMM_REGISTERS_PKG_SVH
`define ZMM_REGISTERS_PKG_SVH

package ymm_pkg;

    // ------------------------------------------------------------------------
    // Índice do Registrador Vetorial YMM (YMM0 até YMM31 em AVX-512)
    // ------------------------------------------------------------------------
    typedef logic [4:0] ymm_id_t;

    // ------------------------------------------------------------------------
    // Modos de Acesso aos Sub-registradores
    // ------------------------------------------------------------------------
    typedef enum logic [1:0] {
        YMM_ACCESS_256BIT = 2'b00, // YMM : Acesso completo [255:0]
        YMM_ACCESS_128BIT = 2 meb01, // XMM : Acesso aos 128 bits inferiores [127:0] (Zera bits superiores em VEX)
        YMM_ACCESS_64BIT  = 2'b10, // MMX/Scalar Double : Acesso aos 64 bits inferiores [63:0]
        YMM_ACCESS_32BIT  = 2'b11  // Scalar Single : Acesso aos 32 bits inferiores [31:0]
    } ymm_access_mode_e;

    // ------------------------------------------------------------------------
    // Estruturas de Decomposição Vetorial (AVX/AVX2 Data Types)
    // ------------------------------------------------------------------------
    // Visão de 128 bits (XMM)
    typedef struct packed {
        logic [127:0] ymm_hi; // Bits [255:128] - Metade superior do YMM
        logic [127:0] xmm_lo; // Bits [127:0]   - Registrador XMM correspondente
    } ymm_xmm_split_t;

    // Visão de Ponto Flutuante (Single e Double Precision)
    typedef struct packed {
        logic [63:0] [31:0] fp32; // 8x Float Single-Precision (32-bit)
    } ymm_fp32_vec_t;

    typedef struct packed {
        logic [3:0] [63:0]  fp64; // 4x Float Double-Precision (64-bit)
    } ymm_fp64_vec_t;

    // Visão de Inteiros Vetoriais (SIMD Integer)
    typedef struct packed {
        logic [31:0] [7:0]  int8;  // 32x Inteiros de 8 bits
        logic [15:0] [15:0] int16; // 16x Inteiros de 16 bits
        logic [7:0]  [31:0] int32; // 8x Inteiros de 32 bits
        logic [3:0]  [63:0] int64; // 4x Inteiros de 64 bits
    } ymm_int_vec_t;

    // União para Múltiplas Visões de Memória do Registrador YMM
    typedef union packed {
        logic [255:0]   raw;     // Visão bruta de 256 bits
        ymm_xmm_split_t xmm;     // Visão dividida XMM_HI/XMM_LO
        ymm_fp32_vec_t  fp32;    // Vector Float 32
        ymm_fp64_vec_t  fp64;    // Vector Float 64
        ymm_int_vec_t   integers;// Vector Integers
    } ymm_reg_u;

    // ------------------------------------------------------------------------
    // Telemetria e Monitoramento de Estado Vetorial
    // ------------------------------------------------------------------------
    typedef struct packed {
        logic         is_zero;    // Indicador se todo o registrador YMM é zero
        logic [255:0] value;      // Valor atual armazenado
    } ymm_status_t;

endpackage : ymm_pkg


// ============================================================================
// Macro para Geração Dinâmica da Interface SystemVerilog para Registradores YMM
// ============================================================================
`define DEFINE_YMM_REG_INTERFACE(REG_NAME) \
interface ``REG_NAME``_if ( \
    input logic clk, \
    input logic rst_n \
); \
    import ymm_pkg::*; \
    logic               wr_en; \
    ymm_access_mode_e   access_mode; \
    logic [255:0]       din; \
    logic [255:0]       dout; \
    ymm_status_t        status; \
    \
    modport Register ( \
        input  clk, rst_n, wr_en, access_mode, din, \
        output dout, status \
    ); \
    modport Controller ( \
        input  clk, rst_n, dout, status, \
        output wr_en, access_mode, din \
    ); \
    modport Monitor ( \
        input clk, rst_n, wr_en, access_mode, din, dout, status \
    ); \
endinterface : ``REG_NAME``_if

// Declaração de Interface Padrão
`DEFINE_YMM_REG_INTERFACE(ymm)

`undef DEFINE_YMM_REG_INTERFACE


// ============================================================================
// Declaração do Módulo Principal do Registrador YMM (Sem Implementação Interna)
// ============================================================================
module ymm_register (
    input  logic                   clk,
    input  logic                   rst_n,
    input  logic                   wr_en,
    input  ymm_pkg::ymm_access_mode_e access_mode,
    input  logic [255:0]           din,
    output logic [255:0]           dout,
    output ymm_pkg::ymm_status_t   status
);
    // A implementação do controle de escrita e o zeramento automático dos
    // 128 bits superiores em escritas de 128 bits (modo VEX) devem ser
    // mantidos no arquivo .sv correspondente.
endmodule : ymm_register

package zmm_pkg;

    // ------------------------------------------------------------------------
    // Índice do Registrador Vetorial ZMM (ZMM0 até ZMM31 em AVX-512)
    // ------------------------------------------------------------------------
    typedef logic [4:0] zmm_id_t;

    // ------------------------------------------------------------------------
    // Modos de Acesso aos Sub-registradores Vetoriais
    // ------------------------------------------------------------------------
    typedef enum logic [2:0] {
        ZMM_ACCESS_512BIT = 3'b000, // ZMM : Acesso completo [512:0]
        ZMM_ACCESS_256BIT = 3'b001, // YMM : Acesso [255:0] (Zera bits [511:256] em EVEX)
        ZMM_ACCESS_128BIT = 3'b010, // XMM : Acesso [127:0] (Zera bits [511:128] em EVEX)
        ZMM_ACCESS_64BIT  = 3'b011, // Scalar Double : Acesso [63:0]
        ZMM_ACCESS_32BIT  = 3'b100  // Scalar Single : Acesso [31:0]
    } zmm_access_mode_e;

    // ------------------------------------------------------------------------
    // Estruturas de Decomposição Vetorial (AVX-512 Data Types)
    // ------------------------------------------------------------------------
    // Visão de Sub-registradores (YMM e XMM)
    typedef struct packed {
        logic [255:0] zmm_hi; // Bits [511:256] - Metade superior do ZMM
        logic [255:0] ymm_lo; // Bits [255:0]   - Registrador YMM correspondente
    } zmm_ymm_split_t;

    // Visão de Ponto Flutuante (AVX-512 Single, Double, FP16/BF16)
    typedef struct packed {
        logic [15:0] [31:0] fp32; // 16x Float Single-Precision (32-bit)
    } zmm_fp32_vec_t;

    typedef struct packed {
        logic [7:0]  [63:0] fp64; // 8x Float Double-Precision (64-bit)
    } zmm_fp64_vec_t;

    typedef struct packed {
        logic [31:0] [15:0] fp16; // 32x Half-Precision Float / Bfloat16
    } zmm_fp16_vec_t;

    // Visão de Inteiros Vetoriais (SIMD AVX-512BW / AVX-512F / AVX-512DQ)
    typedef struct packed {
        logic [63:0] [7:0]  int8;  // 64x Inteiros de 8 bits
        logic [31:0] [15:0] int16; // 32x Inteiros de 16 bits
        logic [15:0] [31:0] int32; // 16x Inteiros de 32 bits
        logic [7:0]  [63:0] int64; // 8x Inteiros de 64 bits
    } zmm_int_vec_t;

    // União para Múltiplas Visões de Memória do Registrador ZMM
    typedef union packed {
        logic [511:0]   raw;     // Visão bruta de 512 bits
        zmm_ymm_split_t ymm;     // Visão dividida ZMM_HI/YMM_LO
        zmm_fp32_vec_t  fp32;    // Vector Float 32
        zmm_fp64_vec_t  fp64;    // Vector Float 64
        zmm_fp16_vec_t  fp16;    // Vector Float 16
        zmm_int_vec_t   integers;// Vector Integers
    } zmm_reg_u;

    // ------------------------------------------------------------------------
    // Telemetria e Monitoramento de Estado Vetorial
    // ------------------------------------------------------------------------
    typedef struct packed {
        logic         is_zero;    // Indicador se todo o registrador ZMM é zero
        logic [511:0] value;      // Valor atual armazenado
    } zmm_status_t;

endpackage : zmm_pkg


// ============================================================================
// Macro para Geração Dinâmica da Interface SystemVerilog para Registradores ZMM
// ============================================================================
`define DEFINE_ZMM_REG_INTERFACE(REG_NAME) \
interface ``REG_NAME``_if ( \
    input logic clk, \
    input logic rst_n \
); \
    import zmm_pkg::*; \
    logic               wr_en; \
    zmm_access_mode_e   access_mode; \
    logic [7:0]         opmask;        // Opmask k0-k7 para escrita mascarada (EVEX) \
    logic [511:0]       din; \
    logic [511:0]       dout; \
    zmm_status_t        status; \
    \
    modport Register ( \
        input  clk, rst_n, wr_en, access_mode, opmask, din, \
        output dout, status \
    ); \
    modport Controller ( \
        input  clk, rst_n, dout, status, \
        output wr_en, access_mode, opmask, din \
    ); \
    modport Monitor ( \
        input clk, rst_n, wr_en, access_mode, opmask, din, dout, status \
    ); \
endinterface : ``REG_NAME``_if

// Declaração de Interface Padrão
`DEFINE_ZMM_REG_INTERFACE(zmm)

`undef DEFINE_ZMM_REG_INTERFACE


// ============================================================================
// Declaração do Módulo Principal do Registrador ZMM (Sem Implementação Interna)
// ============================================================================
module zmm_register (
    input  logic                   clk,
    input  logic                   rst_n,
    input  logic                   wr_en,
    input  zmm_pkg::zmm_access_mode_e access_mode,
    input  logic [7:0]             opmask,
    input  logic [511:0]           din,
    output logic [511:0]           dout,
    output zmm_pkg::zmm_status_t   status
);
    // A implementação do controle de escrita, mascaramento via Opmask (k1-k7)
    // e o zeramento de bits superiores em acessos parciais (modo EVEX)
    // devem ser mantidos no arquivo .sv correspondente.
endmodule : zmm_register

`endif // ZMM_REGISTERS_PKG_SVH
