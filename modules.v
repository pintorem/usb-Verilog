`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Samuele Capacci & Marco Pintore
// 
// Create Date: 04.02.2022 17:17:19
// Design Name: 
// Module Name: modules
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


module controllo(
input ck,reset,
input clock,hit11,hit34us, //clock sarebbe il ps2_clk
output reg shiftL, en11,en34us,clr11,clr34us
);    
    
    reg [2:0] state,stateNxt;
    parameter [2:0] IDLE=0,WORD_READY=1,SAVE_BIT=2,WAIT0=3,WAIT1=4;
    
    always @(posedge ck, posedge reset)
        if(reset) state<=IDLE;
        else state<=stateNxt;
    
    always @(state,clock, hit11,hit34us)
        case(state)
            IDLE:
                if(clock) 
                    stateNxt = WORD_READY;
                else 
                    stateNxt = IDLE;
            WORD_READY:
                stateNxt = SAVE_BIT;
            SAVE_BIT:
                stateNxt = WAIT0;        
            WAIT0: 
                if(clock)
                    stateNxt = WAIT1;
                else 
                    stateNxt = WAIT0;
            WAIT1:
                if(clock && hit34us)
                    stateNxt = WAIT1;
                else 
                begin
                    if (clock==0 && hit11)
                        stateNxt = WORD_READY;
                    if (clock==0 && ~hit11)
                        stateNxt = SAVE_BIT;
                    else 
                    stateNxt = WAIT1;
                end
                
           
            default: stateNxt = IDLE;
        
        endcase
        
    always @(state)
        case(state)
            IDLE:{shiftL,en11,clr11,clr34us}=4'b0001;
            WORD_READY:{shiftL,en11,clr11,clr34us}=4'b0010;
            SAVE_BIT:{shiftL,en11,clr11,clr34us}=4'b1100;
            WAIT0:{shiftL,en11,clr11,clr34us}=4'b0000;
            WAIT1:{shiftL,en11,clr11,clr34us}=4'b0000;
           default:{shiftL,en11,clr11,clr34us}=4'b0001;
           endcase
        
endmodule

module shReg( 
input ck,
input bit,shl, //bit è il dato ricevuto in ingresso dal mouse
output reg [31:0] data
);

    reg [31:0] dataNxt;
                          
    always @(posedge ck)
        data <= dataNxt;

    always @(data,bit,shl)
        if(shl) 
            dataNxt = {data[30:0],bit};
        else 
            dataNxt = data;
        
endmodule

module cnt11(
input ck,clr11,
input en11,
output reg hit11
);

    reg [3:0] cnt,cntNxt;
    
    always @(posedge ck,posedge clr11)
        if(clr11)
            cnt <= 0;
        else cnt <= cntNxt;
    always @(cnt,en11)
        if(en11) 
            cntNxt = cnt+1;
        else cntNxt = cnt;
    always @(cnt)
        if(cnt == 11)
            hit11 = 1;
endmodule

module cnt34us(
input ck,clr34us,
output reg hit34us
);
    parameter STOP = 20;
    reg [11:0] cnt,cntNxt;
    
    always @(posedge ck,posedge clr34us)
        if(clr34us)
            cnt <= 0;
        else 
            cnt <= cntNxt;
        
    always @(cnt) 
        if(cnt < STOP) //TODO METTERE 3400 
            cntNxt = cnt + 1; 
        else 
            cntNxt = 0;
 
    always @(cnt) 
        if(cnt == STOP) 
            hit34us = 1; 
        else 
            hit34us = 0; 

endmodule
