// ============================================================================
// File: headers/registers/gdtr.svh
// Project: x86_64 Hardware Architecture Implementation
// Author: Pedro Emanuel
// License: GPL-3.0-only
//
// Description: Definition of the GDTR (Global Descriptor Table Register)
//              structure for x86_64 mode.
// ============================================================================

`ifndef REGISTERS_GDTR_SVH
`define REGISTERS_GDTR_SVH

package gdtr_pkg;

    // Estrutura de 80 bits do registrador GDTR no modo x86_64
    typedef struct packed {
        logic [63:0] base_address; // Endereço base de 64 bits da GDT
        logic [15:0] limit;        // Limite da tabela (Tamanho em bytes - 1)
    } gdtr_t;

endpackage : gdtr_pkg

`endif // REGISTERS_GDTR_SVH
