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


module smg(
    input clk,
    input rst,
    input [15:0] dispdata,
    output reg [ 7:0] seg,
    output reg [ 3:0] an);
    reg [16:0] divclk_cnt;
    reg divclk;
    reg [3:0] disp_dat; //要显示的数据
    reg [1:0] disp_bit; //要显示的位
    parameter maxcnt = 16'd50000;
    always@(posedge clk or negedge rst)
    begin
        if(!rst)
        begin
            divclk <= 1'b0;
            divclk_cnt <= 17'd0;
        end
        else if(divclk_cnt == maxcnt)
        begin
            divclk <= ~divclk;
            divclk_cnt <= 17'd0;
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
            an <= 4'b0000;
            disp_bit <= 2'd0;
        end
        else
        begin
            disp_bit <= disp_bit + 1'b1;
            case(disp_bit)
                2'h0:
                begin
                    disp_dat <= dispdata[3:0];
                    an <= 4'b0001;
                end
                2'h1:
                begin
                    disp_dat <= dispdata[7:4];
                    an <= 4'b0010;
                end
                2'h2:
                begin
                    disp_dat <= dispdata[11:8];
                    an <= 4'b0100;
                end
                2'h3:
                begin
                    disp_dat <= dispdata[15:12];
                    an <= 4'b1000;
                end
            endcase
        end
    end
    always@(disp_dat)
    begin
        case(disp_dat)
            4'h0: seg = 8'h3f;
            4'h1: seg = 8'h06;
            4'h2: seg = 8'h5b;
            4'h3: seg = 8'h4f;
            4'h4: seg = 8'h66;
            4'h5: seg = 8'h6d;
            4'h6: seg = 8'h7d;
            4'h7: seg = 8'h07;
            4'h8: seg = 8'h7f;
            4'h9: seg = 8'h6f;
            4'ha: seg = 8'h77;
            4'hb: seg = 8'h7c;
            4'hc: seg = 8'h39;
            4'hd: seg = 8'h5e;
            4'he: seg = 8'h79;
            4'hf: seg = 8'h71;
        endcase
    end
endmodule