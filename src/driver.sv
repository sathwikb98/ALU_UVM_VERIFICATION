class driver extends uvm_driver#(sequence_item);
  `uvm_component_utils(driver)
  // virtual interface !!
  virtual inf vif;

  //uvm_analysis_port#(sequence_item) item_collect_drv;

  sequence_item req;

  int count = 0;

  function new(string name="driver", uvm_component parent= null);
    super.new(name,parent);
    req = sequence_item::type_id::create("req");
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db#(virtual inf)::get(this,"","vif",vif) )
      `uvm_fatal(get_type_name(), " Could'nt get the handle to VIF !");
    // item_collect_drv = new("item_collect_drv",this);
  endfunction

  function bit SINGLE_OP_CMD(bit MODE , bit [`CMD_WIDTH-1:0] CMD);
    if( (MODE == 1 && CMD inside {[4:7]}) || (MODE == 0 && CMD inside {[6:11]})) return 1;
    else return 0;
  endfunction

  task drive_if();
    vif.INP_VALID <= req.INP_VALID;
    vif.MODE      <= req.MODE ;
    vif.CMD       <= req.CMD;
    vif.OPA       <= req.OPA;
    vif.OPB       <= req.OPB;
    vif.CIN       <= req.CIN;
    //item_collect_drv.write(req);
  endtask

  task run_phase(uvm_phase phase);
    repeat(3) @(posedge vif.CLK);
    //repeat(`no_of_transaction) begin
    forever begin
      @(posedge vif.CLK) begin
        seq_item_port.get_next_item(req);
        if(!vif.RST) begin
          //`uvm_info(get_type_name(),$sformatf(" @driver,  req  =  %s ",req.convert2string()),UVM_LOW)
          req.MODE.rand_mode(1);
          req.CMD.rand_mode(1);

          // logic of driving !
          if(SINGLE_OP_CMD(req.MODE, req.CMD)) begin // logic for single operand
            `uvm_info(get_type_name(),$sformatf(" @driver,  req  =  %s ",req.convert2string()),UVM_LOW)
            drive_if();
            @(posedge vif.CLK);
            if(req.INP_VALID != 2'b11) begin
              uvm_config_db#(bit)::set(null,"*","FLAG",1);
            end
            else begin
              uvm_config_db#(bit)::set(null,"*","FLAG",0);
            end
          end
          else begin // logic for dual operand
            if(req.INP_VALID inside {2'b10, 2'b01}) begin
              drive_if();
              req.MODE.rand_mode(0);
              req.CMD.rand_mode(0);
              count = 0;
              `uvm_info(get_type_name(),$sformatf(" @driver, req  =  %s ",req.convert2string()),UVM_LOW)
              repeat(2) @(posedge vif.CLK); // added to synchronize 16 clock cycle event
              for(count = 1; count < 17 ; count++) begin
                @(posedge vif.CLK);
                $display("Driver_count : %0d",count);
                void'(req.randomize());
                if(req.INP_VALID == 2'b11) begin
                  `uvm_info(get_type_name(),$sformatf(" @driver, req  =  %s ",req.convert2string()),UVM_LOW)
                  drive_if();
                  @(posedge vif.CLK);
                  if(req.MODE == 1 && req.CMD inside {[9:10]}) @(posedge vif.CLK);
                  if(req.MODE == 0 && req.CMD inside {[12:13]} && req.OPB > 15) begin
                    uvm_config_db#(bit)::set(null,"*","FLAG",1); // rotate error flag !!
                  end
                  else begin
                    uvm_config_db#(bit)::set(null,"*","FLAG",0);
                  end

                  count = 0;
                  break;
                end
                else if(count == 16) begin
                  drive_if(); // with error signal defined at scoreboard end!
                  `uvm_info(get_type_name(),$sformatf(" @driver,  req  =  %s ",req.convert2string()),UVM_LOW)
                  @(posedge vif.CLK);
                  if(req.MODE == 1 && req.CMD inside {[9:10]}) @(posedge vif.CLK);
                  uvm_config_db#(bit)::set(null,"*","FLAG",1);
                  count = 0;
                  break;
                end
                drive_if();
                `uvm_info(get_type_name(),$sformatf(" @driver, req  =  %s ",req.convert2string()),UVM_LOW)
              end
            end
            else begin // dual operand with inp_valid == 2'b00/2'b11 !
              drive_if();
              `uvm_info(get_type_name(),$sformatf(" @driver,  req  =  %s ",req.convert2string()),UVM_LOW)
              @(posedge vif.CLK);
              if(req.MODE == 1 && req.CMD inside {[9:10]}) @(posedge vif.CLK);
              if(req.INP_VALID != 2'b11) begin
                uvm_config_db#(bit)::set(null,"*","FLAG",1);
              end
              else begin
                uvm_config_db#(bit)::set(null,"*","FLAG",0);
              end
            end
          end
          $display("---------------------end of driver logic--------------------------------");
          seq_item_port.item_done(req);
          @(posedge vif.CLK);
        end
      end
    end
  endtask

endclass
