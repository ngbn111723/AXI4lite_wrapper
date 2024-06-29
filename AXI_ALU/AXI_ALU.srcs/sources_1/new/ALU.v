`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/01/2024 08:30:51 AM
// Design Name: 
// Module Name: ALU
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


module ALU(
    input sys_clk,
    input reset,
    input[2:0] alu_op,
    output alu_result
    );
    
        
    reg[31:0] op1, op2, result;
    reg[31:0] operation1, operation2, alu_result;
    
    always @(posedge sys_clk) begin
        if (!reset) begin
            operation1 <= op1;
            operation2 <= op2; 
        end else begin
            operation1 <= 32'd0;
            operation2 <= 32'd0; 
        end
    end
    
    always @( posedge sys_clk) begin
        if (start) begin
            case (alu_op) 
                2'b00: result = operation1 + operation2;
                2'b01: result = operation1 - operation2;
                2'b10: result = operation1 & operation2;
                2'b11: result = operation1 | operation2;
                default  result= 32'd0;
            endcase
        end else result= 32'd0;
    end
    
    always @(posedge sys_clk) if (!reset) alu_result= result;
    else alu_result= 32'd0;
endmodule
