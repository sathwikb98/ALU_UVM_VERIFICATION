class monitor extends uvm_monitor;
  // virtual interface to get the result from dut
  virtual inf vif;
  uvm_analysis_port#(sequence_item) analysis_port;

  sequence_item req;

  int count = 0;

  `uvm_component_utils(monitor)

  function new(string name ="monitor", uvm_component parent = null);
    super.new(name,parent);
    req = sequence_item::type_id::create("req");
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual inf)::get(this,"","vif",vif))
      `uvm_fatal(get_type_name(), "could'nt get the handle for VIF!!")
    analysis_port = new("analysis_port", this);
  endfunction

  function bit SINGLE_OP_CMD(bit MODE , bit [`CMD_WIDTH-1:0] CMD);
        if( (MODE == 1 && CMD inside {[4:7]}) || (MODE == 0 && CMD inside {[6:11]})) return 1;
        else return 0;
  endfunction

  task set_req();
    // setting up the packet before sending further [like scoreboard.....]
    req.INP_VALID = vif.INP_VALID;
    req.MODE = vif.MODE;
    req.CMD = vif.CMD;
    req.OPA = vif.OPA;
    req.OPB = vif.OPB;
    req.CIN = vif.CIN;
    req.ERR = vif.ERR;
    req.RES = vif.RES;
    req.OFLOW = vif.OFLOW;
    req.COUT = vif.COUT;
    req.G = vif.G;
    req.L = vif.L;
    req.E = vif.E;
  endtask

  task run_phase(uvm_phase phase);
    repeat(4) @(posedge vif.CLK);
    forever begin
      @(posedge vif.CLK) begin
        repeat(1) @(posedge vif.CLK);
        if(!vif.RST) begin
          // monitor logic !!
          if(SINGLE_OP_CMD(vif.MODE, vif.CMD)) begin
            @(posedge vif.CLK);
            set_req();
          end
          else begin
            if(vif.INP_VALID == 2'b10 || vif.INP_VALID == 2'b01) begin
              //@(posedge vif.CLK);
              for(count = 1; count < 17; count++) begin
                @(posedge vif.CLK);
                $display("Monitor_count: %0d",count);
                if( (count == 16 && vif.INP_VALID != 2'b11) || (vif.INP_VALID == 2'b11) ) begin
                  repeat(2) @(posedge vif.CLK);
                  if(vif.MODE == 1 && vif.CMD inside {[9:10]}) @(posedge vif.CLK);
                  //`uvm_info("MON_LOOP_COUNT", $sformatf("count : %0d",count),UVM_MEDIUM)
                  set_req();
                  count = 0; // de-assert the counter
                  break;
                end
              end
            end
            else begin
              @(posedge vif.CLK);
              if(vif.MODE == 1 && vif.CMD inside {[9:10]}) @(posedge vif.CLK);
              set_req(); // for dual op inp_valid == 2'b11 or 2'b00
            end
          end
          `uvm_info(get_type_name(), $sformatf("near monitor, req  =  %s",req.convert2string()), UVM_LOW)
          `uvm_info(get_type_name(), $sformatf("@monitor, OUTPUT: %s",req.convert2string_out()), UVM_LOW)
          analysis_port.write(req); 
          $display("--------------------------end of monitor logic----------------------------");
        end
      end
    end
  endtask

endclass
