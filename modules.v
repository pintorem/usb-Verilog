`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Samuele Capacci & Marco Pintore
// 
// Create Date: 12.02.2022 15:54:20
// Design Name: 
// Module Name: modules
// Project Name: ps2 protocol
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

/*INIZIO SENDER----------------------------------------------------------------------------------
***********************
**********************
*******************
******************/

/*Questo modulo è il "top" che racchiude il datapath e il controllo dedicato all'invio dei dati, 
prende in ingresso ck,reset e un comando send, che nel constraint corrisponde al bottone centrale. Questo send
dura un solo ciclo di clock perché nel TOP dell'applicazione gli viene fatto un noBounce.
Ps2c e ps2d sono i segnali di inout del protocollo ps2
busyRead è un segnale che ancora non è perfettamente implementato, per adesso lo mettiamo a 0
dataToSend è il dato da 8 bit da inviare, tipo 0xee, che verrà poi concatenato con i vari bit di parità, start bit e end bit
busyWrite come busyRead non è implementato in questa versione
*/
module senderUSB(
input ck,reset,send,
inout ps2c,ps2d,
input busyRead,
input [7:0] dataToSend,
output busyWrite
);

    wire hit01ms,hit7,clr01ms,en7,clr7;
    
    //USB SENDER

    writerSM z0(ck,reset, send,busyRead,ps2c,ps2d, hit01ms, hit7 ,dataToSend,clr01ms,en7,clr7,busyWrite);
    counter7 z1(ck, clr7, en7,hit7);
    counter01ms z2(ck, clr01ms,hit01ms);

endmodule
/*
Questa è la macchina a stati del writer o "sender"
Regola un datapath che è composto da un contatore che fa 11 conteggi (n.b. si chiama counter7 ma è da modificare appena è tutto pronto)
oltre a un cnt per i 100microsec del protocollo iniziali
oltre a uno shifter che fa entrare uno ad uno i bit da inviare alla periferica
*/
module writerSM(
input ck, reset, send,
input busyRead,
inout ps2c,ps2d, 
input hit01ms, hit7,
input [7:0] data,
output reg clr01ms,en7,clr7,busyWrite
);
    
    parameter[3:0] IDLE = 0, FIRST_SHIFT = 1, FIRST_BIT = 2, WAITCLK = 3, SHIFT = 4,WAIT0 = 5, WAIT1 = 6,ENABLE10 = 7,WAIT_ACK = 8;
    reg[3:0] currentState, nextState;
    
    reg ps2c_out;
    wire ps2d_out;
    reg tri_c,tri_d;
    
    reg load,shift;
    
    /*il local data è una composizione di parity bit - data - bit iniziale,
    così dall'esterno bisogna solamente passare il valore di data che 
    */
    wire [9:0] localData = {1'b1,~^data,data,1'b0}; 
    
    shifter shreg(ck,reset,localData,load,shift,ps2d_out);
    
    always @(posedge ck, posedge reset)
        if(reset) 
            currentState <= IDLE;
        else 
            currentState <= nextState;
    
    always @(currentState,send,ps2c,ps2d, hit01ms, hit7 )
        case(currentState)
        IDLE:
            if(send && busyRead == 0) 
                nextState = FIRST_SHIFT;
            else nextState = IDLE;
        FIRST_SHIFT:
            nextState = FIRST_BIT;

        FIRST_BIT:
            if(hit01ms)
                nextState = WAITCLK;
            else nextState = FIRST_BIT;
            
        WAITCLK:
            if(ps2c==1)
                nextState = WAITCLK;
            else nextState = SHIFT;
        SHIFT:
            if(hit7 && ps2c==0)
                nextState = IDLE;
            else
                nextState = WAIT0;
        WAIT0:
            if(ps2c==1)
                nextState = WAIT1;
            else if(hit7)
                nextState = WAIT_ACK;
            else
                nextState = WAIT0;
        WAIT1:
            if(ps2c==0)
               nextState = ENABLE10;
            else    
                nextState = WAIT1;
        ENABLE10:
            nextState = SHIFT;
        WAIT_ACK:
            if(ps2d==0)
                nextState = IDLE;
            else 
                nextState = WAIT_ACK;
    
        default: nextState = IDLE;
    endcase
    
    always @(currentState,send,ps2c,ps2d, hit01ms, hit7,load,shift)
    case(currentState)
        IDLE: {clr01ms,ps2c_out,tri_c,tri_d,en7,clr7,load,shift,busyWrite} = 9'b1z0001000;
        FIRST_SHIFT: {clr01ms,ps2c_out,tri_c,tri_d,en7,clr7,load,shift,busyWrite} =9'b1Z0001101;
        FIRST_BIT: {clr01ms,ps2c_out,tri_c,tri_d,en7,clr7,load,shift,busyWrite} = 9'b001101001;
        WAITCLK: {clr01ms,ps2c_out,tri_c,tri_d,en7,clr7,load,shift,busyWrite} = 9'b1Z0101001;
        SHIFT: {clr01ms,ps2c_out,tri_c,tri_d,en7,clr7,load,shift,busyWrite} = 9'b1z0100011; //trid=1 perché devo trasmettere il dato
        WAIT0: {clr01ms,ps2c_out,tri_c,tri_d,en7,clr7,load,shift,busyWrite} = 9'b1z0100001;
        WAIT1: {clr01ms,ps2c_out,tri_c,tri_d,en7,clr7,load,shift,busyWrite} = 9'b1z0100001; // in ps2_dat ci va il dato da trasmettere
        ENABLE10: {clr01ms,ps2c_out,tri_c,tri_d,en7,clr7,load,shift,busyWrite} = 9'b1z0010001;
        WAIT_ACK: {clr01ms,ps2c_out,tri_c,tri_d,en7,clr7,load,shift,busyWrite} = 9'b1z0001001;
        default: {clr01ms,ps2c_out,tri_c,tri_d,en7,clr7,load,shift,busyWrite} = 9'b1z000100;
    endcase
    //assign data = ctrl ? 1'bz : 1'b0;
    /*Buffer 3state che gestiscono i bus in ingresso del protocollo*/
    assign ps2c = tri_c ? ps2c_out : 1'bz;
    assign ps2d = tri_d ? ps2d_out : 1'bz;

endmodule


module shifter(                       
input ck,reset,
input [10:0] data,
input load,shift,
output lsb
);
    
    reg [10:0] value,value_nxt;
    assign lsb = value[0];
    
    always @(posedge ck)
        value <= value_nxt;
   
    always @(value,load,shift) 
        if(shift) 
            value_nxt = {1'bx,value[10:1]}; 
        else if(load) 
            value_nxt = data;
        else 
            value_nxt = value;
endmodule

module counter7(
input ck, clr7, en7,
output reg hit7);

    reg[3:0] count, countNext;
    
    always @(posedge ck, posedge clr7)
    if(clr7) 
            count = 0;
    else 
        count = countNext;
    
    always @(*)
        if(en7 && count < 10)
            countNext = count + 1;
        else 
            countNext = count;
    
    always @(*)
        if(count == 10) 
            hit7 = 1;
        else 
            hit7 = 0;

endmodule

module counter01ms(
input ck, clr01ms, 
output reg hit01ms);

    reg [20:0] count,countNext;
    
    always @(posedge ck, posedge clr01ms)
    if(clr01ms) 
        count <= 0;
    else 
        count <= countNext;
    
    always @(count)
    if(count<74999) 
        countNext = count+1;
    else 
        countNext = 0;  
    
    always @(count)
    if(count == 74999)
        hit01ms = 1;
    else 
        hit01ms = 0;

endmodule

/*FINE SENDER----------------------------------------------------------------------------------
***********************
**********************
*******************
******************/


/*USB READER------------------------------
*******************
******************
*****************/

/*Questo modulo contiene il datapath e il controllo del dal reader appunto,
in uscita ci da wordOUT, che corrisponde ai 8 bit di informazione che vengono inviati dalla periferica. Questi
sono esattamente quei bit che vanno in output sui display o che ci danno i dati della perifarica.
Curr state è usato per debug ma si può togliere.
dataIn è il ps2_data, mentre clock è il ps2_clk*/
module USBReader(input ck, reset, dataIn, clock, output word_ready, output[7:0] wordOUT, output[2:0] curr_state);

    wire hit11,hitlim,shiftL, en11, clr11, clrlim;
    wire [10:0] word;
    assign wordOUT = word[8:1];
    
    
    controllo x0(ck,reset,clock, dataIn, hit11,hitlim,shiftL, en11,clr11,clrlim, word_ready, curr_state);
    shReg x1(ck,dataIn, shiftL, word);
    cnt11 x2(ck,clr11,en11,hit11);
    cntlim x3(ck,clrlim, 3700, hitlim);

endmodule

/*
clock e data sono i segnali del protocollo ps2 -> ps2_clk e ps2_data
il datapath si compone si shifter verso sinistra,
un contatore11 a contare gli 11 bit in ingresso
un cntlim che serve per contare fino a un limite impostato in ingresso
word ready è un segnale che va a 1 ogni volta che si completa una lettura
curr state è un debug
*/
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
    
    wire hitdel;
    reg clrdel;
    cntlim x(ck, reset || clrdel, 130, hitdel);
    
    
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
        dataNxt = {bit,data[10:1]};
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
    if(cnt < STOP) 
        cntNxt = cnt + 1;
    else
        cntNxt = cnt;

    always @(cnt)
    if(cnt == STOP)
        hitlim = 1;
    else
        hitlim = 0;

endmodule


/*FINE USB READER
********************
*****************
***************/

//Macchina a stati che gestice la visualizzazione di più stringhe, con un delay di 5 secondi tra una digitazione e l'altra
module smForString(
input ck,reset,
input word_ready,hit5sec,
output reg clr5sec
);
    
    reg [2:0] state,stateNxt;
    parameter [3:0] IDLE=0,SHIFT_DISPLAY=1,ENABLE5SEC=2,WAIT0=3,WAIT1=4,CLEAR_DISPLAY=5;
    
    always @(posedge ck,posedge reset)
        if(reset)
            state<=0;
        else 
            stateNxt = state;
            
    always @(state,word_ready,hit5sec)
    case(state)
        IDLE:
            if(word_ready)
                stateNxt = SHIFT_DISPLAY;
            else 
                stateNxt = IDLE;
        SHIFT_DISPLAY:
            stateNxt = ENABLE5SEC;
        ENABLE5SEC:
            stateNxt = WAIT0;
        WAIT0:
            if(word_ready && hit5sec==0)
                stateNxt = SHIFT_DISPLAY;
            else if(hit5sec == 1)
                stateNxt = WAIT1;
            else stateNxt = WAIT0;
        WAIT1:
            if(word_ready)
                stateNxt = CLEAR_DISPLAY;
            else 
                stateNxt = WAIT1;
        CLEAR_DISPLAY:
            stateNxt = SHIFT_DISPLAY;
    endcase
    
    always @(state)
    case(state)
        IDLE: clr5sec = 1;
        SHIFT_DISPLAY: clr5sec = 0;
        ENABLE5SEC: clr5sec = 0;
        WAIT0: clr5sec = 0;
        WAIT1: clr5sec = 1;
        CLEAR_DISPLAY: clr5sec = 0;
    endcase

endmodule

//Contatore per contare sino a 5 sec
module count5sec(
input ck, clr5sec, 
output reg hit5sec);

    reg [31:0] count,countNext;
    
    always @(posedge ck, posedge clr5sec)
    if(clr5sec) 
        count <= 0;
    else 
        count <= countNext;
    
    always @(count)
    if(count<499999999) 
        countNext = count+1;
    else 
        countNext = 0;  
    
    always @(count)
    if(count == 499999999)
        hit5sec = 1;
    else 
        hit5sec = 0;

endmodule


module shiftDisplay(
input ck,reset,
input [7:0] data,
input wordReady,
output reg [63:0] string); 
//string contiene la parole che si compone digitando delle lettere consecutivamente
    
    reg [63:0] stringNxt;
    
    always @(posedge ck,posedge reset)
        if (reset)
            string <= 32'bx;
        else string <= stringNxt;
    
    always @(wordReady)
        if(wordReady)
            stringNxt = {stringNxt[63:7],data};  
endmodule

//riunisce sia il datapath che il controllo della grafica
module controllerDisplay(
input ck,reset,
input word_ready,
input [7:0] data,
output [63:0] string
);
    wire hit5sec,clr5sec;
    //controllo
    smForString sm(ck,reset,word_ready,hit5sec,clr5sec);
    //datapath
    count5sec counter5(ck, clr5sec, hit5sec);

    shiftDisplay(ck,reset,data,word_ready,string); 
    
endmodule

/*--------------------------
MODULO TOP------------------
----------------------------
*/
module top(
input CK100,reset,
inout PS2_CLK,PS2_DATA,
input send,
output CA,CB,CC,CD,CE,CF,CG,
output [7:0] AN
);
    
    wire [7:0] data_curr;
    wire [23:0] dataOut;
    wire [7:0] dataToSend = 8'hea;
    wire refresh;
    wire busyRead,busyWrite;
    wire word_ready;
    
    wire [2:0] curr_state;
    
    //KEYBOARD READER
    USBReader x(CK100, reset,PS2_DATA,PS2_CLK,word_ready, data_curr,curr_state);

    wire hit01ms,hit7,clr01ms,en7,clr7;
    
    //USB SENDER
    wire sendNb;
    noBounce nob(CK100,reset,send,sendNb);
    senderUSB dut(CK100,reset,sendNb,PS2_CLK,PS2_DATA,1'b0,dataToSend,busyWrite);
    
    wire [63:0] string;
    //controller del display (datapath+controllo)
    controllerDisplay disp(CK100,reset,word_ready,data_curr,string);
    //EIGHT DISPLAY
    genRefresh y3(CK100,reset,refresh);
    eightDisplay x0(CK100, reset, refresh,string[7:0],string[15:8],string[23:16],string[31:24],string[39:32],string[47:40],string[55:48],string[63:56],AN,CA,CB,CC,CD,CE,CF,CG);
endmodule

/*----------------------------------------
EIGHTDISPLAY MODIFICATO PER LA TASTIERA
---------------------------------------*/
module sevenseg(
    input [7:0] in_seg,
    output reg CA,CB,CC,CD,CE,CF,CG);
    
        always @(in_seg)
        case (in_seg)
	
	   //alfabeto ITALIANO
        8'h1c:{CA, CB, CC, CD, CE, CF, CG} = 7'b0001000; //a
        8'h32:{CA, CB, CC, CD, CE, CF, CG} = 7'b1100000; //b
        8'h21:{CA, CB, CC, CD, CE, CF, CG} = 7'b0110001;  //c
        8'h23:{CA, CB, CC, CD, CE, CF, CG} = 7'b1000010;  //d
        8'h24:{CA, CB, CC, CD, CE, CF, CG} = 7'b0110000;  //e
        8'h2b:{CA, CB, CC, CD, CE, CF, CG} = 7'b0111000; //f
        8'h34:{CA, CB, CC, CD, CE, CF, CG} = 7'b0100000;  //g
        8'h33:{CA, CB, CC, CD, CE, CF, CG} = 7'b1001000;  //h
        8'h43:{CA, CB, CC, CD, CE, CF, CG} = 7'b1111001; //i
        8'h4b:{CA, CB, CC, CD, CE, CF, CG} = 7'b1110001; //l
        8'h3a:{CA, CB, CC, CD, CE, CF, CG} = 7'b0001001;  //m 
        8'h31:{CA, CB, CC, CD, CE, CF, CG} = 7'b1101010;  //n
        8'h44:{CA, CB, CC, CD, CE, CF, CG} = 7'b1100010;  //o
       	8'h4d:{CA, CB, CC, CD, CE, CF, CG} = 7'b0011000;  //p
        8'h15:{CA, CB, CC, CD, CE, CF, CG} = 7'b0001100;  //q 
        8'h2d :{CA, CB, CC, CD, CE, CF, CG} =7'b1111010; //r
        8'h1b:{CA, CB, CC, CD, CE, CF, CG} = 7'b0100100; //s come il 5
       	8'h2c:{CA, CB, CC, CD, CE, CF, CG} = 7'b1110000;  //t
        8'h3c:{CA, CB, CC, CD, CE, CF, CG} = 7'b1000001;  //u
        8'h2a :{CA, CB, CC, CD, CE, CF, CG} = 7'b1100011;//v

        8'h1a :{CA, CB, CC, CD, CE, CF, CG} = 7'b0010010;//z come il 2
        8'h45: {CA, CB, CC, CD, CE, CF, CG} = 7'b0000001; //0
        8'h16: {CA, CB, CC, CD, CE, CF, CG} = 7'b1001111; //1
        8'h1e: {CA, CB, CC, CD, CE, CF, CG} = 7'b0010010; //2
        8'h26: {CA, CB, CC, CD, CE, CF, CG} = 7'b0000110; //3
        8'h25: {CA, CB, CC, CD, CE, CF, CG} = 7'b1001100; //4 
        8'h2e: {CA, CB, CC, CD, CE, CF, CG} = 7'b0100100; //5
        8'h36: {CA, CB, CC, CD, CE, CF, CG} = 7'b0100000; //6
        8'h3d: {CA, CB, CC, CD, CE, CF, CG} = 7'b0001111; //7
       	8'h3e: {CA, CB, CC, CD, CE, CF, CG} = 7'b0000000; //8
        8'h46: {CA, CB, CC, CD, CE, CF, CG} = 7'b0000100; //9 
        default:{CA, CB, CC, CD, CE, CF, CG} = 7'bxxxxxxx;
        endcase
endmodule

module contatore(
    input ck,reset,refresh,
    output reg [2:0] q);
        //cnt = q ingresso attuale,  cnt_nxt = d uscita futura
        reg[2:0] d;
        
        always@(posedge ck,posedge reset) //Descrizione flip flop D
            if(reset) q <= 0; //solo q dipende da clock e reset
            else q <= d;
            
        always@(q,refresh) //Descrizione R.C.
            if(refresh) d = q+1;
            else d = q;
endmodule

module genRefresh(
    input ck,reset,
    output reg refresh);
    
    reg [16:0] q,d;
    
    always @(posedge ck,posedge reset)
        if(reset) q <= 0;
        else q <= d;
        
    always @(q) 
        if(q<99999) d=q+1; //1/1000 secondi per via dell'occhio umano, 100MHZ = 1sec /1000 = 10000
        else d=0; 
 
    always @(q) 
        if(q==0) refresh=1; 
        else refresh=0; 
endmodule

module decoder(
    input [2:0] sel, //sel ? un contatore in questo progetto
    output reg [7:0] an);
      
    always @(sel)
    case (sel)
    3'd0: an = 8'b11111110;
    3'd1: an = 8'b11111101;
    3'd2: an = 8'b11111011;
    3'd3: an = 8'b11110111;
    3'd4: an = 8'b11101111;
    3'd5: an = 8'b11011111;
    3'd6: an = 8'b10111111;
    3'd7: an = 8'b01111111;    
    default: an = 8'bxxxxxxxx;
    endcase
endmodule

module multiplexer(
    input [7:0] in0,in1,in2,in3,in4,in5,in6,in7, 
    input [2:0] sel,
    output reg [7:0] in_seg
);

    always @(sel)
        case(sel)
        3'd0: in_seg = in0;
        3'd1: in_seg = in1;
        3'd2: in_seg = in2;
        3'd3: in_seg = in3;
        3'd4: in_seg = in4;
        3'd5: in_seg = in5;
        3'd6: in_seg = in6;
        3'd7: in_seg = in7;
        default: in_seg = 4'bxxxx;
        endcase
endmodule

module eightDisplay(
    input ck, reset, refresh,
    input [7:0] seg0,seg1,seg2,seg3,seg4,seg5,seg6,seg7,
    output [7:0] an,
    output CA,CB,CC,CD,CE,CF,CG
);
    wire [2:0] sel;
    wire [7:0] in_seg;
    
    contatore x0(ck,reset,refresh,sel);
    decoder x1(sel,an);
    multiplexer x2(seg0,seg1,seg2,seg3,seg4,seg5,seg6,seg7,sel,in_seg);
    sevenseg x3(in_seg,CA,CB,CC,CD,CE,CF,CG);
      
endmodule
