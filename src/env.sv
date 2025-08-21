class env extends uvm_env;
 `uvm_component_utils(env)
  agent        agt;
  scoreboard   scb;
  coverage     fcov;

  function new(string name ="env", uvm_component parent= null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agt = agent::type_id::create("agent",this);
    scb = scoreboard::type_id::create("scb",this);
    fcov = coverage::type_id::create("coverage",this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agt.mon.analysis_port.connect(scb.analysis_export);
    agt.mon.analysis_port.connect(fcov.monitor_cov);
    agt.drv.item_collect_drv.connect(fcov.driver_cov);
  endfunction

endclass
