`timescale 1ns / 1ps

module password_lock(
    input [9:0]pwds,
    input backspace,
    input reset,
    input clk_100Mhz,
    input confirm,//确认键
    input operate,
    input administrate,//管理员按键
    input relieve,//报警后解除报警按键
    output reg[6:0]segment_display,
    output reg[7:0]AN,
    output reg[14:0]led,
    output reg alarm,//报警输出端口信号
    output reg warning//密码过于简单警告信号
    );
    parameter size=4;
    reg [size-1:0]stable=1;//五种状态，输入密码状态，退格状态，管理员状态，开锁状态，密码过于简单警告状态
    reg [9:0]key0=10'b0000000010,key1=10'b0000000100,key2=10'b0000001000,key3=10'b0000010000,key4=10'b0000100000,key5=10'b0001000000,pwds0,pwds1,pwds2,pwds3,pwds4,pwds5;
    //初始密码设置为123456
    reg confirm_record;
    reg [3:0]stable_record;
    reg [1:0]times=0;
    reg relieve_record;
    reg [15:0]counter;
    reg [8:0]counter0;
    reg [5:0]countdown;
    reg [3:0] tens, ones;
//分频
integer clk_cnt;//将100MHz分成400Hz
reg clk_400hz;
   always @(posedge clk_100Mhz)begin
        if(clk_cnt==30'd125000)
        begin clk_cnt <= 1'b0; clk_400hz <= ~clk_400hz;end
        else
        clk_cnt <= clk_cnt + 1'b1;
   end

//用户输入密码状态对应接口变量，模块实例化
wire [6:0]segment_display_connect0;
wire [7:0]AN_connect0;
wire [9:0]pwds0_connect0,pwds1_connect0,pwds2_connect0,pwds3_connect0,pwds4_connect0,pwds5_connect0;
digital_segment ins0(
.pwds(pwds),
.pwd0(0),.pwd1(0),.pwd2(0),.pwd3(0),.pwd4(0),.pwd5(0),
.backspace(backspace),
.reset(reset),
.countdown(countdown),
.reset_stable((stable==4'b0001)&&(stable_record!=4'b0001)),
.clk_400hz(clk_400hz),
.o_segment_display(segment_display_connect0),
.o_AN(AN_connect0),
.o_pwds0(pwds0_connect0),.o_pwds1(pwds1_connect0),.o_pwds2(pwds2_connect0),.o_pwds3(pwds3_connect0),.o_pwds4(pwds4_connect0),.o_pwds5(pwds5_connect0));

//管理员状态，模块实例化
wire [6:0]segment_display_connect1;
wire [7:0]AN_connect1;
wire [9:0]pwds0_connect1,pwds1_connect1,pwds2_connect1,pwds3_connect1,pwds4_connect1,pwds5_connect1;
digital_segment ins1(
.pwds(pwds),
.pwd0(0),.pwd1(0),.pwd2(0),.pwd3(0),.pwd4(0),.pwd5(0),
.backspace(backspace),
.reset(reset),
.countdown(6'b0),
.reset_stable((stable==4'b1000)&&(stable_record!=4'b1000)),
.clk_400hz(clk_400hz),
.o_segment_display(segment_display_connect1),
.o_AN(AN_connect1),
.o_pwds0(pwds0_connect1),.o_pwds1(pwds1_connect1),.o_pwds2(pwds2_connect1),.o_pwds3(pwds3_connect1),.o_pwds4(pwds4_connect1),.o_pwds5(pwds5_connect1));



always@(posedge clk_400hz)begin
    confirm_record<=confirm;
    stable_record<=stable;
  if (stable != stable_record) begin//检测状态改变
        case (stable)
            4'b0001: countdown <= 15;   // 输入密码状态
            4'b0010: countdown <= 30;   // 开锁状态
            default: countdown <= 0;
        endcase
    end else begin
        // --- 倒计时逻辑：每秒减一 ---
        if (counter % 400 == 0 && countdown > 0) begin
            countdown <= countdown - 1;
        end
    end
 case(stable)

    4'b0001:begin              //正在输入密码状态
      
      AN<=AN_connect0;
      segment_display<=segment_display_connect0;
      pwds0<=pwds0_connect0;pwds1<=pwds1_connect0;pwds2<=pwds2_connect0;pwds3<=pwds3_connect0;pwds4<=pwds4_connect0;pwds5<=pwds5_connect0;
      if(confirm&&!confirm_record)begin
        if((pwds0==key0)&&(pwds1==key1)&&(pwds2==key2)&&(pwds3==key3)&&(pwds4==key4)&&(pwds5==key5))begin//确认键按下后如果密码正确
          stable<=4'b0010;times<=0;
        end  else begin
           if(times==2)begin//如果报警三次
            stable<=4'b0100;times<=0;
           end else //报警小于三次且密码错误
           times<=times+1;
           alarm<=1;
           countdown<=15;
        end
      end
      if(alarm==1)begin//前两次报警信号，红灯亮约1s
        counter0<=counter0+1;
        if(counter0==400)begin
          alarm<=0;counter0<=0;
        end
      end
      if(administrate)begin stable=4'b1000;end
      
      if ((pwds0!=pwds0_connect0)||(pwds1!=pwds1_connect0)||(pwds2!=pwds2_connect0)||(pwds3!=pwds3_connect0)||(pwds4!=pwds4_connect0)||(pwds5!=pwds5_connect0)) begin
        counter <= 0;               // 如果有操作信号，计数器清零
        countdown<=15;
        end else if (counter == 6000) begin
          stable_record<=0; 
          counter<=0;         // 15秒无操作,回归正在输入密码状态
          
        end else begin
          counter <= counter + 1;   // 计数器递增
          
        end
    end


   
    4'b0010:begin                   //开锁状态
   
   AN<=AN_connect0;
   segment_display<=segment_display_connect0;
   led<=15'b111111111111111;
   if (operate) begin
        counter <= 0;               // 如果有操作信号，计数器清零
        countdown<=30;
        end else if (counter == 12300) begin
          stable<=4'b0001; 
          counter<=0;
          led<=0;          // 30秒无操作,回归正在输入密码状态
        end else begin
          counter <= counter + 1;   // 计数器递增
          
        end
    if(administrate)begin 
        stable=4'b1000;
        led<=0;
        counter<=0;
        end
    if(confirm&&!confirm_record)begin
      stable<=4'b0001;
      counter<=0;
      led<=0;    

    end
    end


    4'b0100:begin              //报警状态
    alarm<=1;
    segment_display<=0;
    AN<=0;
    relieve_record<=relieve;
    if(relieve&&!relieve_record)begin//按下解除信号后转回输入密码状态
      stable<=4'b0001;
      alarm<=0;
    end 
    end
 
 4'b0101:begin              //密码过于简单状态状态
    warning<=1;
    segment_display<=0;
    AN<=0;
    relieve_record<=relieve;
    if(relieve&&!relieve_record)begin
      stable<=4'b0001;
      warning<=0;
    end 
    end

    4'b1000:begin               //管理员模式状态
      AN<=AN_connect1;
      segment_display<=segment_display_connect1;
      pwds0<=pwds0_connect1;pwds1<=pwds1_connect1;pwds2<=pwds2_connect1;pwds3<=pwds3_connect1;pwds4<=pwds4_connect1;pwds5<=pwds5_connect1;
     
      if(!administrate)begin 
        if ((pwds0 == pwds1) && (pwds1 == pwds2) &&
            (pwds2 == pwds3) && (pwds3 == pwds4) &&
            (pwds4 == pwds5)) begin
            stable <= 4'b0101;   // 进入密码重复过于简单错误报警状态
        end
        else begin
        stable=4'b0001;//设置密码
        key0<=pwds0;
        key1<=pwds1;
        key2<=pwds2;
        key3<=pwds3;
        key4<=pwds4;
        key5<=pwds5;
        end
      end
    end
    endcase
end



endmodule