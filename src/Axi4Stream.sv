
module Axi4StreamMaster #(
  parameter N = 1,
  parameter I = 1,
  parameter D = 1,
  parameter U = 1
)(
  AXI4Stream intf
);

  task Send(
    input bit [8*N-1:0] data[],
    input bit [N-1:0] strb[],
    input bit [N-1:0] keep[],
    input bit [I-1:0] id[],
    input bit [D-1:0] dest[],
    input bit [U-1:0] user[],
    input int length
  );
    intf.TVALID <= 1'b1;
    for(int i=0; i<length; i++)
    begin
      intf.TDATA <= data[i];
      intf.TSTRB <= strb[i];
      intf.TKEEP <= keep[i];
      intf.TID <= id[i];
      intf.TDEST <= dest[i];
      intf.TUSER <= user[i];
      intf.TLAST <= (i==(length-1));
      @(posedge intf.ACLK);
      while (!intf.TREADY) @(posedge intf.ACLK);
    end
    intf.TVALID <= 1'b0;
  endtask
  
  task SendRandom(
    input int length
  );
    bit [8*N-1:0] data[] = new[length];
    bit [N-1:0] strb[] = new[length];
    bit [N-1:0] keep[] = new[length];
    bit [I-1:0] id[] = new[length];
    bit [D-1:0] dest[] = new[length];
    bit [U-1:0] user[] = new[length];
    for(int i=0; i<length; i++)
    begin
      data[i] = $random();
      strb[i] = $random();
      keep[i] = $urandom();
      id[i] = $urandom();
      dest[i] = $urandom();
      user[i] = $urandom();
    end
    Send(data, strb, keep, id, dest, user, length);
  endtask

  always @(negedge intf.ARESETn or posedge intf.ACLK)
  begin
    if (!intf.ARESETn)
    begin
      intf.TVALID <= 1'b0;
      intf.TDATA <= {N{8'b0}};
      intf.TSTRB <= {N{1'b0}};
      intf.TKEEP <= {N{1'b0}};
      intf.TLAST <= 1'b0;
      intf.TID <= {I{1'b0}};
      intf.TDEST <= {D{1'b0}};
      intf.TUSER <= {U{1'b0}};
    end
  end
endmodule: Axi4StreamMaster

module Axi4StreamSlave#(
  parameter N = 1,
  parameter I = 1,
  parameter D = 1,
  parameter U = 1
)(
  AXI4Stream intf
);
  
  task Receive(
    output [8*N-1:0] data[],
    output [N-1:0] strb[],
    output [N-1:0] keep[],
    output [I-1:0] id[],
    output [D-1:0] dest[],
    output [U-1:0] user[],
    output int length
  );
    intf.TREADY <= 1'b1;
  endtask
  
  always @(negedge intf.ARESETn or posedge intf.ACLK)
  begin
    if (!intf.ARESETn)
      intf.TREADY <= 1'b0;
  end
endmodule: Axi4StreamSlave

  
module Axi4StreamMonitor#(
  parameter N = 1,
  parameter I = 1,
  parameter D = 1,
  parameter U = 1
)(
  AXI4Stream intf
);
endmodule
