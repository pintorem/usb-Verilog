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
    input clock, data, hit11, hitlim, //clock sarebbe il ps2_clk
    output reg shiftL, en11,clr11,clrlim, word_ready,
    output[2:0] curr_state //DEBUG
);

    reg [2:0] state,stateNxt;
    parameter [2:0] IDLE = 0, DELAY = 5, SAVEBIT = 1, CLOCK0 = 2, CLOCK1 = 3, WORDREADY = 4;
    
    wire[2:0] status;
    assign status = {hitlim, hit11,clock};
    
    assign curr_state = state; //DEBUG
    
    always @(posedge ck, posedge reset)
    if(reset) state = IDLE;
    else state<=stateNxt;
    
    cntlim(ck, reset || clrdel, 130, hitdel);
    wire hitdel;
    reg clrdel;
    
always @(*)
case(state)
IDLE:
if(~clock && ~data) stateNxt = DELAY;
else stateNxt = IDLE;
SAVEBIT: stateNxt = CLOCK0;
CLOCK0:
if(clock) stateNxt = CLOCK1;
else stateNxt = CLOCK0;
CLOCK1:
if(hitlim) stateNxt = IDLE;
else if(hit11) stateNxt = WORDREADY;
else if(~clock) stateNxt = DELAY;
else stateNxt = CLOCK1;
WORDREADY:
stateNxt = IDLE;
DELAY:
if(hitdel) stateNxt = SAVEBIT;
else stateNxt = DELAY;
default: stateNxt = IDLE;
endcase

    always @(*)
    case(state)
        IDLE:{shiftL,en11,clr11,clrlim, word_ready, clrdel}=6'b001101;
        SAVEBIT:{shiftL,en11,clr11,clrlim, word_ready, clrdel}=6'b110101;
        CLOCK0:{shiftL,en11,clr11,clrlim, word_ready, clrdel}=6'b000101;
        CLOCK1:{shiftL,en11,clr11,clrlim, word_ready, clrdel}=6'b000001;
        WORDREADY:{shiftL,en11,clr11,clrlim, word_ready, clrdel}=6'b001111;
        DELAY:{shiftL,en11,clr11,clrlim, word_ready, clrdel} = 6'b000000;
    endcase

endmodule

module shReg(input ck, input bit,shl, output reg [10:0] data);
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

module cntlim(
    input ck,clrlim, input[11:0] STOP,
    output reg hitlim
);
    reg [11:0] cnt,cntNxt;

    always @(posedge ck,posedge clrlim)
    if(clrlim)
        cnt <= 0;
    else
        cnt <= cntNxt;

    always @(cnt)
    if(cnt < STOP) //
        cntNxt = cnt + 1;
    else
        cntNxt = cnt;

    always @(cnt)
    if(cnt == STOP)
        hitlim = 1;
    else
        hitlim = 0;

endmodule

module USBReader(input ck, reset, dataIn, clock, output word_ready, output[10:0] word, output[2:0] curr_state);
    wire hit11,hitlim,shiftL, en11, clr11, clrlim;
    
    controllo x0(ck,reset,clock, dataIn, hit11,hitlim,shiftL, en11,clr11,clrlim, word_ready, curr_state);
    shReg x1(ck,dataIn, shiftL, word);
    cnt11 x2(ck,clr11,en11,hit11);
    cntlim x3(ck,clrlim, 3700, hitlim);

endmodule

//---------------------------------------------------------------------------------------------------------
//USB writer


module writerSM(input ck, reset, send, inout data, clock, input hit10, hit01ms, input dataout, output reg en10, clr10, clr01ms, shift, busy, reading_clock, reading_data, output[3:0] state, output assignedClock);

parameter[3:0] IDLE = 0, CLOCK0 = 1, CLOCK1 = 2, WAIT1 = 3, WAIT0 = 4, HIT10EN = 5, SHIFTDATA = 6, WAITFINAL1 = 7, WAITFINAL0 = 8, RTS = 9, DELAY= 10;
reg[3:0] currentState, nextState;

reg assignedClock;

    assign clock = readingClock ? 1'bz : assignedClock;
    assign data = readingData ? 1'bz : dataout;

assign state = currentState;

reg clrrts, clrdelay;
wire hitrts, hitdelay;
cntlim x0(ck, clrrts, 20, hitrts);
cntlim x1(ck, clrdelay, 300, hitdelay);

always @(posedge ck, posedge reset)
if(reset) currentState <= IDLE;
else currentState <= nextState;

always @(send, hit01ms, hit10)
case(currentState)
IDLE:
if(send) nextState = CLOCK0;
else nextState = IDLE;
CLOCK0:
if(hit01ms) nextState = RTS;
else nextState = CLOCK0;
RTS: //mette data a low e mantiene clock a 0 per un breve periodo di tempo (vedere grafico)
if(hitrts) nextState = CLOCK1;
else nextState = RTS;
CLOCK1: //riporta il clock a 1
nextState = WAIT1;
WAIT1: //rilascia il clock
if(clock) nextState = WAIT1;
else nextState = DELAY;
DELAY:
if(hitdelay) nextState = HIT10EN;
else nextState = DELAY;
WAIT0:
if(~clock) nextState = WAIT0;
else nextState = WAIT1;
HIT10EN:
nextState = SHIFTDATA;
SHIFTDATA:
if(~hit10) nextState = WAIT0;
else nextState = WAITFINAL0;
WAITFINAL1:
if(clock) nextState = WAITFINAL1;
else nextState = WAITFINAL0;
WAITFINAL0:
if(~clock) nextState = WAITFINAL0;
else nextState = IDLE;
default:nextState=IDLE;
endcase

always @(send, hit01ms, hit10)
case(currentState)
IDLE: {reading_clock, reading_data, assignedClock, en10, clr10, clr01ms, shift, busy, clrrts, clrdelay} = 10'b11x0110011;
CLOCK0: {reading_clock, reading_data, assignedClock, en10, clr10, clr01ms, shift, busy, clrrts, clrdelay} = 10'b0100100111;
CLOCK1:{reading_clock, reading_data, assignedClock, en10, clr10, clr01ms, shift, busy, clrrts, clrdelay} = 10'b0010110101;
WAIT1:{reading_clock, reading_data, assignedClock, en10, clr10, clr01ms, shift, busy, clrrts, clrdelay} = 10'b10x0010101;
WAIT0:{reading_clock, reading_data, assignedClock, en10, clr10, clr01ms, shift, busy, clrrts, clrdelay} = 10'b10x0010101;
HIT10EN:{reading_clock, reading_data, assignedClock, en10, clr10, clr01ms, shift, busy, clrrts, clrdelay} = 10'b10x1010101;
SHIFTDATA: {reading_clock, reading_data, assignedClock, en10, clr10, clr01ms, shift, busy, clrrts, clrdelay} = 10'b10x0011101;
WAITFINAL1:{reading_clock, reading_data, assignedClock, en10, clr10, clr01ms, shift, busy, clrrts, clrdelay} = 10'b11x0110101;
WAITFINAL0: {reading_clock, reading_data, assignedClock, en10, clr10, clr01ms, shift, busy, clrrts, clrdelay} = 10'b11x0110101;
RTS:{reading_clock, reading_data, assignedClock, en10, clr10, clr01ms, shift, busy, clrrts, clrdelay} = 10'b0000110101;
DELAY:{reading_clock, reading_data, assignedClock, en10, clr10, clr01ms, shift, busy, clrrts, clrdelay} = 10'b10x0010100;
default:{reading_clock, reading_data, assignedClock, en10, clr10, clr01ms, shift, busy, clrrts, clrdelay} = 10'b11x011001;
endcase

endmodule

module counter10(input ck, reset, en, output reg hit);
reg[3:0] count, countNext;

always @(posedge ck, posedge reset)
if(reset) count = 0;
else count = countNext;

always @(*)
if(en && count < 11) countNext = count + 1;
else countNext = count;

always @(*)
if(count == 11) hit = 1;
else hit = 0;

endmodule

module counter01ms(input ck, reset, output reg hit);
reg[15:0]count;

always @(posedge ck, posedge reset)
if(reset) count <= 0;
else if(count < 10000) count <= count + 1;

always @(*)
if(count == 10000) hit = 1;
else hit = 0;

endmodule

module serializer(input ck, shift, save, input[7:0] dataToSend, output dataout);
reg[10:0] savedData;

assign dataout = savedData[10];

always @(posedge ck)
if(save) 
begin
savedData = {1'b0, dataToSend, ~(^dataToSend), 1'b1}; //costruisce la stringa con gli 11 bit dati gli 8 di informazioni da trasmettere
end
else if(shift) savedData = {savedData[9:0],1'bx};

endmodule


module USBSender(input ck, reset, send, input[7:0] dataToSend, inout data, clock, output busy, readingClock, readingData, output[3:0] currentState, output assignedClock, currentdata); //busy in uscita probabilmente non serve, reading clock serve solo per far funzionare il testbench ma forse serve anche dopo. Se serve lui, servirà anche readdata
wire hit10, hit01ms, en10, shift, clr10, clr01ms, currentdata;



writerSM x0(ck, reset, send, data, clock, hit10, hit01ms, currentdata, en10, clr10, clr01ms, shift, busy, readingClock, readingData, currentState, assignedClock);
counter10 x1(ck, reset || clr10, en10, hit10);
counter01ms x2(ck, reset || clr01ms, hit01ms);
serializer x3(ck, shift, send && ~busy, dataToSend, currentdata); //salva quando siamo in idle e viene inviato un nuovo segnale di send

endmodule
