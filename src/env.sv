class env extends uvm_env;
 `uvm_component_utils(env)
  agent          agt_a, agt_p;
  scoreboard     scb;
  coverage       fcov;

  function new(string name ="env", uvm_component parent= null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agt_a = agent::type_id::create("agent_active",this);
    agt_p = agent::type_id::create("agent_passive",this);
    scb   = scoreboard::type_id::create("scb",this);
    fcov  = coverage::type_id::create("coverage",this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agt_a.mon.analysis_port.connect(scb.analysis_export);
    agt_a.mon.analysis_port.connect(fcov.monitor_cov);
    agt_p.mon.analysis_port.connect(scb.analysis_export);
    agt_p.mon.analysis_port.connect(fcov.monitor_cov);
  endfunction

endclass
