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
    output reg shiftL, en11,en34us,clr11,clr34us, word_ready
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
            stateNxt = IDLE;
        else
            stateNxt = SAVE_BIT;
        WORD_READY:
        if(hit34us) 
            stateNxt = IDLE;
        else 
            stateNxt = SAVE_BIT;
        SAVE_BIT:
        stateNxt = WAIT0;
        WAIT0:
        if(clock)
            stateNxt = WAIT1;
        else
            stateNxt = WAIT0;
        WAIT1:
        if (hit34us)
            stateNxt = WORD_READY;
        else if(~clock && hit11)
            stateNxt = WORD_READY;
        else if(~clock && ~hit11)
            stateNxt = SAVE_BIT;
        else stateNxt = WAIT1;
        default: stateNxt = IDLE;

    endcase

    always @(state)
    case(state)
        IDLE:{shiftL,en11,clr11,clr34us, word_ready}=5'b00110;
        WORD_READY:{shiftL,en11,clr11,clr34us, word_ready}=5'b00101;
        SAVE_BIT:{shiftL,en11,clr11,clr34us, word_ready}=5'b11010;
        WAIT0:{shiftL,en11,clr11,clr34us, word_ready}=5'b00000;
        WAIT1:{shiftL,en11,clr11,clr34us, word_ready}=5'b00000;
        default:{shiftL,en11,clr11,clr34us, word_ready}=5'b00010;
    endcase

endmodule

module shReg(input ck, input bit,shl, /*bit è il dato ricevuto in ingresso dal mouse*/ output reg [10:0] data);
    reg [10:0] dataNxt;

    always @(posedge ck)
    data <= dataNxt;

    always @(data,bit,shl)
    if(shl)
        dataNxt = {data[9:0],bit};
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
    else hit11 = 0;
endmodule

module cnt34us(
    input ck,clr34us,
    output reg hit34us
);
    parameter STOP = 3400;
    reg [11:0] cnt,cntNxt;

    always @(posedge ck,posedge clr34us)
    if(clr34us)
        cnt <= 0;
    else
        cnt <= cntNxt;

    always @(cnt)
    if(cnt < STOP) 
        cntNxt = cnt + 1;
    else
        cntNxt = cnt;

    always @(cnt)
    if(cnt == STOP)
        hit34us = 1;
    else
        hit34us = 0;

endmodule

module USBReader(input ck, reset, dataIn, clock, output word_ready, output[10:0] data);

    wire hit11,hit34us,shiftL, en11,en34us,clr11,clr34us;
    wire [10:0] data;
    
    controllo dut0(ck,reset,clock,hit11,hit34us,shiftL, en11,en34us,clr11,clr34us, word_ready);
    shReg dut1(ck,dataIn,shiftL,data);
    cnt11 dut2(ck,clr11,en11,hit11);
    cnt34us dut3(ck,clr34us,hit34us);

endmodule

//---------------------------------------------------------------------------------------------------------
//USB sender: (da debuggare)

module writerSM(input ck, reset, send, inout data, clock, input hit10, hit01ms, input dataout, output reg en10, clr10, clr01ms, shift, busy);

parameter[3:0] IDLE = 0, CLOCK0 = 1, CLOCK1 = 2, WAIT1 = 3, WAIT0 = 4, HIT10EN = 5, SHIFTDATA = 6, WAITFINAL1 = 7, WAITFINAL0 = 8;
reg[3:0] currentState, nextState;

reg reading_clock, reading_data;
reg assignedClock;

assign data = reading_data ? 1'bz : dataout;
assign clock = reading_clock ? 1'bz : assignedClock;

always @(posedge ck, posedge reset)
if(reset) currentState <= IDLE;
else currentState <= nextState;

always @(*)
case(currentState)
IDLE:
if(send) nextState = CLOCK0;
else nextState = IDLE;
CLOCK0:
if(hit01ms) nextState = CLOCK1;
else nextState = CLOCK0;
CLOCK1:
nextState = WAIT1;
WAIT1:
if(clock) nextState = WAIT1;
else nextState = WAIT0;
WAIT0:
if(~clock) nextState = WAIT0;
else nextState = HIT10EN;
HIT10EN:
nextState = SHIFTDATA;
SHIFTDATA:
if(~hit10) nextState = WAIT1;
else nextState = WAITFINAL1;
WAITFINAL1:
if(clock) nextState = WAITFINAL1;
else nextState = WAITFINAL0;
WAITFINAL0:
if(~clock) nextState = WAITFINAL0;
else nextState = IDLE;
default:nextState=IDLE;
endcase

always @(*)
case(currentState)
IDLE: {reading_clock, reading_data, assignedClock, en10, clr10, clr01ms, shift} = 7'b11x0110;
CLOCK0: {reading_clock, reading_data, assignedClock, en10, clr10, clr01ms, shift} = 7'b0000100;
CLOCK1:{reading_clock, reading_data, assignedClock, en10, clr10, clr01ms, shift} = 7'b0010110;
WAIT1:{reading_clock, reading_data, assignedClock, en10, clr10, clr01ms, shift} = 7'b10x0010;
WAIT0:{reading_clock, reading_data, assignedClock, en10, clr10, clr01ms, shift} = 7'b10x0010;
HIT10EN:{reading_clock, reading_data, assignedClock, en10, clr10, clr01ms, shift} = 7'b10x1010;
SHIFTDATA: {reading_clock, reading_data, assignedClock, en10, clr10, clr01ms, shift} = 7'b10x0011;
WAITFINAL1:{reading_clock, reading_data, assignedClock, en10, clr10, clr01ms, shift} = 7'b11x0110;
WAITFINAL0: {reading_clock, reading_data, assignedClock, en10, clr10, clr01ms, shift} = 7'b11x0110;
default:{reading_clock, reading_data, assignedClock, en10, clr10, clr01ms, shift} = 7'b11x0110;
endcase

//questo l'ho aggiunto dopo, funziona uguale
always @(*)
if(currentState == IDLE) busy = 0;
else busy = 1;

endmodule

module counter10(input ck, reset, en, output reg hit);
reg[3:0] count, countNext;

always @(posedge ck, posedge reset)
if(reset) count = 0;
else count = countNext;

always @(*)
if(en && count < 10) countNext = count + 1;
else countNext = count;

always @(*)
if(count == 10) hit = 1;
else hit = 0;

endmodule

module counter01ms(input ck, reset, output reg hit);
reg[15:0]count;

always @(posedge ck, posedge reset)
if(reset) count <= 0;
else if(count < 10000) count <= count + 1;

endmodule

module serializer(input ck, shift, save, input[9:0] dataToSend, output dataout);
reg[9:0] savedData;

assign dataout = savedData[9];

always @(posedge ck)
if(save) savedData = dataToSend;
else if(shift) savedData = {savedData[8:0],1'bx};

endmodule


module USBsender(input ck, reset, send, input[9:0] dataToSend, inout data, clock, output busy);
wire hit10, hit01ms, en10, shift, clr10, clr01ms, currentdata;

writerSM x0(ck, reset, data, clock, hit10, hit01ms, currentdata, en10, clr10, clr01ms, shift, busy);
counter10 x1(ck, reset || clr10, en10, hit10);
counter01ms x2(ck, reset || clr01ms, hit01ms);
serializer x3(ck, shift, send && ~busy, dataToSend, currentdata); //salva quando siamo in idle e viene inviato un nuovo segnale di send

endmodule
