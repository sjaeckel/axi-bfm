`timescale 1ns/1ps

module tb;

  parameter N = 1;
  parameter I = 1;
  parameter D = 1;
  parameter U = 1;
  
  reg Clk;
  reg Rst;
  
  initial Clk = 1'b0;
  always #(5) Clk = !Clk;

  
  reg [31:0] data;
  reg [1:0] resp;
  
  initial
  begin 
    Rst = 1'b1; 
    #(2500)
    @(posedge Clk);
    Rst = 1'b0;
  end
  
  initial
  begin
    // Wait for end of reset
    @(negedge Rst);
    @(posedge Clk);
    Axi4Lite_M.WriteTransaction(32'h100, 3'b0, 32'h12345678, 4'b1011, resp);
    Axi4Lite_M.WriteTransaction(32'h12345678, 3'b0, 32'habcd, 4'b1111, resp);
    Axi4Lite_M.ReadTransaction(32'h100, 3'b0, data, resp);
    Axi4Stream_S.Receive;
    Axi4Stream_M.SendRandomPacket(200);
    Axi4Stream_M.SendRandomPacket(100);
  end

  AXI4 #(.N(8), .I(1)) axi4(.ACLK(Clk), .ARESETn(!Rst));
  AXI4Lite #(.N(4), .I(1)) axi4lite(.ACLK(Clk), .ARESETn(!Rst));
  AXI4Stream #(.N(4)) axi4stream(.ACLK(Clk), .ARESETn(!Rst));
  
  Axi4LiteMaster #(.N(4), .I(1)) Axi4Lite_M(.intf(axi4lite));
  Axi4LiteSlave #(.N(4), .I(1)) Axi4Lite_S(.intf(axi4lite));
  Axi4StreamMaster #(.N(4), .I(1), .D(1), .U(1)) Axi4Stream_M(.intf(axi4stream));
  Axi4StreamSlave #(.N(4), .I(1), .D(1), .U(1)) Axi4Stream_S(.intf(axi4stream));
  Axi4MasterBFM #(.N(8), .I(1)) Axi4_M(.intf(axi4));
  Axi4SlaveBFM #(.N(8), .I(1)) Axi4_S(.intf(axi4));

endmodule : tb