`include "uvm_macros.svh"

package alu_pkg;
  import uvm_pkg::*;
  `include "defines.svh"
  //`include "ALU_DESIGN.sv"
  `include "sequence_item.sv"
  `include "sequence.sv"
  `include "sequencer.sv"
  `include "driver.sv"
  `include "monitor.sv"
  `include "scoreboard.sv"
  `include "coverage.sv"

  `include "agent.sv"
  `include "env.sv"
  `include "test.sv"

endpackage
