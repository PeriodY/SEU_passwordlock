`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/05/14 23:29:46
// Design Name: 
// Module Name: segment_driver
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

module segment_driver (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] display_data, // 8个位，每位4bit BCD码 (例如: [31:28]是最高位)
    output reg  [7:0]  anode,        // 位选 (AN)
    output reg  [6:0]  cathode       // 段选 (A-G)
);

    // 1. 生成 1kHz 的扫描时钟使能信号 (分频器不输出时钟，只输出 Tick)
    reg [16:0] scan_cnt;
    wire scan_tick = (scan_cnt == 100_000 - 1); 
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) scan_cnt <= 0;
        else if (scan_tick) scan_cnt <= 0;
        else scan_cnt <= scan_cnt + 1;
    end

    // 2. 动态扫描位计数器 (0-7)
    reg [2:0] scan_idx;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) scan_idx <= 0;
        else if (scan_tick) scan_idx <= scan_idx + 1;
    end

    // 3. 数据多路选择器 (MUX)
    reg [3:0] current_bcd;
    always @(*) begin
        case(scan_idx)
            3'd0: current_bcd = display_data[3:0];
            3'd1: current_bcd = display_data[7:4];
            3'd2: current_bcd = display_data[11:8];
            3'd3: current_bcd = display_data[15:12];
            3'd4: current_bcd = display_data[19:16];
            3'd5: current_bcd = display_data[23:20];
            3'd6: current_bcd = display_data[27:24];
            3'd7: current_bcd = display_data[31:28];
        endcase
    end

    // 4. BCD 译码器 
    always @(*) begin
        case(current_bcd)
            4'h0: cathode = 7'b0000001; // 显示 0 
            4'h1: cathode = 7'b1001111; // 显示 1 
            4'h2: cathode = 7'b0010010; // 显示 2 
            4'h3: cathode = 7'b0000110; // 显示 3 
            4'h4: cathode = 7'b1001100; // 显示 4 
            4'h5: cathode = 7'b0100100; // 显示 5 
            4'h6: cathode = 7'b0100000; // 显示 6 
            4'h7: cathode = 7'b0001111; // 显示 7 
            4'h8: cathode = 7'b0000000; // 显示 8 
            4'h9: cathode = 7'b0000100; // 显示 9
            default: cathode = 7'b1111111; // 默认全灭 (用 4'hF 表示不显示)
        endcase
    end

    // 5. 位选输出 (低电平有效)
    always @(*) begin
        anode = ~(8'b0000_0001 << scan_idx);
    end

endmodule
