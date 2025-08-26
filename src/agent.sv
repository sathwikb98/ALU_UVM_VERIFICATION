class agent extends uvm_agent;
  `uvm_component_utils(agent)

  sequencer seqr;
  monitor   mon ;
  driver    drv ;

  uvm_active_passive_enum is_active;

  function new(string name ="agent", uvm_component parent =null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(uvm_active_passive_enum)::get(this,"","is_active",is_active))
      `uvm_info(get_type_name(),$sformatf("DID'nt get the agent_type"),UVM_LOW)
    if(is_active == UVM_ACTIVE) begin
      seqr   = sequencer::type_id::create("sequencer",this);
      drv    = driver::type_id::create("drv",this);
    end
    mon = monitor::type_id::create("mon",this);

  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(is_active == UVM_ACTIVE)
      drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction

endclass
