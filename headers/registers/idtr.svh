// ============================================================================
// File: headers/registers/idtr.svh
// Project: x86_64 Hardware Architecture Implementation
// Author: Pedro Emanuel
// License: GPL-3.0-only
//
// Description: Definition of the IDTR (Interrupt Descriptor Table Register)
//              structure for x86_64 mode.
// ============================================================================

`ifndef REGISTERS_IDTR_SVH
`define REGISTERS_IDTR_SVH

package idtr_pkg;

    // Estrutura de 80 bits do registrador IDTR no modo x86_64
    typedef struct packed {
        logic [63:0] base_address; // Endereço base de 64 bits da IDT
        logic [15:0] limit;        // Limite da tabela (Tamanho em bytes - 1)
    } idtr_t;

endpackage : idtr_pkg

`endif // REGISTERS_IDTR_SVH
