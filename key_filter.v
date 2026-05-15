`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/05/14 23:29:46
// Design Name: 
// Module Name: key_filter
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


`timescale 1ns / 1ps

module key_filter #(
    parameter CLK_FREQ = 100_000_000, // 主时钟 100MHz
    parameter DEBOUNCE_MS = 20        // 消抖时间 20ms
)(
    input  wire clk,
    input  wire rst_n,
    input  wire key_in,       // 外部异步按键输入
    output wire key_pulse     // 消抖后的单周期脉冲输出
);

    // 1. 两级寄存器同步，消除亚稳态
    reg key_sync_1, key_sync_2;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            key_sync_1 <= 1'b0;
            key_sync_2 <= 1'b0;
        end else begin
            key_sync_1 <= key_in;
            key_sync_2 <= key_sync_1;
        end
    end

    // 2. 状态变化检测与 20ms 计时消抖
    localparam MAX_CNT = CLK_FREQ / 1000 * DEBOUNCE_MS;
    reg [20:0] cnt;
    reg key_state;
    reg key_prev;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 0;
            key_state <= 1'b0;
        end else if (key_sync_2 != key_state) begin
            if (cnt == MAX_CNT - 1) begin
                key_state <= key_sync_2; // 计时确认状态稳定
                cnt <= 0;
            end else begin
                cnt <= cnt + 1;
            end
        end else begin
            cnt <= 0;
        end
    end

    // 3. 边沿检测，抓取上升沿输出脉冲
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) key_prev <= 1'b0;
        else        key_prev <= key_state;
    end

    assign key_pulse = (~key_prev) & key_state;

endmodule
