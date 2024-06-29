`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/01/2024 08:09:28 AM
// Design Name: 
// Module Name: AXI_ALU
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


module AXI_ALU(
        input sys_clk,
        input reset,
        input start,
        input[2:0] alu_op,
        
        input[11:0] awaddr,
        input awvaid,
        output reg awready,
        
        input[31:0] wdata,
        input wvaid,
        output reg wready,
        
        output reg[1:0] bresp_w,
        output reg[1:0] bresp_r,
        output reg bvaid,
        input bready,
        
        input[11:0] araddr,
        input arvaid,
        output reg arready,
        
        output reg[31:0] rdata,
        output reg rvaid,
        input   rready        
    );

    reg[31:0] op1, op2, result;
    reg[31:0] operation1, operation2, alu_result;
    reg we1, we2, read_result;
//**********************************ALU*************************************
    always @(posedge sys_clk) 
        if (!reset) begin
            if (we1) operation1 = op1;   
            if (we2) operation2 = op2;        
        end else begin
            operation1 = 32'd0;
            operation2 = 32'd0; 
        end
    
    always @(*) begin
        if (start)  case (alu_op) 
                        2'b00:   result = operation1 + operation2;
                        2'b01:   result = operation1 - operation2;
                        2'b10:   result = operation1 & operation2;
                        2'b11:   result = operation1 | operation2;
                        default  result= 32'd0;
                    endcase
         else result= 32'd0;
    end
    
    always @(posedge sys_clk) if (!reset&&read_result) alu_result= result;
    else alu_result= 32'd0;
//**********************************AXI*************************************    
    reg[3:0] state, next_state;
    parameter[3:0] IDLE= 0, W_ADDR=1, WRITE=2, W_RESPONSE=3;
    parameter[3:0] R_ADDR=4, READ=5, R_RESPONSE=6;
    always @(posedge sys_clk) 
        if (reset) state = IDLE;
        else state = next_state;
    always @(*) 
        case (state)
            IDLE        : if (awvaid)  next_state= W_ADDR;
                          else  if (arvaid) next_state= R_ADDR; 
                          else next_state= IDLE;      
            W_ADDR      : if (wvaid) next_state= WRITE;
                          else next_state= IDLE;                     
            WRITE       : next_state= W_RESPONSE;   
            W_RESPONSE  : next_state= IDLE;    
            R_ADDR      : if (rready) next_state= READ;
                          else next_state= IDLE;
            READ        : next_state= R_RESPONSE;    
            R_RESPONSE  : next_state =  IDLE;                   
            default     : next_state= IDLE;
        endcase
    
    reg[11:0] address_w, address_r ;
       always @(*) 
        case (state)
            IDLE: begin
                     awready = 1'b0;
                     wready  = 1'b0;
                     bresp_w = 2'bzz;
                     bresp_r = 2'bzz;
                     bvaid   = 1'b0;
                     arready = 1'b0;
                     rdata   = 32'd0;
                     rvaid   = 1'b0;
                     we1     = 1'b0;
                     we2     = 1'b0;
                     op1     = 32'd0; 
                     op2     = 32'd0;
                 end
            W_ADDR: if (awvaid==1'b1) begin
                        address_w= awaddr;
                        awready= 1'b1;
                    end else awready= 1'b0;   
            WRITE:  case (address_w) 
								 12'h300: begin op1 =  wdata;  we1 = 1'b1;  we2 = 1'b0; wready = 1'b1; end
								 12'h310: begin op2 =  wdata;  we1 = 1'b0;  we2 = 1'b1; wready = 1'b1; end
								 default: begin op1 =  32'd0;  op2 = 32'd0; we1 = 1'b0; we2    = 1'b0; end
							endcase
            W_RESPONSE: begin bvaid= 1'b1;
                        if (wready==1'b0) bresp_w= 2'b10; //ERROR
                        else bresp_w= 2'b00; // OK
                        end     
            R_ADDR : if (awvaid==1'b1) begin
                        arready= 1'b1;
                        address_r= araddr;
                    end else arready= 1'b0;       
            READ: begin read_result= 1'b1;
                        if (araddr==12'h320) begin rdata= alu_result; rvaid = 1'b1; end
                        else begin rdata= 32'd0; rvaid = 1'b0; end
                   end 
            R_RESPONSE : begin bvaid= 1'b1;
										if (rvaid==1'b0) bresp_r= 2'b10; //ERROR
										else begin //OK
											  bresp_r= 2'b00;
											  rdata  = alu_result;
											  end
                        end
        default: begin awready= 1'b0;
                       wready = 1'b0;
                       bresp_w= 2'bzz;
                       bresp_r= 2'bzz;
                       bvaid= 1'b0;
                       arready= 1'b0;
                       rdata= 32'd0;
                       rvaid= 1'b0;
                 end
        endcase
     
endmodule
