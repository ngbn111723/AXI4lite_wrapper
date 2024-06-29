`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/28/2024 07:12:03 PM
// Design Name: 
// Module Name: AXI_FIFO_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module AXI_FIFO_tb();
    reg sys_clk;
    reg reset;

    
    reg[11:0] awaddr;
    reg awvaid;
    wire awready;
    
    reg[31:0] wdata;
    reg wvaid;
    wire wready;
    
    wire [1:0] bresp_w;
    wire [1:0] bresp_r;
    wire  bvaid;
    reg bready;
    
    reg[11:0] araddr;
    reg arvaid;
    wire arready;
    
    wire [31:0] rdata;
    wire  rvaid;
    reg   rready;
    

    
    always #5 sys_clk= ~sys_clk;
    
    AXI_FIFO DUT(
    . sys_clk(sys_clk),
    . reset(reset),
    
    . awaddr (awaddr),
    . awvaid (awvaid),
    . awready (awready),
    
    . wdata (wdata),
    . wvaid (wvaid),
    . wready (wready),
    
    . bresp_r (bresp_r),
    . bresp_w (bresp_w),
    . bvaid (bvaid),
    . bready (bready),
    
    . araddr  (araddr),
    . arvaid (arvaid),
    . arready (arready),
    

    . rdata (rdata),
    . rvaid (rvaid),
    . rready (rready)    
    );
    initial begin
        reset   = 1'b1;
        sys_clk = 1'b0;
        bready  = 1'b1;
        wdata   = 32'd00;
        wvaid   = 1'b0;
        awvaid  = 1'b0;
       #10 reset   = 1'b0;
       awaddr  = 12'h310;
       araddr  = 12'h320;
        for (integer i=0; i<8; i=i+1) begin
            #10;
            awvaid  = 1'b1;
            
            #10
            awvaid  = 1'b0;
            wvaid   = 1'b1;
            wdata   = i;
            #30;
        end
        wvaid   = 1'b0;
        wdata   = 32'dz;
        #30;
        for (integer i=0; i<8; i=i+1) begin
            arvaid= 1'b1;
            rready= 1'b1;
            #50;
        end
        
    #10;
        $stop;
    end
    

endmodule
