`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/12/26 01:15:54
// Design Name: 
// Module Name: key_debounce
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


module key_debounce (
    input btn_clk,
    input rst,
    input [1:0]btn_in,
    output [1:0]btn_out);
    reg [1:0]btn0;
    reg [1:0]btn1;
    reg [1:0]btn2;
    assign btn_out = btn0 & btn1 & btn2;
    always@ (posedge btn_clk or negedge rst)
    begin
        if(!rst)
        begin
            btn0 <= 1'b0;
            btn1 <= 1'b0;
            btn2 <= 1'b0;
        end
        else
        begin
            btn0 <= btn_in;
            btn1 <= btn0;
            btn2 <= btn1;
        end
    end
endmodule
