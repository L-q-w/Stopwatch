`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/12/26 15:22:13
// Design Name: 
// Module Name: countdown_timer
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



module countdown_timer(
    input clk,
    input start_button,      // 启动倒计时按键
    input reset_button,      // 复位按键
    input [23:0] stopwatch_time, // 秒表当前时间
    output reg [23:0] disp_time, // 显示时间
    output reg led_out,      // LED提示信号
    output reg countdown_active // 倒计时激活标志
);

// 状态定义
localparam IDLE = 2'b00;
localparam COUNTING = 2'b01;
localparam FINISHED = 2'b10;

reg [1:0] state, next_state;
reg [23:0] countdown_value;  // 当前倒计时值
reg [31:0] clk_counter;      // 时钟计数器

// 计时器参数（假设100MHz时钟）
parameter CLK_FREQ = 100_000_000;    // 100MHz时钟
parameter TENTH_MS = CLK_FREQ / 100; // 0.01秒的时钟周期数（10ms）

// 时间格式：分钟(8位):秒(8位):百分秒(8位)
// 60秒 = 0分60秒00百分秒 = 24'h003C00

initial begin
    countdown_value = 24'h003C00;  // 0分60秒00百分秒
    state = IDLE;
    countdown_active = 1'b0;
    led_out = 1'b0;
end

// 状态寄存器
always @(posedge clk or posedge reset_button) begin
    if (reset_button) begin
        state <= IDLE;
    end else begin
        state <= next_state;
    end
end

// 下一状态逻辑
always @(*) begin
    next_state = state;
    case (state)
        IDLE: begin
            if (start_button) begin
                next_state = COUNTING;
            end
        end
        
        COUNTING: begin
            if (countdown_value == 24'h0) begin
                next_state = FINISHED;
            end
        end
        
        FINISHED: begin
            // 保持在完成状态直到复位
        end
        
        default: next_state = IDLE;
    endcase
end

// 倒计时逻辑（精确到0.01秒）
always @(posedge clk or posedge reset_button) begin
    if (reset_button) begin
        countdown_value <= 24'h003C00;  // 60秒00百分秒
        clk_counter <= 0;
        led_out <= 1'b0;
        countdown_active <= 1'b0;
    end else begin
        case (state)
            IDLE: begin
                countdown_value <= 24'h003C00;  // 60秒00百分秒
                clk_counter <= 0;
                led_out <= 1'b0;
                countdown_active <= 1'b0;
            end
            
            COUNTING: begin
                countdown_active <= 1'b1;
                led_out <= 1'b0;
                
                // 每0.01秒更新一次
                if (clk_counter >= TENTH_MS - 1) begin
                    clk_counter <= 0;
                    
                    // 百分秒递减
                    if (countdown_value[7:0] > 8'h00) begin  // 百分秒部分
                        countdown_value[7:0] <= countdown_value[7:0] - 8'h01;
                    end else begin
                        countdown_value[7:0] <= 8'h63;  // 99的十六进制
                        
                        // 秒递减
                        if (countdown_value[15:8] > 8'h00) begin  // 秒部分
                            countdown_value[15:8] <= countdown_value[15:8] - 8'h01;
                        end else begin
                            countdown_value[15:8] <= 8'h3B;  // 59的十六进制
                            
                            // 分钟递减
                            if (countdown_value[23:16] > 8'h00) begin  // 分钟部分
                                countdown_value[23:16] <= countdown_value[23:16] - 8'h01;
                            end else begin
                                countdown_value <= 24'h0;  // 倒计时结束
                            end
                        end
                    end
                end else begin
                    clk_counter <= clk_counter + 1;
                end
            end
            
            FINISHED: begin
                countdown_active <= 1'b1;
                led_out <= 1'b1;  // 倒计时结束，点亮LED
            end
        endcase
    end
end

// 显示时间选择逻辑
always @(*) begin
    if (countdown_active) begin
        disp_time = countdown_value;
    end else begin
        disp_time = stopwatch_time;
    end
end

endmodule
