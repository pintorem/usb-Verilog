`timescale 1ns / 1ps

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


/*
module sevenseg(input [4:0] seg, output reg CA, reg CB, reg CC, reg CD, reg CE, reg CF, reg CG);

always @(seg)
case(seg)
5'b00000:{CA,  CB,  CC, CD, CE, CF, CG} = 7'b0000001; //0
5'b00001:{CA , CB , CC, CD, CE, CF, CG} = 7'b1001111; //1
5'b00010:{CA , CB , CC, CD, CE, CF, CG} = 7'b0010010; //2
5'b00011:{CA , CB , CC, CD, CE, CF, CG} = 7'b0000110; //3
5'b00100:{CA , CB , CC, CD, CE, CF, CG} = 7'b1001100; //4
5'b00101:{CA , CB , CC, CD, CE, CF, CG} = 7'b0100100; //5
5'b00110:{CA , CB , CC, CD, CE, CF, CG} = 7'b0100000; //6
5'b00111:{CA , CB , CC, CD, CE, CF, CG} = 7'b0001111; //7
5'b01000:{CA , CB , CC, CD, CE, CF, CG} = 7'b0000000; //8
5'b01001:{CA , CB , CC, CD, CE, CF, CG} = 7'b0000100; //9
5'b01010:{CA , CB , CC, CD, CE, CF, CG} = 7'b0001000; //A
5'b01011:{CA , CB , CC, CD, CE, CF, CG} = 7'b1100000; //B
5'b01100:{CA , CB , CC, CD, CE, CF, CG} = 7'b0110001; //C
5'b01101:{CA , CB , CC, CD, CE, CF, CG} = 7'b1000010; //D
5'b01110:{CA , CB , CC, CD, CE, CF, CG} = 7'b0110000; //E
5'b01111:{CA , CB , CC, CD, CE, CF, CG} = 7'b0111000; //F
5'b10000:{CA , CB , CC, CD, CE, CF, CG} = 7'b1111111; //display off
5'b10001:{CA , CB , CC, CD, CE, CF, CG} = 7'b1111110; //minus sign
5'b10010:{CA , CB , CC, CD, CE, CF, CG} = 7'b1110001; //L
5'b10011:{CA , CB , CC, CD, CE, CF, CG} = 7'b1110000; //t
5'b10100:{CA , CB , CC, CD, CE, CF, CG} = 7'b1111010; //r
5'b10101:{CA , CB , CC, CD, CE, CF, CG} = 7'b1001000; //H
default:{CA , CB , CC, CD, CE, CF, CG} = 7'bXXXXXXX;
endcase



endmodule
*/
module sevenseg(
input [7:0] in_seg,
output reg CA,CB,CC,CD,CE,CF,CG);

always @(in_seg)
case (in_seg)

//alfabeto ITALIANO
8'h1c:{CA, CB, CC, CD, CE, CF, CG} = 7'b0001000; //a
8'h32:{CA, CB, CC, CD, CE, CF, CG} = 7'b1100000; //b
8'h21:{CA, CB, CC, CD, CE, CF, CG} = 7'b0110001; //c
8'h23:{CA, CB, CC, CD, CE, CF, CG} = 7'b1000010; //d
8'h24:{CA, CB, CC, CD, CE, CF, CG} = 7'b0110000; //e
8'h2b:{CA, CB, CC, CD, CE, CF, CG} = 7'b0111000; //f
8'h34:{CA, CB, CC, CD, CE, CF, CG} = 7'b0100000; //g
8'h33:{CA, CB, CC, CD, CE, CF, CG} = 7'b1001000; //h
8'h43:{CA, CB, CC, CD, CE, CF, CG} = 7'b1111001; //i
8'h4b:{CA, CB, CC, CD, CE, CF, CG} = 7'b1110001; //l
8'h3a:{CA, CB, CC, CD, CE, CF, CG} = 7'b0001001; //m
8'h31:{CA, CB, CC, CD, CE, CF, CG} = 7'b1101010; //n
8'h44:{CA, CB, CC, CD, CE, CF, CG} = 7'b1100010; //o
8'h4d:{CA, CB, CC, CD, CE, CF, CG} = 7'b0011000; //p
8'h15:{CA, CB, CC, CD, CE, CF, CG} = 7'b0001100; //q
8'h2d :{CA, CB, CC, CD, CE, CF, CG} =7'b1111010; //r
8'h1b:{CA, CB, CC, CD, CE, CF, CG} = 7'b0100100; //s come il 5
8'h2c:{CA, CB, CC, CD, CE, CF, CG} = 7'b1110000; //t
8'h3c:{CA, CB, CC, CD, CE, CF, CG} = 7'b1000001; //u
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
8'hFF: {CA, CB, CC, CD, CE, CF, CG} = 7'b1111111; //display off
default:{CA, CB, CC, CD, CE, CF, CG} = 7'b1111111; //i caratteri non ammessi non vengono visualizzati nel display
endcase
endmodule



module mux4_4(input [2:0] sel, input[7:0] seg0, seg1, seg2, seg3, seg4, seg5, seg6, seg7, output reg [7:0] outseg);
always @(sel, seg0, seg1, seg2, seg3, seg4, seg5, seg6, seg7)
case(sel)
3'b000:outseg = seg0;
3'b001:outseg = seg1;
3'b010:outseg = seg2;
3'b011:outseg = seg3;
3'b100:outseg = seg4;
3'b101:outseg = seg5;
3'b110:outseg = seg6;
3'b111:outseg = seg7;
endcase
endmodule

module gen_refresh(input ck, reset, output reg refresh); //il ck della scheda va a 100mhz, quindi per far aumentare il numero sul display una volta al secondo è necessario che il contatore vada avanti solo una volta ogni 99999999 cicli di ck
reg [26:0] cnt_nxt;
reg [26:0] cnt;

always @(posedge ck, posedge reset)
if(reset) cnt <= 26'd0;
else cnt <= cnt_nxt;

always @(cnt)
if (cnt < 99999) cnt_nxt = cnt + 1;
else cnt_nxt = 0;

always @(cnt)
if(cnt == 99999) refresh = 1;
else refresh = 0;
endmodule

module cnt_8(input ck, refresh, reset, output reg [2:0]sel);
reg [2:0] sel_nxt;
always @(posedge ck, posedge reset)
if(reset) sel <= 3'b000;
else sel <= sel_nxt;

always @(refresh, sel)
if(refresh) sel_nxt = sel + 1;
else sel_nxt = sel;
endmodule

module dec3_8(input [2:0]sel, output reg [7:0]an);
always @(sel)
case(sel)
3'b000: an = 8'b01111111;
3'b001: an = 8'b10111111;
3'b010: an = 8'b11011111;
3'b011: an = 8'b11101111;
3'b100: an = 8'b11110111;
3'b101: an = 8'b11111011;
3'b110: an = 8'b11111101;
3'b111: an = 8'b11111110;
default an = 8'bXXXXXXXX;
endcase
endmodule

module AdvEighDisplay(input ck, reset, input [7:0] seg0, seg1, seg2, seg3, seg4, seg5, seg6, seg7, input [7:0]dotpos, output [7:0] AN, output CA, CB, CC, CD, CE, CF, CG, reg DP);
wire [2:0] sel; //contiene il numero del display attivo in un dato momento
wire [7:0] current_seg; //contiene il valore di seg tra tutti quelli in ingresso, da mostrare su di un display in un dato momento
wire refresh;
cnt_8 counter(ck, refresh, reset, sel); //ogni volta che il refresh è a 1 aumenta il selettore sel di 1, restituisce sel

mux4_4 mux(sel, seg0, seg1, seg2, seg3, seg4, seg5, seg6, seg7, current_seg); //seleziona il valore corretto (segN) da mostrare sul display attualmente attivo (selezionato da sel), restituisce current_seg
dec3_8 displ_selector(sel, AN); //spegne tutti i display tranne quello attivo (selezionato da sel), restituisce un array di anodi

gen_refresh x0(ck, reset, refresh);

sevenseg displ_controller(current_seg, CA, CB, CC, CD, CE, CF, CG); //fa si che sul display attualmente attivo venga visualizzato il valore restituito da mux

always @(posedge ck)
if(~dotpos == AN) DP <= 0;
else DP <= 1;

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
module USBReader(input ck, reset, dataIn, clock, output word_ready, output[7:0] wordOUT);

    wire hit11,hitlim,shiftL, en11, clr11, clrlim;
    wire [10:0] word;
    assign wordOUT = word[8:1];
    
    
    controllo x0(ck,reset,clock, dataIn, hit11,hitlim,shiftL, en11,clr11,clrlim, word_ready, curr_state);
    shReg x1(ck,dataIn, shiftL, word);
    cnt11 x2(ck,clr11,en11,hit11);
    cntlim x3(ck,clrlim, 37000, hitlim);

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
        default: {shiftL,en11,clr11,clrlim, word_ready, clrdel} = 6'b001101; 
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
    input ck,clrlim, input[31:0] STOP,
    output reg hitlim
);
    reg [31:0] cnt,cntNxt;

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



/*--------------------------
MODULO TOP------------------
----------------------------
*/

module wordRegiter(input reset, word_ready, input [7:0]wordIN, output reg[7:0] curr_word, output reg filteredShift);

always @(posedge word_ready, posedge reset)
if(reset) curr_word <= 8'b00000000;
else if(wordIN != 8'b11110000)begin curr_word <= wordIN; filteredShift <= 1; end
else filteredShift <= 0;

endmodule


module top(input CK100, reset, PS2_CLK, PS2_DATA, output CA, CB, CC, CD, CE, CF ,CG, output[7:0]AN);

reg [63:0] currString;
reg [63:0] currStringNext;

cntlim(CK100, word_ready, 499999999, hitlim);

wire hitlim;

//AdvEighDisplay dps(CK100, reset, currString[39:35], currString[34:30], currString[29:25], currString[24:20], currString[19:15],currString[14:10], currString[9:0], currSting[4:0], 8'b00000000, AN, CA, CB, CC, CD, CE, CF, CG, DP);
AdvEighDisplay dps(CK100, reset, currString[63:56], currString[55:48], currString[47:40], currString[39:32], currString[31:24],currString[23:16], currString[15:8], currString[7:0], 8'b00000000, AN, CA, CB, CC, CD, CE, CF, CG, DP);

wire DP;

reg [4:0] counter, counterNext;
wire[7:0] wourdFiltered;
wire FilteredShift;

wordRegiter xx(reset, word_ready, word, wourdFiltered, FilteredShift);



always @(posedge CK100)
currString <= currStringNext;

always @(posedge word_ready, posedge reset)
if(reset) counter <= 4'b0;
else counter <= counter + 1;

always @(posedge FilteredShift, posedge hitlim, posedge reset)
if(hitlim || reset) currStringNext <= 64'b1111111111111111111111111111111111111111111111111111111111111111;
else currStringNext <= {currString[55:0], wourdFiltered};

wire word_ready;
wire[7:0] word;
USBReader reader1(CK100, reset, PS2_DATA, PS2_CLK, word_ready,word);


endmodule




/*

module tbUSB;
reg ck, reset;
reg clock1, endclock;
wire clock;
assign clock = clock1 || endclock;
reg [10:0]data = 11'b10010101001;



wire currentBit;
assign currentBit = data[10];

//wire[10:0] word;
//wire word_ready;

//USBReader dut(ck,reset,currentBit,clock, word_ready, word);
wire [7:0] AN;
top dut(ck,reset,clock,currentBit,CA,CB,CC,CD,CE,CF,CG,AN);
initial
begin
reset = 0;
clock1 = 1;
endclock = 0;
#5 reset = 1;
#5 reset = 0;
ck = 0;
#75000 data = 11'b10110001001;
#85000 $stop;
end



always
begin
#3334 clock1 = ~clock1;
end

always #800000 endclock = 1;

always @(negedge clock)
#55 data = {data[9:0], 1'bx};

always
#1 ck = ~ck;

endmodule
*/
