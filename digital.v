`timescale 1ns / 1ps

module digital_segment( 
input [9:0]pwds,
input [9:0]pwd0,pwd1,pwd2,pwd3,pwd4,pwd5,//��������
input backspace,//�˸�
input reset,
input reset_stable,//��λ
input clk_400hz,//��Ƶʱ��
input [5:0]countdown,//����ʱ
output reg[6:0]o_segment_display,//�������ʾ��7��
output reg[7:0]o_AN,//ѡ�������
output reg[9:0]o_pwds0,o_pwds1,o_pwds2,o_pwds3,o_pwds4,o_pwds5);

reg [6:0]segment_record0= 7'b0111111,segment_record1= 7'b0111111,segment_record2= 7'b0111111,segment_record3= 7'b0111111,segment_record4= 7'b0111111,segment_record5= 7'b0111111; 
reg [6:0]segment_record6=7'b0111111,segment_record7= 7'b0111111; //�ֱ����ڼ�¼��������ܵ�����
reg [3:0]pwds_place=0;                                                        //���ڶ�λ������Լ�pwds����
reg [9:0]pwds_prev=0;                                                         //���������ڵ�pwds�ȽϴӶ��������԰����ϵ���������
reg [9:0]pwds0=0,pwds1=0,pwds2=0,pwds3=0,pwds4=0,pwds5=0;                    //���ڼ�¼����pwds����
reg [2:0]scan;                                                             //����ѭ�����������
reg backspace_record;                                                       //�˸��                                                         
reg once=0;                                                              //���������ⲿ���ź�һ��



always@(*)begin
     o_pwds0=pwds0;
     o_pwds1=pwds1;
     o_pwds2=pwds2;
     o_pwds3=pwds3;
     o_pwds4=pwds4;  
     o_pwds5=pwds5;
end//������������ı�

   integer i;integer j;
   always @(posedge clk_400hz) begin
    if(!once)begin
     for(j=0;j<10;j=j+1)begin
        pwds0[j]=pwd0[j];pwds1[j]=pwd1[j];pwds2[j]=pwd2[j];pwds3[j]=pwd3[j];pwds4[j]=pwd4[j];pwds5[j]=pwd5[j];
         pwds_place<=pwds_place+pwd0[j]+pwd1[j]+pwd2[j]+pwd3[j]+pwd4[j]+pwd5[j];
     end
     once<=1;
    end//�������ֵ����������ı�����λ��ָ���ֵ

    //�˸�
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
        end//��������˸�����������㣬ָ����һλ

    //��λ
    if(reset||reset_stable)begin
        pwds_place<=0;
        pwds0=0;pwds1=0;pwds2=0;pwds3=0;pwds4=0;pwds5=0;
    end

   if(pwds_place==4'b0111)begin pwds_place<=4'b0110;end


    //������밴ť������ź�
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

    always@(pwds0,pwds1,pwds2,pwds3,pwds4,pwds5)begin//���������ֵ������Ҫչʾ������7��ֵ
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

reg [3:0] tens, ones;//����ʱ��ʮλ�͸�λ

always @(*) begin//���ڸı�ʮλ�͸�λ��ֵͬʱ�ı�AN6��AN7��ֵ��ʹ����ʱ��ʾ
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



    always@(posedge clk_400hz)begin//ѭ��ɨ������������Ӿ�����ʹ�俴��ȥ����
       if (scan == 3'd7)begin
        scan <= 0;
        end
    else begin
        scan <= scan + 1;
        end

        o_AN=8'b11111111^(8'b00000001<<scan);//����scan����ֵ��o_AN������λ
        case(o_AN)
        8'b11111110: o_segment_display=segment_record0;
        8'b11111101: o_segment_display=segment_record1;
        8'b11111011: o_segment_display=segment_record2;
        8'b11110111: o_segment_display=segment_record3;
        8'b11101111: o_segment_display=segment_record4;
        8'b11011111: o_segment_display=segment_record5;
        8'b10111111: o_segment_display=segment_record6; // AN6 �� ����ʱ��λ
        8'b01111111: o_segment_display=segment_record7; // AN7 �� ����ʱʮλ
        endcase
    end

endmodule