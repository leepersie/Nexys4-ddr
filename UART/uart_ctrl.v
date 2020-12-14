`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/06 15:03:11
// Design Name: 
// Module Name: uart_ctrl
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


module uart_ctrl(
    input clk,
    input [7:0] datain,
    input rdsig,
    output [7:0] dataout,
    output wrsig
    );
    
reg sel, wrsig_r, valid;
reg [2:0] step;
reg [7:0] store [19:0];
reg [7:0] data_r, k, cnt;
reg [17:0] valid_cnt;

assign dataout = (sel)? data_r : datain;
assign wrsig = (sel)? wrsig_r : rdsig;

always @ (*) begin
    store[0]<=72;                           //�洢�ַ�H
    store[1]<=101;                          //�洢�ַ�e
    store[2]<=108;                          //�洢�ַ�l
    store[3]<=108;                          //�洢�ַ�l
    store[4]<=111;                          //�洢�ַ�o
    store[5]<=32;                           //�洢�ַ��ո�
    store[6]<=65;                           //�洢�ַ�A
    store[7]<=76;                           //�洢�ַ�L
    store[8]<=73;                           //�洢�ַ�I
    store[9]<=78;                           //�洢�ַ�N
    store[10]<=88;                          //�洢�ַ�X
    store[11]<=32;                          //�洢�ַ��ո�
    store[12]<=65;                          //�洢�ַ�A
    store[13]<=88;                          //�洢�ַ�X
    store[14]<=53;                          //�洢�ַ�5
    store[15]<=49;                          //�洢�ַ�1
    store[16]<=54;                          //�洢�ַ�6
    store[17]<=32;                          //�洢�ַ��ո�
    store[18]<=10;                          //���з�
    store[19]<=13;                          //�س���
end

always @ (posedge clk) begin
    if(rdsig) begin
        valid_cnt <= 18'd0;
        valid <= 1'b0;
    end
    else if(valid_cnt == 18'h3ffff) begin
        valid_cnt <= 18'd0;
        valid <= 1'b1;
    end
    else begin
        valid_cnt <= valid_cnt + 1'b1;
        valid <= 1'b0;
    end
end

always @ (posedge clk) begin
    if(rdsig) begin
        k <= 8'd0;
        sel <= 1'b0;
        cnt <= 8'd0;
        step <= 3'b000;
    end
    else begin
        case(step)
            3'b000: begin
                if(valid) begin
                    step <= 3'b001;
                    sel <= 1'b1;
                    k <= 8'd0;
                end
            end
            3'b001: begin
                if(k == 18) begin
                    if(cnt == 8'd0) begin
                        cnt <= cnt + 1'b1;
                        data_r <= store[k];
                        wrsig_r <= 1'b1;
                    end
                    else if(cnt == 8'd254) begin
                        cnt <= 8'd0;
                        wrsig_r <= 1'b0;
                        k <= 8'd0;
                        step <= 3'b010;
                    end
                    else begin
                        cnt <= cnt + 1'b1;
                        wrsig_r <= 1'b0;
                    end
                end
                else begin
                    if(cnt == 8'd0) begin
                        cnt <= cnt + 1'b1;
                        data_r <= store[k];
                        wrsig_r <= 1'b1;
                    end
                    else if(cnt == 8'd254) begin
                        cnt <= 8'd0;
                        wrsig_r <= 1'b0;
                        k <=  k + 8'd1;
                    end
                    else begin
                        cnt <= cnt + 1'b1;
                        wrsig_r <= 1'b0;
                    end
                end
            end
            3'b010: begin
                sel <= 1'b0;
                step <= 3'b000;
            end
            default : begin
                step <= 3'b000;
            end
        endcase
    end
end
endmodule
