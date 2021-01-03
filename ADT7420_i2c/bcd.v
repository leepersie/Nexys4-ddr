`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/03 10:07:34
// Design Name: 
// Module Name: bcd
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


module bcd(
    input clk,
    input rst_n,
    input [31:0] cnt,
    input [7:0] bin,
    output reg [3:0] one,ten,
    output reg [1:0] hun
    );

reg [3:0] count;
reg [17:0]shift_reg;
// ��������
always @ ( posedge clk or negedge rst_n ) begin
    if( !rst_n )
        count<=0;
    else begin
        if(cnt <= 31'd1_000_000) begin   //�������ڸ�ֵֹͣת����ʹ�������ֵ�����ȶ��ȶ�
            if(count == 9)
                count<=0;
            else
                count <= count + 1'b1;
        end
    end
end

//������ת��Ϊʮ���� /
always @ (posedge clk or negedge rst_n ) begin
    if (!rst_n)
        shift_reg=0;
    else if (count==0)
        shift_reg={10'b0000000000,bin};
    else if ( count<=8) begin                //ʵ��8����λ����
        if(shift_reg[11:8]>=5) begin         //�жϸ�λ�Ƿ�>5���������+3  
            if(shift_reg[15:12]>=5) begin    //�ж�ʮλ�Ƿ�>5���������+3  
                shift_reg[15:12]=shift_reg[15:12]+2'b11;   
                shift_reg[11:8]=shift_reg[11:8]+2'b11;
                shift_reg=shift_reg<<1;      //�Ը�λ��ʮλ������������������
            end
            else begin
                shift_reg[15:12]=shift_reg[15:12];
                shift_reg[11:8]=shift_reg[11:8]+2'b11;
                shift_reg=shift_reg<<1;
            end
        end              
        else begin
            if(shift_reg[15:12]>=5) begin
                shift_reg[15:12]=shift_reg[15:12]+2'b11;
                shift_reg[11:8]=shift_reg[11:8];
                shift_reg=shift_reg<<1;
            end
            else begin
                shift_reg[15:12]=shift_reg[15:12];
                shift_reg[11:8]=shift_reg[11:8];
                shift_reg=shift_reg<<1;
            end
        end        
    end
end

always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        one<=0;
        ten<=0;
        hun<=0; 
    end
    else if (count==9) begin //��ʱ8����λȫ����ɣ�����Ӧ��ֵ�ֱ𸳸���,ʮ,��λ
        one<=shift_reg[11:8];
        ten<=shift_reg[15:12];
        hun<=shift_reg[17:16]; 
    end
end
endmodule
