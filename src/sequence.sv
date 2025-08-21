class _sequence extends uvm_sequence#(sequence_item);
  `uvm_object_utils(_sequence)

  function new(string name ="sequence_basic");
    super.new(name);
  endfunction

  virtual task body();
    repeat(`no_of_transaction) begin
      req = sequence_item::type_id::create("request");
      wait_for_grant();
      void'(req.randomize());
      `uvm_info(get_type_name(),$sformatf(" req : %s",req.convert2string()), UVM_LOW)
      send_request(req);
      wait_for_item_done();
      get_response(req);
      $display("---------------------------------------------------------------------------------------------------------------------------");
    end
  endtask

endclass

class _arithematic_sequence_single extends uvm_sequence#(sequence_item);
 `uvm_object_utils(_arithematic_sequence_single)

 function new(string name ="sequence_arithematic_single");
   super.new(name);
 endfunction

 virtual task body();
   repeat(`no_of_transaction) begin
    `uvm_do_with(req, {req.MODE == 1; req.CMD inside {[4:7]}; req.CMD dist{`DEC_A:=10}; })
    get_response(req);
    $display("---------------------------------------------------------------------------------------------------------------------------");
   end
 endtask

endclass

class _arithematic_sequence_dual extends uvm_sequence#(sequence_item);
 `uvm_object_utils(_arithematic_sequence_dual)

 function new(string name ="sequence_arithematic_dual");
   super.new(name);
 endfunction

 virtual task body();
   repeat(`no_of_transaction) begin
    `uvm_do_with(req, {req.MODE == 1; req.CMD inside {[0:3], [8:10]}; req.CMD dist{[`ADD:`SUB_CIN] :=7 ,`INCR_MULT :=3 }; } )
    get_response(req);
    $display("---------------------------------------------------------------------------------------------------------------------------");
   end
 endtask

endclass

class _logical_sequence_single extends uvm_sequence#(sequence_item);
 `uvm_object_utils(_logical_sequence_single)

 function new(string name ="sequence_logical_single");
   super.new(name);
 endfunction

 virtual task body();
   repeat(`no_of_transaction) begin
     `uvm_do_with(req, {req.MODE == 0; req.CMD inside {[6:11]}; req.CMD dist { [`NOT_A:`NOT_B]:=4,`SHL1_A:=3,`SHL1_B:=3}; } )
     get_response(req);
     $display("---------------------------------------------------------------------------------------------------------------------------");
   end
 endtask

endclass

class _logical_sequence_dual extends uvm_sequence#(sequence_item);
 `uvm_object_utils(_logical_sequence_dual)

 function new(string name ="sequence_logical_dual");
   super.new(name);
 endfunction

 virtual task body();
   repeat(`no_of_transaction) begin
     `uvm_do_with(req, {req.MODE == 0; req.CMD inside {[0:5], 12, 13}; req.CMD dist{[`AND:`NAND]:=4, [`NOR:`XNOR]:=4, [`ROL_A_B:`ROR_A_B]:=2 }; })
     get_response(req);
     $display("---------------------------------------------------------------------------------------------------------------------------");
   end
 endtask

endclass


class regression extends uvm_sequence#(sequence_item);
  _sequence                            seq1;
  _arithematic_sequence_single         seq2;
  _arithematic_sequence_dual           seq3;
  _logical_sequence_single             seq4;
  _logical_sequence_dual               seq5;

  `uvm_object_utils(regression)

  function new(string name="alu_regression");
    super.new(name);
  endfunction

  virtual task body();
      `uvm_do(seq1);
      `uvm_do(seq2);
      `uvm_do(seq3);
      `uvm_do(seq4);
      `uvm_do(seq5);
  endtask
endclass
