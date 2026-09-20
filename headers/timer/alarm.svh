// ============================================================================
// File: headers/timer/alarm.svh
// Project: x86_64 Hardware Architecture Implementation
// Author: Pedro Emanuel
// License: GPL-3.0-only
//
// Description: Package, interface, and module for managing alarms and
//              programmed interrupts (RTC Alarm / LAPIC Timer / HPET Alarm).
// ============================================================================

`ifndef TIMER_ALARM_SVH
`define TIMER_ALARM_SVH

package timer_alarm_pkg;

    typedef struct packed {
        logic [63:0] target_tick;  // Tick absoluto em que o alarme deve disparar
        logic        periodic;     // 1: Periódico, 0: One-shot
        logic [63:0] period_ticks; // Intervalo para recarga em modo periódico
        logic [7:0]  vector;       // Vetor de interrupção associado ao alarme
    } alarm_config_t;

    typedef struct packed {
        logic alarm_triggered;    // Sinaliza disparo de alarme
        logic active;             // Alarme atualmente armado
    } alarm_status_t;

endpackage : timer_alarm_pkg


interface timer_alarm_if (
    input logic clk,
    input logic rst_n
);
    import timer_alarm_pkg::*;

    logic          arm_alarm;
    logic          disarm_alarm;
    alarm_config_t config_in;
    alarm_status_t status;
    logic          irq_out;

    modport AlarmUnit (
        input  clk, rst_n, arm_alarm, disarm_alarm, config_in,
        output status, irq_out
    );

    modport Controller (
        input  clk, rst_n, status, irq_out,
        output arm_alarm, disarm_alarm, config_in
    );

    modport Monitor (
        input clk, rst_n, arm_alarm, disarm_alarm, config_in, status, irq_out
    );
endinterface : timer_alarm_if


module timer_alarm_unit (
    input  logic                     clk,
    input  logic                     rst_n,
    input  logic                     arm_alarm,
    input  logic                     disarm_alarm,
    input  timer_alarm_pkg::alarm_config_t config_in,
    output timer_alarm_pkg::alarm_status_t status,
    output logic                     irq_out
);
endmodule : timer_alarm_unit

`endif // TIMER_ALARM_SVH
