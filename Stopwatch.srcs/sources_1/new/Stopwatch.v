`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/12/26 01:18:28
// Design Name: 
// Module Name: Stopwatch
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


module Stopwatch(
    input [1:0]btn_in,
    input clk,
    output [7:0]seg_R4,
    output [7:0]seg_L2,
    output [7:0]an
    );
    wire [23:0]disp_time;
    wire [1:0]btn_out;
    reg [7:0]an_reg;
    count_ctrl c_ctrl(
        .start_stop(btn_out[1]),
        .clk(clk),
        .rst(~btn_in[0]),
        .disp_time(disp_time));
    key_debounce key_d(
        .btn_clk(clk),
        .rst(~btn_in[0]),
        .btn_in(btn_in),
        .btn_out(btn_out));
    smg smg_R4(
        .clk(clk),
        .rst(~btn_in[0]),
        .dispdata(disp_time[15:0]),
        .seg(seg_R4),
        .an(an[3:0]));
    smg smg_L2(
        .clk(clk),
        .rst(~btn_in[0]),
        .dispdata({8'b0,disp_time[23:16]}),
        .seg(seg_L2),
        .an(an[7:4]));
    
    initial begin
        an_reg = 8'b00111111;
         
    end
    always @(posedge clk) begin
        
    end
assign an = an_reg;      
endmodule
