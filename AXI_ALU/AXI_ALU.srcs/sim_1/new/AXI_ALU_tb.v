`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/01/2024 09:19:28 AM
// Design Name: 
// Module Name: AXI_ALU_tb
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



module AXI_ALU_tb();
        reg sys_clk;
        reg reset;
        reg start;
        reg[2:0] alu_op;
        
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
        
        AXI_ALU DUT(
        . sys_clk(sys_clk),
        . reset(reset),
        . start(start),
        . alu_op(alu_op),
        
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
        
        . araddr (araddr),
        . arvaid (arvaid),
        . arready (arready),
        
        . rdata (rdata),
        . rvaid (rvaid),
        . rready (rready)    
    );
    
    initial begin
        reset= 1'b1;
        start= 1'b0;
        sys_clk= 1'b0;
        alu_op= 2'b00;
        bready= 1'b1;
        wdata= 32'd00;
        wvaid= 1'b0;
        awaddr= 12'h000;
        awvaid= 1'b0;
        #10;
        reset= 1'b0;
        
        #10;
        awaddr= 12'h300;
        awvaid= 1'b1;
        #10
        awvaid= 1'b0;
        wdata= 32'd23;
        wvaid= 1'b1;
        #30;
        awaddr= 12'h310;
        awvaid= 1'b1;
        wvaid= 1'b0;
        #10
        awvaid= 1'b0;
        wdata= 32'd11;
        wvaid= 1'b1;
        #30 wvaid= 1'b0;
        start  = 1'b1;
        wvaid  = 1'b0;
        awvaid = 1'b0;

        
        #30
        araddr= 12'h320;
        arvaid= 1'b1;
        rready= 1'b1;

        #50 $stop;
    end
        
endmodule
