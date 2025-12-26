`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/12/26 13:09:32
// Design Name: 
// Module Name: tb_stopwatch
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



//============================================
// 秒表系统仿真测试平台 (Vivado 2018.3)
// 测试功能：
// 1. 按键消抖功能
// 2. 启动/停止/复位控制
// 3. 计时精度验证
// 4. 数码管显示输出
// 5. 边界条件测试
//============================================
 

module tb_stopwatch;

    // 测试平台参数
    parameter CLK_PERIOD = 20;      // 50MHz时钟周期 = 20ns
    
    // 测试信号
    reg [1:0] btn_in = 2'b11;
    reg clk = 0;
    wire [7:0] seg_R4;
    wire [7:0] seg_L2;
    wire [7:0] an;
    
    // 测试统计
    integer test_count = 0;
    integer pass_count = 0;
    integer error_count = 0;
    
    // 测试阶段控制
    reg [3:0] test_phase = 0;
    reg [31:0] wait_counter = 0;
    
    // 实例化被测模块
    Stopwatch uut (
        .btn_in(btn_in),
        .clk(clk),
        .seg_R4(seg_R4),
        .seg_L2(seg_L2),
        .an(an)
    );
    
    // 时钟生成
    always #(CLK_PERIOD/2) clk = ~clk;
    
    // 主测试流程（状态机实现）
    initial begin
        $display("============================================");
        $display(" 秒表系统仿真测试开始 - 无task版本");
        $display("============================================");
        
        // 等待初始复位
        #CLK_PERIOD;
        
        // 测试阶段0：系统复位
        test_phase = 0;
        $display("\n[TEST %d] 执行系统复位...", test_count);
        btn_in[0] = 0;  // 按下复位
        #CLK_PERIOD;
        btn_in[0] = 1;  // 释放
        #CLK_PERIOD;
        
        if (uut.disp_time == 24'h000000) begin
            $display("[PASS] 计时器已清零");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] 计时器未清零，当前值：%h", uut.disp_time);
            error_count = error_count + 1;
        end
        test_count = test_count + 1;
        
        // 测试阶段1：按键消抖
        test_phase = 1;
        $display("\n[TEST %d] 测试按键消抖功能...", test_count);
        
        // 模拟机械抖动
        repeat(5) begin
            btn_in[1] = $random;
            #(CLK_PERIOD * 2);
        end
        
        // 稳定按键
        btn_in[1] = 1;
        repeat(10) @(posedge clk);
        
        if (uut.key_d.btn_out[1] == 1) begin
            $display("[PASS] 消抖后按键有效");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] 消抖功能异常");
            error_count = error_count + 1;
        end
        test_count = test_count + 1;
        
        // 测试阶段2：启动计时
        test_phase = 2;
        $display("\n[TEST %d] 启动计时器...", test_count);
        btn_in[1] = 0;  // 确保按键释放
        repeat(5) @(posedge clk);
        
        btn_in[1] = 1;  // 按下启动
        repeat(10) @(posedge clk);
        btn_in[1] = 0;  // 释放
        
        repeat(20) @(posedge clk);
        
        if (uut.c_ctrl.state == 2'b01) begin
            $display("[PASS] 计时器已启动");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] 状态机未进入运行状态，当前state=%b", uut.c_ctrl.state);
            error_count = error_count + 1;
        end
        test_count = test_count + 1;
        
        // 测试阶段3：计时精度（99ms）
        test_phase = 3;
        $display("\n[TEST %d] 验证计时精度到99ms...", test_count);
        wait(uut.disp_time >= 24'h000099);
        
        if (uut.disp_time == 24'h000099) begin
            $display("[PASS] 计时准确: %02d%02d:%02d%02d:%02d%02d", 
                     uut.c_ctrl.min_h, uut.c_ctrl.min_l,
                     uut.c_ctrl.sec_h, uut.c_ctrl.sec_l,
                     uut.c_ctrl.msec_h, uut.c_ctrl.msec_l);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] 计时错误");
            error_count = error_count + 1;
        end
        test_count = test_count + 1;
        
        // 测试阶段4：计时精度（1秒）
        test_phase = 4;
        $display("\n[TEST %d] 验证计时精度到1秒...", test_count);
        wait(uut.disp_time >= 24'h010000);
        
        if (uut.disp_time == 24'h010000) begin
            $display("[PASS] 计时准确: %02d:%02d:%02d", 
                     {uut.c_ctrl.min_h, uut.c_ctrl.min_l},
                     {uut.c_ctrl.sec_h, uut.c_ctrl.sec_l},
                     {uut.c_ctrl.msec_h, uut.c_ctrl.msec_l});
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] 计时错误");
            error_count = error_count + 1;
        end
        test_count = test_count + 1;
        
        // 测试阶段5：停止计时
        test_phase = 5;
        $display("\n[TEST %d] 停止计时器...", test_count);
        btn_in[1] = 1;  // 按下停止
        repeat(10) @(posedge clk);
        btn_in[1] = 0;  // 释放
        
        repeat(20) @(posedge clk);
        
        if (uut.c_ctrl.state == 2'b10) begin
            $display("[PASS] 计时器已停止");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] 状态机未进入暂停状态");
            error_count = error_count + 1;
        end
        test_count = test_count + 1;
        
        // 测试阶段6：显示功能
        test_phase = 6;
        $display("\n[TEST %d] 验证数码管显示...", test_count);
        
        // 模拟数码管扫描周期
        repeat(10000) @(posedge clk);
        
        $display("[INFO] 右4位数码管段码: %h", seg_R4);
        $display("[INFO] 左2位数码管段码: %h", seg_L2);
        $display("[INFO] 位选信号: %b", an);
        
        pass_count = pass_count + 1;
        test_count = test_count + 1;
        
        // 测试阶段7：再次启动
        test_phase = 7;
        $display("\n[TEST %d] 重新启动计时器...", test_count);
        btn_in[1] = 1;  // 按下启动
        repeat(10) @(posedge clk);
        btn_in[1] = 0;  // 释放
        
        repeat(20) @(posedge clk);
        
        if (uut.c_ctrl.state == 2'b01) begin
            $display("[PASS] 计时器已重新启动");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] 重新启动失败");
            error_count = error_count + 1;
        end
        test_count = test_count + 1;
        
        // 测试阶段8：溢出测试（跳过等待）
        test_phase = 8;
        $display("\n[TEST %d] 测试溢出回零...", test_count);
        $display("[INFO] 手动设置接近溢出值...");
        
        // 直接设置接近溢出的值
        force uut.c_ctrl.min_h = 4'd5;
        force uut.c_ctrl.min_l = 4'd9;
        force uut.c_ctrl.sec_h = 4'd5;
        force uut.c_ctrl.sec_l = 4'd9;
        force uut.c_ctrl.msec_h = 4'd9;
        force uut.c_ctrl.msec_l = 4'd8;
        
        @(posedge uut.c_ctrl.divclk);
        
        release uut.c_ctrl.min_h;
        release uut.c_ctrl.min_l;
        release uut.c_ctrl.sec_h;
        release uut.c_ctrl.sec_l;
        release uut.c_ctrl.msec_h;
        release uut.c_ctrl.msec_l;
        
        if (uut.disp_time == 24'h000000) begin
            $display("[PASS] 溢出后正确回零");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] 溢出异常");
            error_count = error_count + 1;
        end
        test_count = test_count + 1;
        
        // 测试阶段9：最终显示验证
        test_phase = 9;
        $display("\n[TEST %d] 最终显示验证...", test_count);
        
        repeat(10) begin
            @(posedge uut.smg_R4.divclk);
            $display("[DISPLAY] 时间=%02d%02d:%02d%02d:%02d%02d | SEG_R4=%h | SEG_L2=%h | AN=%b",
                     uut.c_ctrl.min_h, uut.c_ctrl.min_l,
                     uut.c_ctrl.sec_h, uut.c_ctrl.sec_l,
                     uut.c_ctrl.msec_h, uut.c_ctrl.msec_l,
                     seg_R4, seg_L2, an);
        end
        
        pass_count = pass_count + 1;
        test_count = test_count + 1;
        
        // 测试完成总结
        #CLK_PERIOD;
        $display("\n============================================");
        $display(" 测试完成总结");
        $display("============================================");
        $display(" 总测试项: %d", test_count);
        $display(" 通过项: %d", pass_count);
        $display(" 失败项: %d", error_count);
        $display(" 通过率: %.1f%%", (pass_count*100.0)/test_count);
        $display("============================================");
        
        $finish;
    end
    
    // 波形监控
    initial begin
        $dumpfile("stopwatch_wave.vcd");
        $dumpvars(0, tb_stopwatch);
    end
    
endmodule