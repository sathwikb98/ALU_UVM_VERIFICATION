class scoreboard extends uvm_scoreboard;
  // virtual interface so we can compare the reference model with monitored result !
  virtual inf vif;

  uvm_analysis_imp#(sequence_item, scoreboard) analysis_export;

  sequence_item seq[$];

  sequence_item req, ref_req;

  int MATCH = 0, MISMATCH = 0;

  logic ERR = 0;

  int count = 0; // A global counter to keep count of 16 clock cycle sequence_item intially having 0 !!

  // localparam used in rotation width for logical operation
  localparam ROL_WIDTH = $clog2(`OP_WIDTH);
  reg [ROL_WIDTH-1 : 0] rotation ;
  reg [(`OP_WIDTH - (ROL_WIDTH+2)) : 0] err_flag;

  `uvm_component_utils(scoreboard)

  function new(string name ="scoreboard", uvm_component parent =null);
    super.new(name,parent);
    req     = sequence_item::type_id::create("req");
    ref_req = sequence_item::type_id::create("ref_req");
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual inf)::get(this,"","vif",vif))
      `uvm_fatal(get_type_name()," Could'nt get the handle for VFI!!")
    analysis_export = new("analysis_export", this);
  endfunction

  function void write(sequence_item req);
     seq.push_back(req);
  endfunction

  function bit SINGLE_OP_CMD(input logic MODE , input logic[`CMD_WIDTH-1:0] CMD);
    if(MODE == 1) begin
       if(CMD inside {[0:3], [8:10]}) return 0;
       else return 1;
    end
    else begin
       if(CMD inside {[0:5], [12:13]}) return 0;
       else return 1;
    end
  endfunction : SINGLE_OP_CMD

  task alu_process();
    begin : REFERENCE_MODEL_FUNC
        if(vif.RST) begin : reset

           ref_req.RES = {`OP_WIDTH+1{1'bz}};
           ref_req.OFLOW = 1'bz;
           ref_req.COUT = 1'bz;
           ref_req.G = 1'bz;
           ref_req.L = 1'bz;
           ref_req.E = 1'bz;
           ERR = 1'bz;
        end : reset

        else if(vif.CE) begin : CE_BLOCK

          //assigning default values
          ref_req.RES = {`OP_WIDTH+1{1'bz}};
          ref_req.OFLOW = 1'bz;
          ref_req.COUT = 1'bz;
          ref_req.G = 1'bz;
          ref_req.L = 1'bz;
          ref_req.E = 1'bz;
          // Error will be checked for invalid CMD and Config_db sending the bit !!
          ERR = 0;

          if(req.INP_VALID == 2'b11 || ( req.INP_VALID == 2'b01 && req.MODE == 1 && req.CMD inside {4,5}) || ( req.INP_VALID == 2'b10 && req.MODE == 1 && req.CMD inside {6,7}) || ( req.INP_VALID == 2'b01 && req.MODE == 0 && req.CMD inside {6,8,9}) || ( req.INP_VALID == 2'b10 && req.MODE == 0 && req.CMD inside {7,10,11}) ) begin :VALID_INPUT

          if(req.MODE == 1) begin : ARITHMETIC_OPERATION
             case(req.CMD)  // `INCR_MULT,`SHIFT_MULT -> 3 clock cycle delay !
              `ADD :  // `ADD,`SUB,`ADD_CIN,`SUB_CIN,`INC_A,`DEC_A,`INC_B,`DEC_B,`CMP -> similary output after 2 clock cycle
                  begin
                    ref_req.RES = req.OPA + req.OPB;
                    ref_req.COUT = ref_req.RES[`OP_WIDTH];
                  end
              `SUB :
                  begin
                    ref_req.RES = req.OPA - req.OPB;
                    ref_req.OFLOW = ref_req.RES[`OP_WIDTH];
                  end
               `ADD_CIN :
                 begin
                   ref_req.RES = req.OPA + req.OPB + req.CIN;
                   ref_req.COUT = ref_req.RES[`OP_WIDTH];
                 end
               `SUB_CIN :
                 begin
                   ref_req.RES = req.OPA - (req.OPB + req.CIN);
                   ref_req.OFLOW = (req.OPA < (req.OPB + req.CIN));
                 end
               `INC_A :
                 begin
                   ref_req.RES = req.OPA + 1'b1;
                   ref_req.OFLOW = ref_req.RES[`OP_WIDTH];
                 end
               `DEC_A :
                 begin
                   ref_req.RES = req.OPA - 1'b1;
                   ref_req.OFLOW = ref_req.RES[`OP_WIDTH];
                 end
               `INC_B :
                 begin
                   ref_req.RES = req.OPB + 1'b1;
                   ref_req.OFLOW = ref_req.RES[`OP_WIDTH];
                 end
               `DEC_B :
                 begin
                   ref_req.RES = req.OPB - 1'b1;
                 end
               `CMP :
                 begin
                   if(req.OPA > req.OPB ) begin
                     ref_req.E = 1'bz;
                     ref_req.G = 1'b1;
                     ref_req.L = 1'bz;
                   end
                   else if(req.OPA < req.OPB) begin
                     ref_req.E = 1'bz;
                     ref_req.G = 1'bz;
                     ref_req.L = 1'b1;
                   end
                   else begin // equal
                     ref_req.E = 1'b1;
                     ref_req.G = 1'bz;
                     ref_req.L = 1'bz;
                   end
                 end
               `INCR_MULT :
                 begin
                    ref_req.RES = (req.OPA + 1'b1) * (req.OPB + 1'b1) ;
                 end
               `SHIFT_MULT :
                 begin
                    ref_req.RES = (req.OPA << 1) * (req.OPB);
                 end
               default :
                  begin
                    ref_req.RES = 0;
                    ERR = 1'b1;
                  end
             endcase
          end : ARITHMETIC_OPERATION

          else begin : LOGICAL_OPERATION
              case(req.CMD) // `AND,`NAND,`OR,`NOR,`XOR,`XNOR,`NOT_A,`NOT_B,`SHR1_A,`SHL1_A,`SHR1_B,`SHL1_B,`ROL_A_B,`ROR_A_B
                `AND :
                  begin
                      ref_req.RES = req.OPA & req.OPB;
                  end
                `NAND :
                  begin
                    ref_req.RES = ~(req.OPA & req.OPB);
                    ref_req.RES[`OP_WIDTH] = 1'b0;
                  end
                `OR :
                  begin
                    ref_req.RES = req.OPA | req.OPB;
                  end
                `NOR :
                  begin
                    ref_req.RES = ~(req.OPA | req.OPB);
                    ref_req.RES[`OP_WIDTH] = 1'b0;
                  end
                `XOR :
                  begin
                    ref_req.RES = req.OPA ^ req.OPB;
                  end
                `XNOR :
                  begin
                    ref_req.RES = ~(req.OPA ^ req.OPB);
                    ref_req.RES[`OP_WIDTH] = 1'b0;
                  end
                `NOT_A :
                  begin
                    ref_req.RES = ~(req.OPA);
                    ref_req.RES[`OP_WIDTH] = 1'b0;
                  end
                `NOT_B :
                  begin
                    ref_req.RES = ~(req.OPB);
                    ref_req.RES[`OP_WIDTH] = 1'b0;
                  end
                `SHR1_A :
                  begin
                    ref_req.RES = req.OPA >> 1;
                  end
                `SHL1_A :
                  begin
                    ref_req.RES = req.OPA << 1;
                  end
                `SHR1_B :
                  begin
                    ref_req.RES = req.OPB >> 1;
                  end
                `SHL1_B :
                  begin
                    ref_req.RES = req.OPB << 1;
                  end
                `ROL_A_B :
                  begin
                    rotation = req.OPB[ROL_WIDTH-1:0];
                    err_flag = req.OPB[`OP_WIDTH-1 : ROL_WIDTH+1];
                    ref_req.RES = { (req.OPA << rotation) | (req.OPA >> `OP_WIDTH-rotation) };
                  end
                `ROR_A_B :
                  begin
                    rotation = req.OPB[ROL_WIDTH-1:0];
                    err_flag = req.OPB[`OP_WIDTH-1 : ROL_WIDTH+1];
                    ref_req.RES = { (req.OPA >> rotation) | (req.OPA << `OP_WIDTH-rotation) };

                  end
                default :
                  begin
                    ref_req.RES = 0;
                    ERR = 1'b1;
                  end
              endcase

          end : LOGICAL_OPERATION
         end : VALID_INPUT

      end : CE_BLOCK
    end : REFERENCE_MODEL_FUNC
  endtask : alu_process


  task run_phase(uvm_phase phase);
    
    forever begin

      wait(seq.size() > 0);

      if(seq.size() > 0) begin
        req = seq.pop_front();
        `uvm_info(get_full_name(),$sformatf("sequence item got at scoreboad : %s\n",req.convert2string()),UVM_LOW)
        ref_req.copy(req); // first copy the value of req to ref_ref
        alu_process(); // process of alu on req !!
        //$display(" Before ERR : %0b",ERR);
        if(uvm_config_db#(bit)::get(this,"","FLAG",ERR))
        if(ERR) ref_req.ERR = ERR ;
        ref_req.ERR = (err_flag)? 1'b1 : ref_req.ERR; // rotation error check
        //$display(" After ERR : %0b",ERR);
        `uvm_info(get_full_name(), $sformatf("ref_req : %s",ref_req.convert2string_out), UVM_LOW) // reference model output !!

        // compare logic ...... [ref_req and vif are compared !!]
        if(req.compare(ref_req)) begin
          MATCH++;
          `uvm_info(get_full_name(),"MATCHED @Scoreboard",UVM_LOW)
        end
        else begin
          MISMATCH++;
          `uvm_info(get_full_name(),"MISMATCH @Scoreboard",UVM_LOW)
        end
        `uvm_info(get_type_name(), $sformatf("MATCH : %0d, MISMATCH : %0d",MATCH,MISMATCH), UVM_LOW)
        ERR = 0;
        $display("------------------------ End of scoreboard ----------------------------");
      end
    end
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
    $display("\n--------------------------------- UVM_SCOREBOARD REPORT ------------------------------------------\n");

    `uvm_info(get_type_name(), $sformatf("MATCH : %0d, MISMATCH : %0d",MATCH,MISMATCH), UVM_LOW)

    $display("\n------------------------------------  END UVM_REPORT  --------------------------------------------\n");
  endfunction

endclass
