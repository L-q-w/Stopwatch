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
    input         btn_clk,        // 系统高频时钟（如50MHz）
    input         rst,        // 复位（低有效）
    input  [1:0]  btn_in,     // 2路按键输入（低电平有效：按下=0，释放=1）
    output [1:0]  btn_out     // 2路消抖后输出（和输入有效态一致）
);

// 步骤1：分频高频时钟，生成10ms周期的采样时钟（50MHz→100Hz）
parameter CLK_FREQ = 50_000_000;  // 系统时钟频率
parameter DEBOUNCE_TIME = 10_000; // 消抖时间（10ms，单位us）
localparam CNT_MAX = CLK_FREQ / 1_000_000 * DEBOUNCE_TIME - 1; // 分频计数最大值

reg [19:0] div_cnt;  // 分频计数器（50MHz→100Hz需计数到499_999）
reg        sample_clk; // 10ms周期的采样时钟（仅上升沿采样）

always@(posedge btn_clk or negedge rst) begin
    if(!rst) begin
        div_cnt <= 20'd0;
        sample_clk <= 1'b0;
    end else if(div_cnt == CNT_MAX) begin
        div_cnt <= 20'd0;
        sample_clk <= 1'b1; // 产生采样脉冲（仅1个时钟周期）
    end else begin
        div_cnt <= div_cnt + 1'b1;
        sample_clk <= 1'b0;
    end
end

// 步骤2：采样按键值并打拍
reg [1:0] btn0;
reg [1:0] btn1;
reg [1:0] btn2;

always@(posedge btn_clk or negedge rst) begin
    if(!rst) begin
        btn0 <= 2'b11; // 复位时按键默认释放（高电平）
        btn1 <= 2'b11;
        btn2 <= 2'b11;
    end else if(sample_clk) begin // 仅在采样时钟上升沿更新
        btn0 <= btn_in;
        btn1 <= btn0;
        btn2 <= btn1;
    end
end

// 步骤3：稳定判断（连续3次采样值相同，输出有效）
assign btn_out = btn0 & btn1 & btn2;

endmodule
