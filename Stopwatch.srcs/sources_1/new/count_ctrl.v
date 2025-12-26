`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/12/26 01:11:37
// Design Name: 
// Module Name: smg
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

module count_ctrl(
    input start_stop,
    input clk,
    input rst,
    output [23:0] disp_time);
 
    reg [19:0] divclk_cnt;
    reg divclk;
    reg [3:0] msec_l;
    reg [3:0] msec_h; 
    reg [3:0] sec_l;
    reg [3:0] sec_h;
    reg [3:0] min_l;
    reg [3:0] min_h;
    reg [1:0]state;
    reg start_stop_dly;
    assign disp_time = {min_h, min_l, sec_h, sec_l, msec_h, msec_l};
    
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            state <= 2'b00;
            start_stop_dly <= 1'b0;  // 清零延迟寄存器
        end else begin
            start_stop_dly <= start_stop;  // 延迟一拍
            
            // 检测上升沿（真正的"按下"动作）
            if (start_stop && !start_stop_dly) begin
                case (state)
                    2'b00: state <= 2'b01;  // 空闲 -> 运行
                    2'b01: state <= 2'b10;  // 运行 -> 暂停
                    2'b10: state <= 2'b01;  // 暂停 -> 运行
                    default: state <= 2'b00;
                endcase
            end
        end
    end
    
    always@(posedge clk or negedge rst)
    begin
        if(!rst)
        begin
            divclk <= 1'b0;
            divclk_cnt <= 20'd0;
        end
        else if(divclk_cnt == 20'd500000 - 1'b1)
        begin
            divclk <= ~divclk;
            divclk_cnt <= 20'd0;
        end
        else
        begin
            divclk_cnt <= divclk_cnt + 1'b1;
        end
    end
    always@(posedge divclk or negedge rst)
    begin
        if(!rst)
        begin
            msec_l <= 4'd0; 
            msec_h <= 4'd0;
            sec_l <= 4'd0; 
            sec_h <= 4'd0; 
            min_l <= 4'd0; 
            min_h <= 4'd0; 
        end
        else if(state == 2'b01)
        begin
            msec_l <= msec_l + 1'b1;
            if(msec_l == 4'd9)
            begin
                msec_l <= 4'd0;
                msec_h <= msec_h + 1'b1;
                if(msec_h == 4'd9)
                begin
                    msec_h <= 4'd0;
                    sec_l <= sec_l +1'b1;
                    if(sec_l == 4'd9)
                    begin
                        sec_l <= 4'd0;
                        sec_h <= sec_h + 1'b1;
                        if(sec_h == 4'd5)
                        begin
                            sec_h <= 4'd0;
                            min_l <= min_l +1'b1;
                            if(min_l == 4'd9)
                            begin
                                min_l <= 4'd0;
                                min_h <= min_h + 1'b1;
                                if(min_h == 4'd5)
                                begin
                                    min_h <= 4'd0;
                                end
                            end
                        end
                    end
                end
            end
        end
    end 
endmodule