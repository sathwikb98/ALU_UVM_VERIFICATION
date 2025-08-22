`uvm_analysis_imp_decl(_drv_cg)
`uvm_analysis_imp_decl(_mon_cg)

// coverage or subsrcriber logic used to get the coverage of input [from driver] and output [from monitor].
class coverage extends uvm_component;
  `uvm_component_utils(coverage)
  uvm_analysis_imp_mon_cg#(sequence_item, coverage) monitor_cov;
  uvm_analysis_imp_drv_cg#(sequence_item, coverage) driver_cov;

  sequence_item pktd;
  sequence_item pktm;

  covergroup drv_cg;
    c1: coverpoint pktd.OPA {
      bins a1 = {[0:255]};
    }
    c2: coverpoint pktd.OPB {
      bins a2 = {[0:255]};
    }
    c3: coverpoint pktd.CIN;
    c4: coverpoint pktd.MODE;
    c5: coverpoint pktd.INP_VALID;
    c6: coverpoint pktd.CMD;
    c7: cross c4, c6 ; // cmd and mode cross !
    c8: cross c4, c5 ; // mode and input_valid !
    c9: cross c5, c6 ; // inp_valid and cmd !
  endgroup

  covergroup mon_cg;
    c1: coverpoint pktm.RES{
      bins a1 = {0}; // least value
      bins a2 = {511}; // 9 bit max value
      bins a3 = default;
    }
    c2: coverpoint pktm.G;
    c3: coverpoint pktm.E;
    c4: coverpoint pktm.L;
    c5: coverpoint pktm.COUT;
    c6: coverpoint pktm.OFLOW;
    c7: coverpoint pktm.ERR;
  endgroup

  function new(string name ="coverage", uvm_component parent = null);
    super.new(name,parent);

    drv_cg = new();
    mon_cg = new();
    monitor_cov = new("mon_cov",this);
    driver_cov = new("drv_cov", this);
  endfunction

  function void write_drv_cg(sequence_item req);
    pktd = req;
    drv_cg.sample();
  endfunction

  function void write_mon_cg(sequence_item req);
    pktm = req;
    mon_cg.sample();
  endfunction

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
    // used to print functional coverage of drv_cg and mon_cg !
    `uvm_info(get_type_name(), $sformatf("COVERAGE, drv_cg: %0.2f, mon_cg: %.2f",drv_cg.get_coverage(),mon_cg.get_coverage()),UVM_LOW)

  endfunction

endclass
