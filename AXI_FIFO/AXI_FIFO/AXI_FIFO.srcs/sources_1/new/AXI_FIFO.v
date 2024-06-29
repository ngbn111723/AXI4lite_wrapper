`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/28/2024 06:42:23 PM
// Design Name: 
// Module Name: AXI_FIFO
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


module AXI_FIFO(
        input sys_clk,
        input reset,
        
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
//*****************FIFO*******************************    
    reg[31:0] DIN, DOUT, RAM [7:0];
    reg Wen, Ren;
    wire Full,  Empty;
    reg[2:0] Wptr, Rptr;
    reg[3:0] counter;
    always @(posedge sys_clk or posedge  reset) 
        if (reset) {Wptr, Rptr, counter} = 0;
        else begin
            if (Wen&&!Full) begin
                RAM[Wptr] = DIN;
                Wptr  = (Wptr + 1)%8;
                counter = counter+1; end  
            if (Ren&&!Empty) begin
                DOUT = RAM[Rptr];
                RAM[Rptr] = 32'dz;
                Rptr = (Rptr + 1)%8;
                counter = counter-1;
            end 
        end 
    assign       Empty= (counter==0)?1:0;
    assign       Full = (counter==8)?1:0;
    
//*************************AXI***************************  
    reg [11:0] w_addr, r_addr;  
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
    
       always @(*) 
        case (state)
            IDLE        : begin {awready, wready, bvaid, arready, rvaid, Wen, Ren} = 7'd0;
                            {bresp_w, bresp_r}= 4'bzzzz;
                            rdata= 32'd0;
                          end
            W_ADDR      : {wready, w_addr}= {1'b1, awaddr};      
            WRITE       : if (w_addr== 12'h310) {Wen, DIN, wready}= {1'b1,wdata,1'b1}; 
                          else {Wen, wready} =2'b00;
            W_RESPONSE  : begin 
                            {bvaid,Wen,wready}  = 3'b100;
                            if (wready==1'b0) bresp_w= 2'b10; //ERROR
                            else bresp_w= 2'b00; // OK
                          end     
            R_ADDR      : {arready, r_addr}= {1'b1, araddr};   
            READ        : if (r_addr==12'h320) {Ren, rdata, rvaid}   = {1'b1, DOUT, 1'b1};
                          else {Ren, rvaid}   = 2'b00;
            R_RESPONSE  : begin
                            {bvaid, Ren, rvaid}= 3'b100;
                            if (rvaid==1'b0) bresp_r= 2'b10; //ERROR
                            else bresp_r= 2'b00; //OK
                         end
        default: begin {awready, wready, bvaid, arready, rvaid, Wen, Ren} = 7'd0;
                       {bresp_w, bresp_r}= 4'bzzzz;
                       rdata= 32'd0;
                 end
        endcase  
endmodule

