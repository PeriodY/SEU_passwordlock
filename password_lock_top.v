`timescale 1ns / 1ps

module password_lock_top (
    input  wire clk,         
    input  wire rst_n,       
    
    input  wire [3:0] sw,    
    input  wire btnc,        
    input  wire btnu,        
    input  wire btnl,        
    input  wire btnr,        
    
    output wire [7:0] an,    
    output wire [6:0] seg,   
    output reg  [4:0] led    
);

    wire pulse_num_enter, pulse_confirm, pulse_backspace, pulse_admin;
    key_filter kf_enter (.clk(clk), .rst_n(rst_n), .key_in(btnc), .key_pulse(pulse_num_enter));
    key_filter kf_conf  (.clk(clk), .rst_n(rst_n), .key_in(btnu), .key_pulse(pulse_confirm));
    key_filter kf_back  (.clk(clk), .rst_n(rst_n), .key_in(btnl), .key_pulse(pulse_backspace));
    key_filter kf_adm   (.clk(clk), .rst_n(rst_n), .key_in(btnr), .key_pulse(pulse_admin));

    // 提取一个总的用户按键动作信号，用于打断吞秒
    wire action = pulse_num_enter || pulse_confirm || pulse_backspace || pulse_admin;

    localparam S_IDLE  = 3'd0,
               S_INPUT = 3'd1,
               S_OPEN  = 3'd2,
               S_ADMIN = 3'd3,
               S_ALARM = 3'd4,
               S_WEAK  = 3'd5;
               
    reg [2:0] current_state, next_state;

    reg [23:0] pwd_buffer;   
    reg [2:0]  pwd_idx;      
    reg [23:0] saved_pwd;    
    reg [1:0]  err_cnt;      
    
    wire is_weak = (pwd_buffer[23:20] == pwd_buffer[19:16]) &&
                   (pwd_buffer[19:16] == pwd_buffer[15:12]) &&
                   (pwd_buffer[15:12] == pwd_buffer[11:8])  &&
                   (pwd_buffer[11:8]  == pwd_buffer[7:4])   &&
                   (pwd_buffer[7:4]   == pwd_buffer[3:0]);

    reg [26:0] clk_1hz_cnt;
    wire tick_1hz = (clk_1hz_cnt == 100_000_000 - 1);
    reg [5:0]  timer_sec;    

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) clk_1hz_cnt <= 0;
        else if (action) clk_1hz_cnt <= 0; // 只要有按键，彻底重置1秒滴答，解决闪跳14秒问题
        else if (tick_1hz) clk_1hz_cnt <= 0;
        else clk_1hz_cnt <= clk_1hz_cnt + 1;
    end
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) current_state <= S_IDLE;
        else        current_state <= next_state;
    end

    always @(*) begin
        next_state = current_state; 
        case (current_state)
            S_IDLE: begin
                if (pulse_num_enter) next_state = S_INPUT;
                else if (pulse_admin) next_state = S_ADMIN;
            end
            S_INPUT: begin
                if (timer_sec == 0) next_state = S_IDLE; 
                else if (pulse_confirm) begin
                    if (pwd_buffer == saved_pwd && pwd_idx == 6) next_state = S_OPEN;
                    else if (err_cnt == 2) next_state = S_ALARM; 
                    else next_state = S_INPUT; 
                end
                else if (pulse_admin) next_state = S_ADMIN;
            end
            S_OPEN: begin
                if (timer_sec == 0) next_state = S_IDLE; 
                else if (pulse_confirm) next_state = S_IDLE; 
            end
            S_ALARM: begin
                if (pulse_admin) next_state = S_IDLE; 
            end
            S_ADMIN: begin
                if (pulse_confirm && pwd_idx == 6) begin
                    if (is_weak) next_state = S_WEAK; 
                    else next_state = S_IDLE;
                end
            end
            S_WEAK: begin
                if (pulse_confirm) next_state = S_ADMIN;
            end
            default: next_state = S_IDLE;
        endcase
    end

    // 第三段：数据与输出控制
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pwd_buffer <= 24'hFFFFFF; 
            pwd_idx    <= 0;
            saved_pwd  <= 24'h123456; 
            timer_sec  <= 0;
            err_cnt    <= 0;
            led        <= 5'b00000;
        end else begin
            if (tick_1hz && timer_sec > 0) timer_sec <= timer_sec - 1;
            
            case (current_state)
                S_IDLE: begin
                    pwd_buffer <= 24'hFFFFFF;
                    pwd_idx <= 0;
                    led <= 5'b00000; 
                    if (pulse_num_enter) timer_sec <= 15; // 进入输入态赋15秒
                end
                
                S_INPUT: begin
                    led <= 5'b00001; 
                    if (pulse_num_enter && pwd_idx < 6 && sw <= 4'd9) begin
                        pwd_buffer <= {pwd_buffer[19:0], sw}; 
                        pwd_idx <= pwd_idx + 1;
                        timer_sec <= 15; 
                    end
                    else if (pulse_backspace && pwd_idx > 0) begin
                        pwd_buffer <= {4'hF, pwd_buffer[23:4]}; 
                        pwd_idx <= pwd_idx - 1;
                        timer_sec <= 15; 
                    end
                    else if (pulse_confirm && pwd_idx == 6) begin
                        if (pwd_buffer == saved_pwd) begin
                            err_cnt <= 0; 
                            timer_sec <= 30; // 密码正确时，立刻在此处赋值 30 秒
                        end else begin
                            err_cnt <= err_cnt + 1;   
                            pwd_buffer <= 24'hFFFFFF; 
                            pwd_idx <= 0;
                            timer_sec <= 15;
                        end
                    end
                end
                
                S_OPEN: begin
                    led <= 5'b00010; 
                   
                end
                
                S_ALARM: begin
                    led <= 5'b00100; 
                    pwd_buffer <= 24'hFFFFFF; 
                    if (pulse_admin) err_cnt <= 0; 
                end
                
                S_ADMIN: begin
                    led <= 5'b01000; 
                    if (pulse_num_enter && pwd_idx < 6 && sw <= 4'd9) begin
                        pwd_buffer <= {pwd_buffer[19:0], sw};
                        pwd_idx <= pwd_idx + 1;
                    end
                    else if (pulse_backspace && pwd_idx > 0) begin
                        pwd_buffer <= {4'hF, pwd_buffer[23:4]};
                        pwd_idx <= pwd_idx - 1;
                    end
                    else if (pulse_confirm && pwd_idx == 6) begin
                        if (!is_weak) saved_pwd <= pwd_buffer; // 增加拦截，坚决不保存弱密码
                    end
                end
                
                S_WEAK: begin
                    led <= 5'b10000; // 看到 LED4 亮起，说明触发了弱密码警告
                    if (pulse_confirm) begin
                        pwd_buffer <= 24'hFFFFFF;
                        pwd_idx <= 0;
                    end
                end
            endcase
        end
    end

    wire [31:0] display_bus;
    wire [3:0] sec_tens = timer_sec / 10;
    wire [3:0] sec_ones = timer_sec % 10;
    
    assign display_bus = (current_state == S_OPEN || current_state == S_INPUT) ? 
                         {sec_tens, sec_ones, pwd_buffer} : 
                         {4'hF, 4'hF, pwd_buffer}; 

    segment_driver seg_inst (
        .clk(clk),
        .rst_n(rst_n),
        .display_data(display_bus),
        .anode(an),
        .cathode(seg)
    );

endmodule