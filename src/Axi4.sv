module Axi4Master #(
  parameter N = 1,
  parameter I = 1
)(
  AXI4 intf
  );
  int AWDelay;
  int WDelay;
  int BDelay;
  int ARDelay;
  int RDelay;
  
  task ARTransaction(
    input int delay,
    input [31:0] addr,
    input [2:0] prot
  );
    for(int i=0; i<delay; i++) @(posedge intf.ACLK);
    intf.ARVALID <= 1'b1;
    intf.ARADDR <= addr;
    intf.ARPROT <= prot;
    @(posedge intf.ACLK);
    while (!intf.ARREADY) @(posedge intf.ACLK);
    intf.ARVALID <= 1'b0;
  endtask
  
  task RTransaction(
    input int delay,
    output [63:0] data,
    output [2:0] resp
  );
    for(int i=0; i<delay; i++) @(posedge intf.ACLK);
    intf.RREADY <= 1'b1;
    while(!intf.RVALID) @(posedge intf.ACLK);
    data = intf.RDATA;
    resp = intf.RRESP;
    intf.RREADY <= 1'b0;
  endtask

  task AWTransaction(
    input int delay,
    input bit [31:0] addr,
    input bit [2:0] prot
  );
    for(int i=0; i<delay; i++) @(posedge intf.ACLK);
    intf.AWVALID <= 1'b1;
    intf.AWADDR <= addr;
    intf.AWPROT <= prot;
    @(posedge intf.ACLK);
    while (!intf.AWREADY) @(posedge intf.ACLK);
    intf.AWVALID <= 1'b0;
  endtask
  
  task WTransaction(
    input int delay,
    input [63:0] data,
    input [7:0] strb
  );
    for(int i=0; i<delay; i++) @(posedge intf.ACLK);
    intf.WVALID <= 1'b1;
    intf.WDATA <= data;
    intf.WSTRB <= strb;
    @(posedge intf.ACLK);
    while (!intf.WREADY) @(posedge intf.ACLK);
    intf.WVALID <= 1'b0;
  endtask
  
  task BTransaction(
    input int delay,
    output [1:0] resp
  );
    for(int i=0; i<delay; i++) @(posedge intf.ACLK);
    intf.BREADY <= 1'b1;
    while(!intf.BVALID) @(posedge intf.ACLK);
    resp = intf.BRESP;
    intf.BREADY <= 1'b0;
  endtask
  
  task ReadTransaction (
    input [31:0] addr,
    input [2:0] prot,
    output [63:0] data,
    output [2:0] resp);
    ARTransaction(ARDelay, addr, prot);
    RTransaction(RDelay, data, resp);
  endtask
  
  task WriteTransaction (
    input [31:0] addr,
    input [2:0] prot,
    input [63:0] data,
    input [7:0] strb,
    output [1:0] resp);
    fork
      AWTransaction(AWDelay, addr, prot);
      WTransaction(WDelay, data, strb);
    join
    BTransaction(BDelay, resp);
  endtask
  
  always @(negedge intf.ARESETn or posedge intf.ACLK)
  begin
    if (!intf.ARESETn)
    begin
      intf.ARID     <= {I{1'b0}};
      intf.ARADDR   <= 32'b0;
      intf.ARREGION <= 4'b0;
      intf.ARLEN    <= 8'b0;
      intf.ARSIZE   <= (N==1)?3'b000:(N==2)?3'b001:(N==4)?3'b010:(N==8)?3'b011:(N==16)?3'b100:(N==32)?3'b101:(N==64)?3'b110:3'b111;
      intf.ARBURST  <= 2'b01;
      intf.ARLOCK   <= 1'b0;
      intf.ARCACHE  <= 4'b0;
      intf.ARPROT   <= 3'b0;
      intf.ARQOS    <= 4'b0;
      intf.ARVALID  <= 1'b0;
      intf.RREADY   <= 1'b0;
      intf.AWID     <= {I{1'b0}};
      intf.AWADDR   <= 32'b0;
      intf.AWREGION <= 4'b0;
      intf.AWLEN    <= 8'b0;
      intf.AWSIZE   <= (N==1)?3'b000:(N==2)?3'b001:(N==4)?3'b010:(N==8)?3'b011:(N==16)?3'b100:(N==32)?3'b101:(N==64)?3'b110:3'b111;
      intf.AWBURST  <= 2'b01;
      intf.AWLOCK   <= 1'b0;
      intf.AWCACHE  <= 4'b0;
      intf.AWPROT   <= 3'b0;
      intf.AWQOS    <= 4'b0;
      intf.AWVALID  <= 1'b0;
      intf.WDATA    <= {N{8'b0}};
      intf.WSTRB    <= {N{1'b1}};
      intf.WLAST    <= 1'b0;
      intf.WVALID   <= 1'b0;
      intf.BREADY   <= 1'b0;
    end
  end
endmodule: Axi4Master

module Axi4Slave#(
  parameter N = 1,
  parameter I = 1
)(
  AXI4 intf
  );
  int AWDelay;
  int WDelay;
  int BDelay;
  int ARDelay;
  int RDelay;
  
  task ARTransaction(
    input int delay,
    output [31:0] addr,
    output [2:0] prot
  );
    for(int i=0; i<delay; i++) @(posedge intf.ACLK);
    intf.ARREADY <= 1'b1;
    while (!intf.ARVALID) @(posedge intf.ACLK);
    addr = intf.ARADDR;
    prot = intf.ARPROT;
    intf.ARREADY <= 1'b0;
  endtask
  
  task RTransaction(
    input int delay,
    input [63:0] data,
    input [2:0] resp
  );
    for(int i=0; i<delay; i++) @(posedge intf.ACLK);
    intf.RVALID <= 1'b1;
    intf.RDATA <= data;
    intf.RRESP <= resp;
    @(posedge intf.ACLK);
    while(!intf.RREADY) @(posedge intf.ACLK);
    intf.RVALID <= 1'b0;
  endtask

  task AWTransaction(
    input int delay,
    output bit [31:0] addr,
    output bit [2:0] prot
  );
    for(int i=0; i<delay; i++) @(posedge intf.ACLK);
    intf.AWREADY <= 1'b1;
    while (!intf.AWVALID) @(posedge intf.ACLK);
    addr = intf.AWADDR;
    prot = intf.AWPROT;
    intf.AWREADY <= 1'b0;
  endtask
  
  task WTransaction(
    input int delay,
    output [63:0] data,
    output [7:0] strb
  );
    for(int i=0; i<delay; i++) @(posedge intf.ACLK);
    intf.WREADY <= 1'b1;
    while (!intf.WVALID) @(posedge intf.ACLK);
    data = intf.WDATA;
    strb = intf.WSTRB;
    intf.WREADY <= 1'b0;
  endtask
  
  task BTransaction(
    input int delay,
    input [1:0] resp
  );
    for(int i=0; i<delay; i++) @(posedge intf.ACLK);
    intf.BVALID <= 1'b1;
    intf.BRESP <= resp;
    @(posedge intf.ACLK);
    while(!intf.BREADY) @(posedge intf.ACLK);
    intf.BVALID <= 1'b0;
  endtask
  
  task ReadRequest(
    output [31:0] addr,
    output [2:0] prot
  );
    ARTransaction(ARDelay, addr, prot);
  endtask
  
  task ReadResponse(
    input [31:0] data,
    input [1:0] resp
  );
    RTransaction(RDelay, data, resp);
  endtask
  
  task WriteRequest(
    output [31:0] addr,
    output [2:0] prot,
    output [31:0] data,
    output [3:0] strb
  );
    fork
      AWTransaction(AWDelay, addr, prot);
      WTransaction(WDelay, data, strb);
    join
  endtask
  
  task WriteResponse(
    input [1:0] resp
  );
    BTransaction(BDelay, resp);
  endtask
  
  task run;
  endtask
  
  always @(negedge intf.ARESETn or posedge intf.ACLK)
  begin
    if (!intf.ARESETn)
    begin
      intf.ARREADY  <= 1'b0;
      intf.RID      <= {I{1'b0}};
      intf.RDATA    <= {N{8'b0}};
      intf.RRESP    <= 2'b0;
      intf.RLAST    <= 1'b0;
      intf.RVALID   <= 1'b0;
      intf.AWREADY  <= 1'b0;
      intf.WREADY   <= 1'b0;
      intf.BID      <= {I{1'b0}};
      intf.BRESP    <= 2'b0;
      intf.BVALID   <= 1'b0;
    end
  end
endmodule: Axi4Slave

module Axi4LiteMonitor#(
  parameter N = 1,
  parameter I = 1
)(
  AXI4Lite intf
  );
  task run;
  endtask
  
endmodule: Axi4LiteMonitor
