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
    output [7:0]an,
    output countdown_led  // 新增：倒计时提示LED
);
    wire [23:0]disp_time;
    wire [23:0]stopwatch_time;  // 秒表原始时间
    wire [1:0]btn_out;
    reg [3:0]dp_ctrl_R4;
    reg [3:0]dp_ctrl_L2;
    
    // 倒计时模块信号
    wire countdown_active;      // 倒计时激活标志
    wire [23:0]countdown_disp;  // 倒计时显示时间
    
    // 秒表控制模块（将disp_time输出到中间信号）
    count_ctrl c_ctrl(
        .start_stop(btn_out[1] & ~countdown_active), // 倒计时激活时禁用秒表
        .clk(clk),
        .rst(~btn_out[0]),
        .disp_time(stopwatch_time)  // 输出到中间信号
    );
    
    key_debounce key_d(
        .btn_clk(clk),
        .rst(1'b0),
        .btn_in(btn_in),
        .btn_out(btn_out)
    );
    
    // 倒计时模块实例化
    countdown_timer countdown_inst(
        .clk(clk),
        .start_button(btn_out[1]),      // 启动按键
        .reset_button(~btn_out[0]),     // 复位按键（使用消抖后的信号）
        .stopwatch_time(stopwatch_time), // 秒表当前时间
        .disp_time(countdown_disp),     // 倒计时显示时间
        .led_out(countdown_led),        // LED输出
        .countdown_active(countdown_active) // 倒计时激活标志
    );
    
    // 数码管模块1
    smg smg_R4(
        .clk(clk),
        .rst(~btn_out[0]),
        .dp_ctrl(dp_ctrl_R4),
        .dispdata(disp_time[15:0]),
        .seg(seg_R4),
        .an()
    );
    
    // 数码管模块2
    smg smg_L2(
        .clk(clk),
        .rst(~btn_in[0]),
        .dp_ctrl(dp_ctrl_L2),
        .dispdata({8'b0, disp_time[23:16]}),
        .seg(seg_L2),
        .an()
    );
    
    // 显示时间选择：倒计时激活时显示倒计时，否则显示秒表
    assign disp_time = countdown_active ? countdown_disp : stopwatch_time;
    
    // 数码管控制逻辑
    always @(posedge clk or posedge btn_out[0]) begin
        if (btn_out[0]) begin
            dp_ctrl_R4 <= 4'b0101;
            dp_ctrl_L2 <= 4'b0001; 
        end
    end
    
assign an = 8'b00111111;      
endmodule
    