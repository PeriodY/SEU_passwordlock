`timescale 1ns / 1ps

module password_lock(
    input [9:0]pwds,
    input backspace,
    input reset,
    input clk_100Mhz,
    input confirm,//ȷ�ϼ�
    input operate,
    input administrate,//����Ա����
    input relieve,//����������������
    output reg[6:0]segment_display,
    output reg[7:0]AN,
    output reg[14:0]led,
    output reg alarm,//��������˿��ź�
    output reg warning//������ڼ򵥾����ź�
    );
    parameter size=4;
    reg [size-1:0]stable=1;//����״̬����������״̬���˸�״̬������Ա״̬������״̬��������ڼ򵥾���״̬
    reg [9:0]key0=10'b0000000010,key1=10'b0000000100,key2=10'b0000001000,key3=10'b0000010000,key4=10'b0000100000,key5=10'b0001000000,pwds0,pwds1,pwds2,pwds3,pwds4,pwds5;
    //��ʼ��������Ϊ123456
    reg confirm_record;
    reg [3:0]stable_record;
    reg [1:0]times=0;
    reg relieve_record;
    reg [15:0]counter;
    reg [8:0]counter0;
    reg [5:0]countdown;
    reg [3:0] tens, ones;
//��Ƶ
integer clk_cnt;//��100MHz�ֳ�400Hz
reg clk_400hz;
   always @(posedge clk_100Mhz)begin
        if(clk_cnt==30'd125000)
        begin clk_cnt <= 1'b0; clk_400hz <= ~clk_400hz;end
        else
        clk_cnt <= clk_cnt + 1'b1;
   end

//�û���������״̬��Ӧ�ӿڱ�����ģ��ʵ����
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

//����Ա״̬��ģ��ʵ����
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
  if (stable != stable_record) begin//���״̬�ı�
        case (stable)
            4'b0001: countdown <= 15;   // ��������״̬
            4'b0010: countdown <= 30;   // ����״̬
            default: countdown <= 0;
        endcase
    end else begin
        // --- ����ʱ�߼���ÿ���һ ---
        if (counter % 400 == 0 && countdown > 0) begin
            countdown <= countdown - 1;
        end
    end
 case(stable)

    4'b0001:begin              //������������״̬
      
      AN<=AN_connect0;
      segment_display<=segment_display_connect0;
      pwds0<=pwds0_connect0;pwds1<=pwds1_connect0;pwds2<=pwds2_connect0;pwds3<=pwds3_connect0;pwds4<=pwds4_connect0;pwds5<=pwds5_connect0;
      if(confirm&&!confirm_record)begin
        if((pwds0==key0)&&(pwds1==key1)&&(pwds2==key2)&&(pwds3==key3)&&(pwds4==key4)&&(pwds5==key5))begin//ȷ�ϼ����º����������ȷ
          stable<=4'b0010;times<=0;
        end  else begin
           if(times==2)begin//�����������
            stable<=4'b0100;times<=0;
           end else //����С���������������
           times<=times+1;
           alarm<=1;
           countdown<=15;
        end
      end
      if(alarm==1)begin//ǰ���α����źţ������Լ1s
        counter0<=counter0+1;
        if(counter0==400)begin
          alarm<=0;counter0<=0;
        end
      end
      if(administrate)begin stable=4'b1000;end
      
      if ((pwds0!=pwds0_connect0)||(pwds1!=pwds1_connect0)||(pwds2!=pwds2_connect0)||(pwds3!=pwds3_connect0)||(pwds4!=pwds4_connect0)||(pwds5!=pwds5_connect0)) begin
        counter <= 0;               // ����в����źţ�����������
        countdown<=15;
        end else if (counter == 6000) begin
          stable_record<=0; 
          counter<=0;         // 15���޲���,�ع�������������״̬
          
        end else begin
          counter <= counter + 1;   // ����������
          
        end
    end


   
    4'b0010:begin                   //����״̬
   
   AN<=AN_connect0;
   segment_display<=segment_display_connect0;
   led<=15'b111111111111111;
   if (operate) begin
        counter <= 0;               // ����в����źţ�����������
        countdown<=30;
        end else if (counter == 12300) begin
          stable<=4'b0001; 
          counter<=0;
          led<=0;          // 30���޲���,�ع�������������״̬
        end else begin
          counter <= counter + 1;   // ����������
          
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


    4'b0100:begin              //����״̬
    alarm<=1;
    segment_display<=0;
    AN<=0;
    relieve_record<=relieve;
    if(relieve&&!relieve_record)begin//���½���źź�ת����������״̬
      stable<=4'b0001;
      alarm<=0;
    end 
    end
 
 4'b0101:begin              //������ڼ�״̬״̬
    warning<=1;
    segment_display<=0;
    AN<=0;
    relieve_record<=relieve;
    if(relieve&&!relieve_record)begin
      stable<=4'b0001;
      warning<=0;
    end 
    end

    4'b1000:begin               //����Աģʽ״̬
      AN<=AN_connect1;
      segment_display<=segment_display_connect1;
      pwds0<=pwds0_connect1;pwds1<=pwds1_connect1;pwds2<=pwds2_connect1;pwds3<=pwds3_connect1;pwds4<=pwds4_connect1;pwds5<=pwds5_connect1;
     
      if(!administrate)begin 
        if ((pwds0 == pwds1) && (pwds1 == pwds2) &&
            (pwds2 == pwds3) && (pwds3 == pwds4) &&
            (pwds4 == pwds5)) begin
            stable <= 4'b0101;   // ���������ظ����ڼ򵥴��󱨾�״̬
        end
        else begin
        stable=4'b0001;//��������
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