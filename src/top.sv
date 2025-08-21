`include "uvm_macros.svh"
`include "defines.svh"
`include "interface.sv"
`include "alu_pkg.sv"
`include "ALU_DESIGN.sv"

module top;

  import uvm_pkg::*;   // include uvm_package
  import alu_pkg::*;   // include ALU package

  bit CLK, RST, CE;

  inf intf(.CLK(CLK), .RST(RST), .CE(CE)); // global signals

  ALU_DESIGN duv (.CLK(CLK), .RST(RST), .INP_VALID(intf.INP_VALID), .MODE(intf.MODE), .CMD(intf.CMD), .CE(CE), .OPA(intf.OPA), .OPB(intf.OPB), .CIN(intf.CIN), .ERR(intf.ERR), .RES(intf.RES), .OFLOW(intf.OFLOW), .COUT(intf.COUT), .G(intf.G), .L(intf.L), .E(intf.E));

  always #5 CLK = ~CLK;

  initial begin
    CLK = 0; CE = 0; RST = 1; // assert reset !!
    #20;
    RST = 0; // de-assert
    #10;
    CE = 1;
  end

  initial begin
    uvm_config_db#(virtual inf)::set(uvm_root::get(),"*","vif",intf);
    //run_test("test");
    run_test("regression_test"); 
  end

endmodule
