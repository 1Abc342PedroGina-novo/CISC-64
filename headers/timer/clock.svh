// ============================================================================
// File: headers/timer/clock.svh
// Project: x86_64 Hardware Architecture Implementation
// Author: Pedro Emanuel
// License: GPL-3.0-only
//
// Description: Package, interface, and module for the system clock generator,
//              real-time counters (RTC / TSC), and frequency measurement.
// ============================================================================

`ifndef TIMER_CLOCK_SVH
`define TIMER_CLOCK_SVH

package timer_clock_pkg;

    typedef struct packed {
        logic [63:0] tsc_counter;  // Time Stamp Counter (TSC - rdtsc)
        logic [31:0] sys_freq_mhz; // Frequência do sistema em MHz
        logic        clock_stable; // Sinaliza estabilidade do PLL/Clock
    } clock_info_t;

endpackage : timer_clock_pkg


interface timer_clock_if (
    input logic clk,
    input logic rst_n
);
    import timer_clock_pkg::*;

    logic        enable_tsc;
    logic        clear_tsc;
    clock_info_t clock_info;

    modport ClockGenerator (
        input  clk, rst_n, enable_tsc, clear_tsc,
        output clock_info
    );

    modport System (
        input  clk, rst_n, clock_info,
        output enable_tsc, clear_tsc
    );

    modport Monitor (
        input clk, rst_n, enable_tsc, clear_tsc, clock_info
    );
endinterface : timer_clock_if


module timer_clock_generator (
    input  logic                       clk,
    input  logic                       rst_n,
    input  logic                       enable_tsc,
    input  logic                       clear_tsc,
    output timer_clock_pkg::clock_info_t clock_info
);
endmodule : timer_clock_generator

`endif // TIMER_CLOCK_SVH
