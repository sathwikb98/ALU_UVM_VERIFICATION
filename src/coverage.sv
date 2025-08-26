`uvm_analysis_imp_decl(_active_mon_cg)
`uvm_analysis_imp_decl(_passive_mon_cg)

class coverage extends uvm_component;
  `uvm_component_utils(coverage)

  // Gets the data from the active/passive monitor !
  uvm_analysis_imp_active_mon_cg#(sequence_item, coverage) active_mon_cov;
  uvm_analysis_imp_passive_mon_cg#(sequence_item, coverage) passive_mon_cov;

  sequence_item a_pktm;
  sequence_item p_pktm;

  covergroup inp_cg;
    c1: coverpoint a_pktm.OPA {
      bins a1 = {[0:255]};
    }
    c2: coverpoint a_pktm.OPB {
      bins a2 = {[0:255]};
    }
    c3: coverpoint a_pktm.CIN;
    c4: coverpoint a_pktm.MODE;
    c5: coverpoint a_pktm.INP_VALID;
    c6: coverpoint a_pktm.CMD {
      bins a3 = {[0:13]};
      ignore_bins bad = {[14:$]};
    }
    c7: cross c4, c6 ; // cmd and mode cross !
    c8: cross c4, c5 ; // mode and input_valid !
    c9: cross c5, c6 ; // inp_valid and cmd !
  endgroup

  covergroup out_cg;
    c1: coverpoint p_pktm.RES; //{
      //bins a1 = {0}; // least value
      //bins a2 = {511}; // 9 bit max value
      //bins a3 = default;
    //}
    c2: coverpoint {p_pktm.G,p_pktm.E,p_pktm.L}{
      bins a1 = {[1:$]};
    }
    c5: coverpoint p_pktm.COUT;
    c6: coverpoint p_pktm.OFLOW;
    c7: coverpoint p_pktm.ERR;
  endgroup

  function new(string name ="coverage", uvm_component parent = null);
    super.new(name,parent);

    inp_cg = new();
    out_cg = new();
    active_mon_cov = new("active_mon_cov",this);
    passive_mon_cov = new("passive_mon_cov",this);
  endfunction

  function void write_active_mon_cg(sequence_item req);
    a_pktm = req;
    inp_cg.sample();
  endfunction

  function void write_passive_mon_cg(sequence_item req);
    p_pktm = req;
    out_cg.sample();
  endfunction

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);

    `uvm_info(get_type_name(), $sformatf("COVERAGE, inp_cg: %0.2f, out_cg: %.2f",inp_cg.get_coverage(),out_cg.get_coverage()),UVM_LOW)

  endfunction

endclass
