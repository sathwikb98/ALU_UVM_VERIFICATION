interface inf(input CLK, RST, CE);
  // INPUTS
  logic [1:0] INP_VALID;
  logic MODE, CIN;
  logic [`CMD_WIDTH-1 :0] CMD;
  logic [`OP_WIDTH-1: 0] OPA, OPB;
  // OUTPUTS
  logic ERR, OFLOW, COUT, G, L, E;
  logic [`OP_WIDTH:0] RES;

  clocking drv_cb@(posedge CLK);
    input OPA, OPB, MODE, CIN, CMD, INP_VALID;
  endclocking

  clocking mon_cb@(posedge CLK);
    input RES, COUT, OFLOW, G, L, E, ERR;
  endclocking

    //Assertions

//Check if all inputs are valid when CE is high
  property valid_ip;
    @(posedge CLK)
    disable iff(RST) CE |=> not($isunknown({OPA, OPB, CIN, MODE, CMD, INP_VALID}));
  endproperty
  assert property(valid_ip)begin
    //$info("Valid Inputs Pass");
  end
  else begin
    $error("Valid Inputs Fail");
  end

  //Check 16 cycle error condition
  property loop_err;
    @(posedge CLK)
    disable iff(RST) (CE && (INP_VALID == 2'b01 || INP_VALID == 2'b10) && ( MODE == 1 && CMD inside {[0:3],[8:10]} || (MODE == 0 && CMD inside {[0:5], 12, 13}) ) ) |-> ( ##[0:16] INP_VALID == 2'b11 ) or ERR;
  endproperty
  assert property(loop_err)begin
    //$info("Loop error condition Pass");
  end
  else begin
    $info("Loop error condition Fail");
  end

  //Rotate error
  property rotate_err;
    @(posedge CLK)
    disable iff(RST) (CE && INP_VALID == 3 && MODE == 0 && (CMD == 12 || CMD == 13) && OPB[7:4] > 0) |=> ERR;
  endproperty
  assert property(rotate_err)begin
    //$info("Rotate Error Condition Pass");
  end
  else begin
    $info("Rotate Error Condition Fail");
  end

  //Cen stable
  property stable_cen;
    @(posedge CLK) CE |=> $stable(CE);
  endproperty
  assert property(stable_cen)begin
    //$info("Stable Cen Pass");
  end
  else begin
    $error("Stable Cen Fail");
  end

  //Check if asserting reset is making outputs z
  property rst_check;
    @(posedge CLK)
    RST |=> ( RES === 9'bzzzzzzz && COUT === 1'bz && OFLOW === 1'bz && E === 1'bz && G === 1'bz && L === 1'bz && ERR === 1'bz );
  endproperty
  assert property(rst_check)begin
    //$info("Reset Check Pass");
  end
  else begin
    $error("Reset Check Fail");
  end

endinterface
