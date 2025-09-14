`timescale 1ns / 1ps

module digital_segment( 
input [9:0]pwds,
input [9:0]pwd0,pwd1,pwd2,pwd3,pwd4,pwd5,//输入密码
input backspace,//退格
input reset,
input reset_stable,//复位
input clk_400hz,//分频时钟
input [5:0]countdown,//倒计时
output reg[6:0]o_segment_display,//数码管显示，7段
output reg[7:0]o_AN,//选择数码管
output reg[9:0]o_pwds0,o_pwds1,o_pwds2,o_pwds3,o_pwds4,o_pwds5);

reg [6:0]segment_record0= 7'b0111111,segment_record1= 7'b0111111,segment_record2= 7'b0111111,segment_record3= 7'b0111111,segment_record4= 7'b0111111,segment_record5= 7'b0111111; 
reg [6:0]segment_record6=7'b0111111,segment_record7= 7'b0111111; //分别用于记录各个数码管的数据
reg [3:0]pwds_place=0;                                                        //用于定位数码管以及pwds数据
reg [9:0]pwds_prev=0;                                                         //用于与现在的pwds比较从而接受来自板子上的输入数据
reg [9:0]pwds0=0,pwds1=0,pwds2=0,pwds3=0,pwds4=0,pwds5=0;                    //用于记录各个pwds数据
reg [2:0]scan;                                                             //用于循环亮起数码管
reg backspace_record;                                                       //退格键                                                         
reg once=0;                                                              //接受来自外部的信号一次



always@(*)begin
     o_pwds0=pwds0;
     o_pwds1=pwds1;
     o_pwds2=pwds2;
     o_pwds3=pwds3;
     o_pwds4=pwds4;  
     o_pwds5=pwds5;
end//根据密码输入改变

   integer i;integer j;
   always @(posedge clk_400hz) begin
    if(!once)begin
     for(j=0;j<10;j=j+1)begin
        pwds0[j]=pwd0[j];pwds1[j]=pwd1[j];pwds2[j]=pwd2[j];pwds3[j]=pwd3[j];pwds4[j]=pwd4[j];pwds5[j]=pwd5[j];
         pwds_place<=pwds_place+pwd0[j]+pwd1[j]+pwd2[j]+pwd3[j]+pwd4[j]+pwd5[j];
     end
     once<=1;
    end//检测输入值，根据输入改变密码位置指针的值

    //退格
    backspace_record<=backspace;
        if((backspace&&!backspace_record))begin
            if(pwds_place)begin
             pwds_place<=pwds_place-1;
             case(pwds_place)
            4'b0001:begin
                pwds0=0;
            end
            4'b0010:begin
                pwds1=0;
            end
            4'b0011:begin
                pwds2=0;
            end
            4'b0100:begin
                pwds3=0;
            end
            4'b0101:begin
                pwds4=0;
            end
            4'b0110:begin
                pwds5=0;
            end
            
             endcase
            end
        end//如果输入退格键则内容清零，指针退一位

    //复位
    if(reset||reset_stable)begin
        pwds_place<=0;
        pwds0=0;pwds1=0;pwds2=0;pwds3=0;pwds4=0;pwds5=0;
    end

   if(pwds_place==4'b0111)begin pwds_place<=4'b0110;end


    //检测输入按钮输入的信号
    pwds_prev<=pwds;
    for(i=0;i<10;i=i+1)begin
            if (pwds[i]&&!pwds_prev[i]) begin
               pwds_place<=pwds_place+1;
            case(pwds_place)
            4'b0000: begin pwds0=pwds;
            end
            4'b0001: begin pwds1=pwds;
            end
            4'b0010: begin pwds2=pwds;
            end
            4'b0011: begin pwds3=pwds;
            end
            4'b0100: begin pwds4=pwds;
            end
            4'b0101: begin pwds5=pwds;
            end
            
               endcase
            end
        end
    end

    always@(pwds0,pwds1,pwds2,pwds3,pwds4,pwds5)begin//根据输入的值设置需要展示的数字7段值
            case(pwds0)
            9'b0000000001: segment_record0 = 7'b1000000; // 0
            9'b0000000010: segment_record0 = 7'b1111001; // 1
            9'b0000000100: segment_record0 = 7'b0100100; // 2
            9'b0000001000: segment_record0 = 7'b0110000; // 3
            9'b0000010000: segment_record0 = 7'b0011001; // 4
            9'b0000100000: segment_record0 = 7'b0010010; // 5
            9'b0001000000: segment_record0 = 7'b0000010; // 6
            9'b0010000000: segment_record0 = 7'b1111000; // 7
            9'b0100000000: segment_record0 = 7'b0000000; // 8
            10'b1000000000:segment_record0 = 7'b0010000; // 9
            default: segment_record0 = 7'b0111111; // Blank
                endcase
    
            case(pwds1)
            9'b0000000001: segment_record1 = 7'b1000000; // 0
            9'b0000000010: segment_record1= 7'b1111001; // 1
            9'b0000000100: segment_record1 = 7'b0100100; // 2
            9'b0000001000: segment_record1 = 7'b0110000; // 3
            9'b0000010000: segment_record1 = 7'b0011001; // 4
            9'b0000100000: segment_record1 = 7'b0010010; // 5
            9'b0001000000: segment_record1 = 7'b0000010; // 6
            9'b0010000000: segment_record1 = 7'b1111000; // 7
            9'b0100000000: segment_record1 = 7'b0000000; // 8
            10'b1000000000: segment_record1 = 7'b0010000; // 9
            default: segment_record1 = 7'b0111111; // Blank
                endcase
            case(pwds2)
            9'b0000000001: segment_record2 = 7'b1000000; // 0
            9'b0000000010: segment_record2 = 7'b1111001; // 1
            9'b0000000100: segment_record2 = 7'b0100100; // 2
            9'b0000001000: segment_record2 = 7'b0110000; // 3
            9'b0000010000: segment_record2 = 7'b0011001; // 4
            9'b0000100000: segment_record2 = 7'b0010010; // 5
            9'b0001000000: segment_record2 = 7'b0000010; // 6
            9'b0010000000: segment_record2 = 7'b1111000; // 7
            9'b0100000000: segment_record2 = 7'b0000000; // 8
            10'b1000000000: segment_record2 = 7'b0010000; // 9
            default: segment_record2 = 7'b0111111; // Blank
                endcase
            case(pwds3)
            9'b0000000001: segment_record3 = 7'b1000000; // 0
            9'b0000000010: segment_record3 = 7'b1111001; // 1
            9'b0000000100: segment_record3 = 7'b0100100; // 2
            9'b0000001000: segment_record3 = 7'b0110000; // 3
            9'b0000010000: segment_record3 = 7'b0011001; // 4
            9'b0000100000: segment_record3 = 7'b0010010; // 5
            9'b0001000000: segment_record3 = 7'b0000010; // 6
            9'b0010000000: segment_record3 = 7'b1111000; // 7
            9'b0100000000: segment_record3 = 7'b0000000; // 8
            10'b1000000000: segment_record3 = 7'b0010000; // 9
            default: segment_record3= 7'b0111111; // Blank
                endcase
            case(pwds4)
            9'b0000000001: segment_record4 = 7'b1000000; // 0
            9'b0000000010: segment_record4 = 7'b1111001; // 1
            9'b0000000100: segment_record4 = 7'b0100100; // 2
            9'b0000001000: segment_record4 = 7'b0110000; // 3
            9'b0000010000: segment_record4 = 7'b0011001; // 4
            9'b0000100000: segment_record4 = 7'b0010010; // 5
            9'b0001000000: segment_record4 = 7'b0000010; // 6
            9'b0010000000: segment_record4 = 7'b1111000; // 7
            9'b0100000000: segment_record4 = 7'b0000000; // 8
            10'b1000000000:segment_record4 = 7'b0010000; // 9
            default: segment_record4 = 7'b0111111; // Blank
                endcase
            case(pwds5)
            9'b0000000001: segment_record5 = 7'b1000000; // 0
            9'b0000000010: segment_record5 = 7'b1111001; // 1
            9'b0000000100: segment_record5 = 7'b0100100; // 2
            9'b0000001000: segment_record5 = 7'b0110000; // 3
            9'b0000010000: segment_record5 = 7'b0011001; // 4
            9'b0000100000: segment_record5 = 7'b0010010; // 5
            9'b0001000000: segment_record5 = 7'b0000010; // 6
            9'b0010000000: segment_record5 = 7'b1111000; // 7
            9'b0100000000: segment_record5 = 7'b0000000; // 8
            10'b1000000000:segment_record5 = 7'b0010000; // 9
            default: segment_record5 = 7'b0111111; // Blank
                endcase
 end

reg [3:0] tens, ones;//倒计时的十位和个位

always @(*) begin//用于改变十位和个位的值同时改变AN6和AN7的值，使倒计时显示
    tens = countdown / 10;
    ones = countdown % 10;

    case(ones)
        4'd0: segment_record6 = 7'b1000000; // 0
        4'd1: segment_record6 = 7'b1111001; // 1
        4'd2: segment_record6 = 7'b0100100; // 2
        4'd3: segment_record6 = 7'b0110000; // 3
        4'd4: segment_record6 = 7'b0011001; // 4
        4'd5: segment_record6 = 7'b0010010; // 5
        4'd6: segment_record6 = 7'b0000010; // 6
        4'd7: segment_record6 = 7'b1111000; // 7
        4'd8: segment_record6 = 7'b0000000; // 8
        4'd9: segment_record6 = 7'b0010000; // 9
        default: segment_record6 = 7'b1111111; // Blank
    endcase                     
                                
    case(tens)                  
        4'd0: segment_record7 = 7'b1000000; // 0 
        4'd1: segment_record7 = 7'b1111001; // 1 
        4'd2: segment_record7 = 7'b0100100; // 2 
        4'd3: segment_record7 = 7'b0110000; // 3 
        4'd4: segment_record7 = 7'b0011001; // 4 
        4'd5: segment_record7 = 7'b0010010; // 5 
        4'd6: segment_record7 = 7'b0000010; // 6 
        4'd7: segment_record7 = 7'b1111000; // 7 
        4'd8: segment_record7 = 7'b0000000; // 8 
        4'd9: segment_record7 = 7'b0010000; // 9 
        default: segment_record7 = 7'b1111111; // Blank
    endcase
end



    always@(posedge clk_400hz)begin//循环扫描数码管利用视觉暂留使其看上去常亮
       if (scan == 3'd7)begin
        scan <= 0;
        end
    else begin
        scan <= scan + 1;
        end

        o_AN=8'b11111111^(8'b00000001<<scan);//根据scan的数值对o_AN进行移位
        case(o_AN)
        8'b11111110: o_segment_display=segment_record0;
        8'b11111101: o_segment_display=segment_record1;
        8'b11111011: o_segment_display=segment_record2;
        8'b11110111: o_segment_display=segment_record3;
        8'b11101111: o_segment_display=segment_record4;
        8'b11011111: o_segment_display=segment_record5;
        8'b10111111: o_segment_display=segment_record6; // AN6 → 倒计时个位
        8'b01111111: o_segment_display=segment_record7; // AN7 → 倒计时十位
        endcase
    end

endmodule