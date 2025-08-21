class sequence_item extends uvm_sequence_item;
  // CLK, CE, RST are global signals
  bit CLK, CE, RST;

  // OUTPUT SIGNALS
  bit ERR, OFLOW, COUT, G, L, E;
  bit [`OP_WIDTH:0] RES;

  // INPUT SIGNALS
  rand bit [1:0] INP_VALID;
  rand bit MODE, CIN;
  rand bit [`OP_WIDTH-1:0] OPA, OPB;
  rand bit [`CMD_WIDTH-1:0] CMD;

  `uvm_object_utils_begin(sequence_item)
  `uvm_field_int(INP_VALID, UVM_ALL_ON)
  `uvm_field_int(MODE,      UVM_ALL_ON)
  `uvm_field_int(CIN,       UVM_ALL_ON)
  `uvm_field_int(OPA,       UVM_ALL_ON)
  `uvm_field_int(OPB,       UVM_ALL_ON)
  `uvm_field_int(CMD,       UVM_ALL_ON)
  `uvm_field_int(ERR,       UVM_ALL_ON)
  `uvm_field_int(RES,       UVM_ALL_ON)
  `uvm_field_int(OFLOW,     UVM_ALL_ON)
  `uvm_field_int(COUT,      UVM_ALL_ON)
  `uvm_field_int(G,         UVM_ALL_ON)
  `uvm_field_int(L,         UVM_ALL_ON)
  `uvm_field_int(E,         UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name ="");
    super.new(name);
  endfunction

  function string convert2string();
    return $sformatf(" INP_VALID = %2b, MODE = %0b, CIN = %0b, OPA = %0d, OPB = %0d, CMD = %0d\n", INP_VALID, MODE, CIN, OPA, OPB, CMD);
  endfunction

  function string convert2string_out();
    return $sformatf(" ERR = %0b, OFLOW = %0b, RES = %0d, COUT = %0b, G = %0b, L = %0b, E = %0b\n", ERR, OFLOW, RES, COUT, G, L, E);
  endfunction

  // Added constraint
  constraint MODE_SOLVE_FIRST { solve MODE before CMD; }
  constraint CMD_RANGE { if(MODE == 1) CMD inside {[0:10]};
                         else CMD inside {[0:13]};
  }
  constraint OP_RANGE { OPA inside {[0:25]}; OPB inside {[1:20]}; }
  constraint INP_VALID_CMD_RANGE { INP_VALID dist{ 2'b11 := 80, 2'b10 := 10, 2'b01 := 10}; }

endclass
