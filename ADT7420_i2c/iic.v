`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/30 22:38:21
// Design Name: 
// Module Name: iic
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


module iic(
    input CLK,
    input RSTn,
    input [2:0] Start_Sig,             //read or write command
    input [7:0] Addr_Sig,              //words address
    input [7:0] WrData,                //write data
    output reg [15:0] RdData,          //read data
    output reg Done_Sig,               //read/write finish

    output reg SCL,
    inout SDA
    );

parameter F200K = 9'd500;             //200Khz��ʱ�ӷ�Ƶϵ��

reg [7:0]i;
reg [4:0]Go;
reg [9:0]C1;
reg rSDA;
reg isAck;
reg isOut;    
reg [7:0] data_r;
assign SDA = isOut ? rSDA : 1'bz;      //SDA�������ѡ��

//****************************************//
//*             I2C��д�������            *//
//****************************************//
always @ ( posedge CLK or negedge RSTn ) begin           //SCL
    if( !RSTn ) begin
        SCL <= 1'b1;
    end
    else begin
        if( Start_Sig[0] ) begin
            case(i)
                0: begin                                //start
                    if( C1 == 0 ) SCL <= 1'b1;
                    else if( C1 == 400 ) SCL <= 1'b0;   //SCL�ɸ߱��
                end
                4: begin                                //end
                    if( C1 == 0 ) SCL <= 1'b0;
                    else if( C1 == 100 ) SCL <= 1'b1;   //SCL�ɵͱ��
                end
                7,8,9,10,11,12,13,14,15: begin          //sclʱ��
                    if( C1 == 0 ) SCL <= 1'b0;
                    else if( C1 == 100 ) SCL <= 1'b1;
                    else if( C1 == 350 ) SCL <= 1'b0;
                end
                default: begin
                    SCL <= SCL;
                end
            endcase
        end
        else if( Start_Sig[1] ) begin
            case(i)
                0,3: begin
                    if( C1 == 0 ) SCL <= 1'b1;
                    else if( C1 == 400 ) SCL <= 1'b0;   //SCL�ɸ߱��
                end
                6: begin
                    if( C1 == 0 ) SCL <= 1'b0;
                    else if( C1 == 100 ) SCL <= 1'b1;   //SCL�ɵͱ��
                end
                9,10,11,12,13,14,15,16,17,19,20,21,22,23,24,25,26,27: begin
                    if( C1 == 0 ) SCL <= 1'b0;
                    else if( C1 == 100 ) SCL <= 1'b1;
                    else if( C1 == 350 ) SCL <= 1'b0;
                end
                default: begin
                    SCL <= SCL;
                end
            endcase
        end
        else if( Start_Sig[2] ) begin
            case(i)
                0,3: begin
                    if( C1 == 0 ) SCL <= 1'b1;
                    else if( C1 == 400 ) SCL <= 1'b0;   //SCL�ɸ߱��
                end
                6: begin
                    if( C1 == 0 ) SCL <= 1'b0;
                    else if( C1 == 100 ) SCL <= 1'b1;   //SCL�ɵͱ��
                end
                9,10,11,12,13,14,15,16,17,19,20,21,22,23,24,25,26,27,
                28,29,30,31,32,33,34,35,36: begin
                    if( C1 == 0 ) SCL <= 1'b0;
                    else if( C1 == 100 ) SCL <= 1'b1;
                    else if( C1 == 350 ) SCL <= 1'b0;
                end
                default: begin
                    SCL <= SCL;
                end
            endcase
        end
    end
end

always @ ( posedge CLK or negedge RSTn ) begin     //C1����
    if( !RSTn ) begin
        C1 <= 9'd0;
    end
    else begin
        if( Start_Sig[0] ) begin
            case (i)
                0,4,7,8,9,10,11,12,13,14,15: begin
                    if( C1 == F200K -1) begin C1 <= 9'd0; end
                    else C1 <= C1 + 1'b1;
                end
                default: C1 <= 9'd0;
            endcase
        end
        else if( Start_Sig[1] ) begin
            case (i)
                0,3,6,9,10,11,12,13,14,15,16,17,19,20,21,22,23,24,25,26,27: begin
                    if( C1 == F200K -1) begin C1 <= 9'd0; end
                    else C1 <= C1 + 1'b1;
                end
                default: C1 <= 9'd0;
            endcase
        end
        else if( Start_Sig[2] ) begin
            case (i)
                0,3,6,9,10,11,12,13,14,15,16,17,19,20,21,22,23,24,25,26,27,
                28,29,30,31,32,33,34,35,36: begin
                    if( C1 == F200K -1) begin C1 <= 9'd0; end
                    else C1 <= C1 + 1'b1;
                end
                default: C1 <= 9'd0;
            endcase
        end
    end
end

always @ ( posedge CLK or negedge RSTn ) begin
    if( !RSTn ) begin
        i <= 8'd0;
        Go <= 5'd0;
        RdData <= 16'd0;
        data_r <= 8'd0;
        rSDA <= 1'b1;
        isAck <= 1'b1;
        Done_Sig <= 1'b0;
        isOut <= 1'b1;
    end
    else begin
        if( Start_Sig[0] ) begin                         //I2C ����д
            case( i )
                0: begin // iic Start
                    isOut <= 1'b1;                       //SDA�˿���������ж�
    
                    if( C1 == 0 ) rSDA <= 1'b1;
                    else if( C1 == 200 ) rSDA <= 1'b0;   //SDA���ɸ߱��
        
                    if( C1 == F200K -1) begin i <= i + 1'b1; end
                end
                1:                                       // Write Device Addr
                begin data_r <= {4'b1001, 3'b011, 1'b0}; i <= 5'd7; Go <= i + 1'b1; end
                2:                                       // Wirte Word Addr
                begin data_r <= Addr_Sig; i <= 5'd7; Go <= i + 1'b1; end
                3:                                       // Write Data
                begin data_r <= WrData; i <= 5'd7; Go <= i + 1'b1; end
                4: begin                                 //iic Stop
                    isOut <= 1'b1;
                    
                    if( C1 == 0 ) rSDA <= 1'b0;
                    else if( C1 == 300 ) rSDA <= 1'b1;   //SDA�ɵͱ��
        
                    if( C1 == F200K -1 ) begin i <= i + 1'b1; end
                end
                5: begin
                    Done_Sig <= 1'b1; i <= i + 1'b1; end //дI2C ����
                6:
                begin Done_Sig <= 1'b0; i <= 5'd0; end
                7,8,9,10,11,12,13,14:                    //����Device Addr/Word Addr/Write Data
                begin
                    isOut <= 1'b1;
                    rSDA <= data_r[14-i];                //��λ�ȷ���
    
                    if( C1 == F200K -1 ) begin i <= i + 1'b1; end
                end
                15:                                      // waiting for acknowledge
                begin
                    isOut <= 1'b0;                       //SDA�˿ڸ�Ϊ����
                    if( C1 == 200 ) isAck <= SDA;
    
                    if( C1 == F200K -1 ) begin i <= i + 1'b1; end
                end
                16: begin
                    if( isAck != 0 ) i <= 5'd0;
                    else i <= Go;
                end
            endcase
        end
        
        else if( Start_Sig[1] ) begin                    //I2C ���ݶ���8bit��
            case( i )
                0: begin //iic Start
                    isOut <= 1'b1;                       //SDA�˿����
                    
                    if( C1 == 0 ) rSDA <= 1'b1;
                    else if( C1 == 200 ) rSDA <= 1'b0;   //SDA���ɸ߱��
    
                    if( C1 == F200K -1 ) begin i <= i + 1'b1; end
                end
                1:                                       // Write Device Addr
                begin data_r <= {4'b1001, 3'b011, 1'b0}; i <= 5'd9; Go <= i + 1'b1; end
                2:                                       // Wirte Word Addr
                begin data_r <= Addr_Sig; i <= 5'd9; Go <= i + 1'b1; end
                3:                                       //iic Start again
                begin
                    isOut <= 1'b1;
    
                    if( C1 == 0 ) rSDA <= 1'b1;
                    else if( C1 == 300 ) rSDA <= 1'b0;   //SDA�ȱ��
    
                    if( C1 == F200K -1 ) begin i <= i + 1'b1; end
                end
                4:                                       // Write Device Addr ( Read )
                begin data_r <= {4'b1001, 3'b011, 1'b1}; i <= 5'd9; Go <= i + 1'b1; end
                5:                                       // Read Data
                begin  i <= 5'd19; Go <= i + 1'b1; end
                6: begin                                 //iic Stop
                    isOut <= 1'b1;
                
                    if( C1 == 0 ) rSDA <= 1'b0;
                    else if( C1 == 300 ) rSDA <= 1'b1;   //SDA����
    
                    if( C1 == F200K -1 ) begin i <= i + 1'b1; end
                end
                7:                                       //дI2C ����
                begin Done_Sig <= 1'b1; i <= i + 1'b1; end
                8:
                begin Done_Sig <= 1'b0; i <= 5'd0; end
                9,10,11,12,13,14,15,16:                  //����Device Addr(write)/Word Addr/Device Addr(read)
                begin
                    isOut <= 1'b1;
                    rSDA <= data_r[16-i];
                                  
                    if( C1 == F200K -1 ) begin i <= i + 1'b1; end
                end
                17:                                      // waiting for acknowledge
                begin
                    isOut <= 1'b0;                       //SDA�˿ڸ�Ϊ����
                    
                    if( C1 == 200 ) isAck <= SDA;
                                  
                    if( C1 == F200K -1 ) begin i <= i + 1'b1; end
                end
                18:
                    if( isAck != 0 ) i <= 5'd0;
                    else i <= Go;
                19,20,21,22,23,24,25,26:                 // Read data
                begin
                    isOut <= 1'b0;
                    if( C1 == 200 ) RdData[26-i] <= SDA;
                                  
                    if( C1 == F200K -1 ) begin i <= i + 1'b1; end
                end      
                27: begin                                // no acknowledge
                    isOut <= 1'b1;
                                  
                    if( C1 == F200K -1 ) begin i <= Go; end
                end
            endcase
        end
        
        else if( Start_Sig[2] ) begin                    //I2C ���ݶ���16bit��
            case( i )
                0: begin //iic Start
                    isOut <= 1;                          //SDA�˿����
                    
                    if( C1 == 0 ) rSDA <= 1'b1;
                    else if( C1 == 200 ) rSDA <= 1'b0;   //SDA���ɸ߱��
    
                    if( C1 == F200K -1 ) begin i <= i + 1'b1; end
                end
                1:                                       // Write Device Addr
                begin data_r <= {4'b1001, 3'b011, 1'b0}; i <= 5'd9; Go <= i + 1'b1; end
                2:                                       // Wirte Word Addr
                begin data_r <= Addr_Sig; i <= 5'd9; Go <= i + 1'b1; end
                3:                                       //iic Start again
                begin
                    isOut <= 1'b1;
    
                    if( C1 == 0 ) rSDA <= 1'b1;
                    else if( C1 == 300 ) rSDA <= 1'b0;   //SDA�ȱ��
    
                    if( C1 == F200K -1 ) begin i <= i + 1'b1; end
                end
                4:                                       // Write Device Addr ( Read )
                begin data_r <= {4'b1001, 3'b011, 1'b1}; i <= 5'd9; Go <= i + 1'b1; end
                5:                                       // Read Data
                begin  i <= 5'd19; Go <= i + 1'b1; end
                6: begin                                 //iic Stop
                    isOut <= 1'b1;
                
                    if( C1 == 0 ) rSDA <= 1'b0;
                    else if( C1 == 300 ) rSDA <= 1'b1;   //SDA����
    
                    if( C1 == F200K -1 ) begin i <= i + 1'b1; end
                end
                7:
                begin Done_Sig <= 1'b1; i <= i + 1'b1; end
                8:
                begin Done_Sig <= 1'b0; i <= 5'd0; end
                9,10,11,12,13,14,15,16:                  //����Device Addr(write)/Word Addr/Device Addr(read)
                begin
                    isOut <= 1'b1;
                    rSDA <= data_r[16-i];

                    if( C1 == F200K -1 ) begin i <= i + 1'b1; end
                end
                17:                                      // waiting for acknowledge
                begin
                    isOut <= 1'b0;                       //SDA�˿ڸ�Ϊ����
                    if( C1 == 200 ) isAck <= SDA;

                    if( C1 == F200K -1 ) begin i <= i + 1'b1; end
                end
                18:
                    if( isAck != 0 ) i <= 5'd0;
                    else i <= Go;
                19,20,21,22,23,24,25,26:                 // Read data(MSB)
                begin
                    isOut <= 1'b0;
                    if( C1 == 200 ) RdData[34-i] <= SDA;

                    if( C1 == F200K -1 ) begin i <= i + 1'b1; end
                end      
                27: begin
                    isOut <= 1'b1;
                    rSDA <= 1'b0;
                    
                    if( C1 == F200K -1 ) begin i <= i + 1'b1; end
                end
                28,29,30,31,32,33,34,35:                 // Read data(LSB)
                begin
                    isOut <= 1'b0;
                    if( C1 == 200 ) RdData[35-i] <= SDA;

                    if( C1 == F200K -1 ) begin i <= i + 1'b1; end
                end
                36: begin                                // no acknowledge
                    isOut <= 1'b1;

                    if( C1 == F200K -1 ) begin i <= Go; end
                end
            endcase
        end
    end
end
endmodule
