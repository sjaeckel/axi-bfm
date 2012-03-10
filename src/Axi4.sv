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
  
  task ARTransfer(
    input int     delay,
    input [I-1:0] id,
    input [31:0]  addr,
    input [3:0]   region,
    input [7:0]   len,
    input [2:0]   size,
    input [1:0]   burst,
    input         lock,
    input [3:0]   cache,
    input [2:0]   prot,
    input [3:0]   qos
  );
    for(int i=0; i<delay; i++) @(posedge intf.ACLK);
    intf.ARVALID <= 1'b1;
    intf.ARID <= id;
    intf.ARADDR <= addr;
    intf.ARREGION <= region;
    intf.ARLEN <= len;
    intf.ARSIZE <= size;
    intf.ARBURST <= burst;
    intf.ARLOCK <= lock;
    intf.ARCACHE <= cache;
    intf.ARPROT <= prot;
    intf.ARQOS <= qos;
    @(posedge intf.ACLK);
    while (!intf.ARREADY) @(posedge intf.ACLK);
    intf.ARVALID <= 1'b0;
  endtask
  
  task RTransfer(
    input int         delay,
    output [I-1:0]    id,
    output [8*N-1:0]  data,
    output [1:0]      resp,
    output            last
  );
    for(int i=0; i<delay; i++) @(posedge intf.ACLK);
    intf.RREADY <= 1'b1;
    while(!intf.RVALID) @(posedge intf.ACLK);
    id = intf.RID;
    data = intf.RDATA;
    resp = intf.RRESP;
    last = intf.RLAST;
    intf.RREADY <= 1'b0;
  endtask

  task AWTransfer(
    input int     delay,
    input [I-1:0] id,
    input [31:0]  addr,
    input [3:0]   region,
    input [7:0]   len,
    input [2:0]   size,
    input [1:0]   burst,
    input         lock,
    input [3:0]   cache,
    input [2:0]   prot,
    input [3:0]   qos
  );
    for(int i=0; i<delay; i++) @(posedge intf.ACLK);
    intf.AWVALID <= 1'b1;
    intf.AWID <= id;
    intf.AWADDR <= addr;
    intf.AWREGION <= region;
    intf.AWLEN <= len;
    intf.AWSIZE <= size;
    intf.AWBURST <= burst;
    intf.AWLOCK <= lock;
    intf.AWCACHE <= cache;
    intf.AWPROT <= prot;
    intf.AWQOS <= qos;
    @(posedge intf.ACLK);
    while (!intf.AWREADY) @(posedge intf.ACLK);
    intf.AWVALID <= 1'b0;
  endtask
  
  task WTransfer(
    input int       delay,
    input [8*N-1:0] data,
    input [N-1:0]   strb,
    input           last
  );
    for(int i=0; i<delay; i++) @(posedge intf.ACLK);
    intf.WVALID <= 1'b1;
    intf.WDATA <= data;
    intf.WSTRB <= strb;
    intf.WLAST <= last;
    @(posedge intf.ACLK);
    while (!intf.WREADY) @(posedge intf.ACLK);
    intf.WVALID <= 1'b0;
  endtask
  
  task BTransfer(
    input int       delay,
    output [I-1:0]  id,
    output [1:0]    resp
  );
    for(int i=0; i<delay; i++) @(posedge intf.ACLK);
    intf.BREADY <= 1'b1;
    while(!intf.BVALID) @(posedge intf.ACLK);
    id = intf.BID;
    resp = intf.BRESP;
    intf.BREADY <= 1'b0;
  endtask
  
  task RBurst(
    input [I-1:0] id,
    input         len,
    inout byte    data[],
    inout bit [2:0] resp[],
  );
    bit [I-1:0] id_t;
    bit [255:0][N-1:0][7:0] data_t;
    bit [1:0] resp_t;
    bit last_t;
    int j=0;
    for (int i=0; i<256; i++)
    begin
      RTransfer(0, id_t, data_t[j], resp_t, last_t);
      if (id_t == id)
      begin
        j++;
        if (last_t)
        
        break;
      end
    end
  endtask
  task WBurst(
    input int   len,
    input byte  data[],
    input bit   strb[]
  );
    bit [N-1:0][7:0] data_t;
    bit [N-1:0] strb_t;
    bit last_t;
    for(int i=0; i<len; i++)
    begin
      for(int j=0; j<N; j++)
      begin
        data_t[j] = data[N*i+j];
        strb_t[j] = strb[N*i+j];
      end
      last_t = (i == (len -1));
      WTransfer(0, data_t, strb_t, last_t);
    end
  endtask
  
/*  
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
*/  
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
  
  task ARTransfer(
    input int       delay,
    output [I-1:0]  id,
    output [31:0]   addr,
    output [3:0]    region,
    output [7:0]    len,
    output [2:0]    size,
    output [1:0]    burst,
    output          lock,
    output [3:0]    cache,
    output [2:0]    prot,
    output [3:0]    qos
  );
    for(int i=0; i<delay; i++) @(posedge intf.ACLK);
    intf.ARREADY <= 1'b1;
    while (!intf.ARVALID) @(posedge intf.ACLK);
    id = intf.ARID;
    addr = intf.ARADDR;
    region = intf.ARREGION;
    len = intf.ARLEN;
    size = intf.ARSIZE;
    burst = intf.ARBURST;
    lock = intf.ARLOCK;
    cache = intf.ARCACHE;
    prot = intf.ARPROT;
    qos = intf.ARQOS;
    intf.ARREADY <= 1'b0;
  endtask
  
  task RTransfer(
    input int       delay,
    input [I-1:0]   id,
    input [8*N-1:0] data,
    input [2:0]     resp,
    input           last
  );
    for(int i=0; i<delay; i++) @(posedge intf.ACLK);
    intf.RVALID <= 1'b1;
    intf.RID <= id;
    intf.RDATA <= data;
    intf.RRESP <= resp;
    intf.RLAST <= last;
    @(posedge intf.ACLK);
    while(!intf.RREADY) @(posedge intf.ACLK);
    intf.RVALID <= 1'b0;
  endtask

  task AWTransfer(
    input int       delay,
    output [I-1:0]  id,
    output [31:0]   addr,
    output [3:0]    region,
    output [7:0]    len,
    output [2:0]    size,
    output [1:0]    burst,
    output          lock,
    output [3:0]    cache,
    output [2:0]    prot,
    output [3:0]    qos
  );
    for(int i=0; i<delay; i++) @(posedge intf.ACLK);
    intf.AWREADY <= 1'b1;
    while (!intf.AWVALID) @(posedge intf.ACLK);
    id = intf.AWID;
    addr = intf.AWADDR;
    region = intf.AWREGION;
    len = intf.AWLEN;
    size = intf.AWSIZE;
    burst = intf.AWBURST;
    lock = intf.AWLOCK;
    cache = intf.AWCACHE;
    prot = intf.AWPROT;
    qos = intf.AWQOS;
    intf.AWREADY <= 1'b0;
  endtask
  
  task WTransaer(
    input int         delay,
    output [8*N-1:0]  data,
    output [N-1:0]    strb,
    output            last
  );
    for(int i=0; i<delay; i++) @(posedge intf.ACLK);
    intf.WREADY <= 1'b1;
    while (!intf.WVALID) @(posedge intf.ACLK);
    data = intf.WDATA;
    strb = intf.WSTRB;
    last = intf.WLAST;
    intf.WREADY <= 1'b0;
  endtask
  
  task BTransfer(
    input int     delay,
    input [I-1:0] id,
    input [1:0]   resp
  );
    for(int i=0; i<delay; i++) @(posedge intf.ACLK);
    intf.BVALID <= 1'b1;
    intf.BID <= id;
    intf.BRESP <= resp;
    @(posedge intf.ACLK);
    while(!intf.BREADY) @(posedge intf.ACLK);
    intf.BVALID <= 1'b0;
  endtask
/*  
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
*/  
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
