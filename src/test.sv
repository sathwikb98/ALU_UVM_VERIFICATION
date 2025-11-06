class test extends uvm_test;
  `uvm_component_utils(test)

  env               env_o;
  _sequence         b_seq;

  function new(string name = "test", uvm_component parent =null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // setting agent configuration before creating it
    uvm_config_db#(uvm_active_passive_enum)::set(this,"env_o.agent_active","is_active",UVM_ACTIVE);
    uvm_config_db#(uvm_active_passive_enum)::set(this,"env_o.agent_passive","is_active",UVM_PASSIVE);
    env_o = env::type_id::create("env_o",this);
    b_seq = _sequence::type_id::create("b_seq");

  endfunction

  task run_phase(uvm_phase phase);
    uvm_objection phase_done = phase.get_objection();
    phase.raise_objection(this);
      b_seq.start(env_o.agt_a.seqr);
    phase.drop_objection(this);
    // drain time for last sequence to run !!
    phase_done.set_drain_time(this,20);
    `uvm_info(get_type_name(), "END of testcase.......[TEST]", UVM_LOW);

  endtask

endclass

class arthematic_test_s extends test;
  `uvm_component_utils(arthematic_test_s)
  _arithematic_sequence_single seq2;

  function new(string name = "_arthematic_test_s", uvm_component parent = null);
    super.new(name,parent);
    seq2 = _arithematic_sequence_single::type_id::create("arth_s");
  endfunction


  task run_phase(uvm_phase phase);
    uvm_objection phase_done = phase.get_objection();
    phase.raise_objection(this);
      seq2.start(env_o.agt_a.seqr);
    phase.drop_objection(this);
    // drain time for last sequence to run !!
    phase_done.set_drain_time(this,20);
    `uvm_info(get_type_name(), "END of testcase........[arthematic_test_s]", UVM_LOW);
  endtask

endclass

class arthematic_test_d extends test;
  `uvm_component_utils(arthematic_test_d)
  _arithematic_sequence_dual seq3;

  function new(string name = "_arithematic_test_d", uvm_component parent = null);
    super.new(name,parent);
    seq3 = _arithematic_sequence_dual::type_id::create("arth_d");
  endfunction

  task run_phase(uvm_phase phase);
    uvm_objection phase_done = phase.get_objection();
    phase.raise_objection(this);
      seq3.start(env_o.agt_a.seqr);
    phase.drop_objection(this);
    // drain time for last sequence to run !!
    phase_done.set_drain_time(this,20);
    `uvm_info(get_type_name(), "END of testcase........[arthematic_test_d]", UVM_LOW);
  endtask

endclass

class logical_test_s extends test;
  `uvm_component_utils(logical_test_s)
  _logical_sequence_single seq4;

  function new(string name = "logical_test_s", uvm_component parent = null);
    super.new(name,parent);
    seq4 = _logical_sequence_single::type_id::create("log_s");
  endfunction

  task run_phase(uvm_phase phase);
    uvm_objection phase_done = phase.get_objection();
    phase.raise_objection(this);
      seq4.start(env_o.agt_a.seqr);
    phase.drop_objection(this);
    // drain time for last sequence to run !!
    phase_done.set_drain_time(this,20);
    `uvm_info(get_type_name(), "END of testcase.........[logical_test_s]", UVM_LOW);
  endtask

endclass

class logical_test_d extends test;
  `uvm_component_utils(logical_test_d)
  _logical_sequence_dual seq5;

  function new(string name = "logical_test_d", uvm_component parent = null);
    super.new(name,parent);
    seq5 = _logical_sequence_dual::type_id::create("log_d");
  endfunction

  task run_phase(uvm_phase phase);
    uvm_objection phase_done = phase.get_objection();
    phase.raise_objection(this);
      seq5.start(env_o.agt_a.seqr);
    phase.drop_objection(this);
    // drain time for last sequence to run !!
    phase_done.set_drain_time(this,20);
    `uvm_info(get_type_name(), "END of testcase.........[logical_test_d]", UVM_LOW);
  endtask

endclass

class regression_test extends test;
  `uvm_component_utils(regression_test)
  regression reg_seq;
  function new(string name = "regression_test", uvm_component parent = null);
    super.new(name,parent);
    reg_seq = regression::type_id::create("reg_seq");
  endfunction

  task run_phase(uvm_phase phase);
    uvm_objection phase_done = phase.get_objection();
    phase.raise_objection(this);
      reg_seq.start(env_o.agt_a.seqr);
    phase.drop_objection(this);
    // drain time for last sequence to run !!
    phase_done.set_drain_time(this,20);
    `uvm_info(get_type_name(), "END of testcase...........[regression_test]", UVM_LOW);
  endtask

endclass
