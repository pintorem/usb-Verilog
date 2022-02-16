`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.02.2022 15:54:20
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

/*Bisogna rifare un altro modulo perché sono formattati diversamente i dati della keyboard e del mouse,
infatti il mouse è così
la keyboard è così: 
cambiano le posizioni dei bit e quindi non possiamo fare un singolo reader*/
/*module mouseReader(
input ps2_clk, 
input ps2_data, 
output reg [7:0] dataOut1,
output reg [7:0] dataOut2,
output reg [7:0] dataOut3
);
    //TODO: DA TESTARE
    reg [32:0] data;
    reg [5:0] i = 0;
    
    assign dataOut1 = data[30:23];
    assign dataOut2 = data[19:12];
    assign dataOut3 = data[9:2];
    
    always @(negedge ps2_clk)
    begin
        
        data[i] = ps2_data;
     
        if(i==33)
        begin
            dataOut1 = data[30:23];
            dataOut2 = data[19:12];
            dataOut3 = data[9:2];
            i = 0;
        end
        else i = i + 1;

    end
endmodule*/


module keyBoardReader(
input ps2_clk, 
input ps2_data, 
input busyWrite,
output reg [7:0] dataOut,
output reg busyRead
);

    reg [3:0] i = 0;
    reg [10:0] data;
    reg startBit,stopBit,parity;
    
    always @(negedge ps2_clk)
    begin
        if(busyWrite == 0)
        begin
            if(i==0)
                startBit = ps2_data;
            else if(i==9)
                parity = ps2_data;
            else if(i==10)
                stopBit = ps2_data;
            else dataOut[i-1] = ps2_data;
            
            if(i<10)
            begin
                i = i+1;
                busyRead = 1;
            end
            else begin
                i = 0;
                busyRead = 0;
            end
        end
    end
    
endmodule

module writerSM(
input ck, reset, send,
input busyRead,
inout ps2c,ps2d, 
input hit01ms, hit7,
input [7:0] data,
output reg clr01ms,en7,clr7,busyWrite
);
    
    parameter[3:0] IDLE = 0, CLKHOST0 = 1, FIRST_BIT = 2, SHIFT = 3,WAIT0 = 4, WAIT1 = 5,ENABLE10 = 6,WAIT_ACK = 7;
    reg[3:0] currentState, nextState;
    
    reg ps2c_out;
    wire ps2d_out;
    reg tri_c,tri_d;
    
    reg load,shift;
    
    /*il local data è una composizione di parity bit - data - bit iniziale,
    così dall'esterno bisogna solamente passare il valore di data che 
    */
    wire [9:0] localData = {~^data,data,1'b0}; 
    
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
                nextState = CLKHOST0;
            else nextState = IDLE;
        CLKHOST0:
            if(hit01ms) nextState = FIRST_BIT;
            else nextState = CLKHOST0;
        FIRST_BIT:
            if(ps2c==0)
                nextState = SHIFT;
            else nextState = FIRST_BIT;
        SHIFT:
            if(hit7)
                nextState = WAIT_ACK;
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
                
            /*else if(ps2c==1)
                if(hit7)
                    nextState = WAIT_ACK;*/
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
        CLKHOST0: {clr01ms,ps2c_out,tri_c,tri_d,en7,clr7,load,shift,busyWrite} =9'b001001101;
        FIRST_BIT: {clr01ms,ps2c_out,tri_c,tri_d,en7,clr7,load,shift,busyWrite} = 9'b1z0101001;
        SHIFT: {clr01ms,ps2c_out,tri_c,tri_d,en7,clr7,load,shift,busyWrite} = 9'b1z0000011; //trid=1 perché devo trasmettere il dato
        WAIT0: {clr01ms,ps2c_out,tri_c,tri_d,en7,clr7,load,shift,busyWrite} = 9'b1z0100001;
        WAIT1: {clr01ms,ps2c_out,tri_c,tri_d,en7,clr7,load,shift,busyWrite} = 9'b1z0100001; // in ps2_dat ci va il dato da trasmettere
        ENABLE10: {clr01ms,ps2c_out,tri_c,tri_d,en7,clr7,load,shift,busyWrite} = 9'b1z0010001;
        WAIT_ACK: {clr01ms,ps2c_out,tri_c,tri_d,en7,clr7,load,shift,busyWrite} = 9'b1z0001001;
        default: {clr01ms,ps2c_out,tri_c,tri_d,en7,clr7,load,shift,busyWrite} = 9'b1z000100;
    endcase
    //assign data = ctrl ? 1'bz : 1'b0;
    assign ps2c = tri_c ? ps2c_out : 1'bz;
    assign ps2d = tri_d ? ps2d_out : 1'bz;

endmodule

module shifter(                       
input ck,reset,
input [9:0] data,
input load,shift,
output lsb
);
    
    reg [9:0] value,value_nxt;
    assign lsb = value[0];
    
    always @(posedge ck)
        value <= value_nxt;
   
    always @(value,load,shift) 
        if(shift) 
            value_nxt = {1'bx,value[9:1]}; 
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
        if(en7 && count < 9)
            countNext = count + 1;
        else 
            countNext = count;
    
    always @(*)
        if(count == 9) 
            hit7 = 1;
        else 
            hit7 = 0;

endmodule

module counter01ms(
input ck, clr01ms, 
output reg hit01ms);

    reg [19:0] count,countNext;
    
    always @(posedge ck, posedge clr01ms)
    if(clr01ms) 
        count <= 0;
    else 
        count <= countNext;
    
    always @(count)
    if(count<49999) 
        countNext = count+1;
    else 
        countNext = 0;  
    
    always @(count)
    if(count == 49999)
        hit01ms = 1;
    else 
        hit01ms = 0;

endmodule

module senderUSB(
input ck,reset,send,
inout ps2c,ps2d,
input [7:0] data
);

    wire hit01ms,hit7,clr01ms,en7,clr7;
    

    writerSM x0(ck, reset, send,ps2c,ps2d, hit01ms, hit7 ,data,clr01ms,en7,clr7);

    counter7 x1(ck, clr7, en7,hit7);

    counter01ms x2(ck, clr01ms,hit01ms);

endmodule

module top(
input CK100,
inout PS2_CLK,PS2_DATA,
input send,
output CA,CB,CC,CD,CE,CF,CG,
output [7:0] AN
//output reg ledSx
);
    
    wire [7:0] data_curr;
    wire [23:0] dataOut;
    wire [7:0] dataToSend = 8'hee;
    wire refresh;
    //assign ledSx = busyRead;
    wire busyRead,busyWrite;
    
    //KEYBOARD READER
    keyBoardReader x1(PS2_CLK,PS2_DATA,busyWrite,data_curr,busyRead);
    //mouseReader x2(PS2_CLK,PS2_DATA, dataOut);
   
    wire hit01ms,hit7,clr01ms,en7,clr7;
    
    //USB SENDER
    writerSM z0(CK100,0, send,busyRead,PS2_CLK,PS2_DATA, hit01ms, hit7 ,dataToSend,clr01ms,en7,clr7,busyWrite);
    counter7 z1(CK100, clr7, en7,hit7);
    counter01ms z2(CK100, clr01ms,hit01ms);


    //EIGHT DISPLAY
    genRefresh y3(CK100,0,refresh);
    eightDisplay x0(CK100, 0, refresh,data_curr[3:0],data_curr[7:4],4'bx,4'bx,4'bx,4'bx,4'bx,4'bx,AN,CA,CB,CC,CD,CE,CF,CG);
    //eightDisplay x0(CK100, 0, refresh,dataOut[3:0],dataOut[7:4],4'bx,4'bx,4'bx,4'bx,4'bx,4'bx,AN,CA,CB,CC,CD,CE,CF,CG);
endmodule

/*TESTBENCH SENDER*/
`timescale 1ns / 1ns

module tbSenderMarco;

    reg ck,reset,send;
    
    tri1 ps2_clk;
    tri1 ps2_data;
    reg ps2c;
    reg ps2d;
    
    wire [7:0] data = 8'b10101011;
    
    //assign ps2_clk = ps2c;
    //assign ps2_data = ps2d;
    
    assign ps2_clk = ps2c==0 ? 0 : 1'bz;
    //assign ps2_data = ps2d==0 ? 0 : ps2_data;
   
    wire hit01ms,hit7,clr01ms,en7,clr7;
    
    writerSM x0(ck, reset, send,ps2_clk,ps2_data, hit01ms, hit7 ,data,clr01ms,en7,clr7);
    
    counter7 x1(ck, clr7, en7,hit7);

    counter01ms x2(ck, clr01ms,hit01ms);
    
    initial 
    begin
        ck=0;
        reset = 0;
        send = 0;
        ps2c = 1;
        ps2d = 1'bz;
        
        #1 reset = 1;
        #3 reset = 0;
        #3 send = 1;
        #3 send = 0;
        
        //Simulazione di una generazione di clock generato dalla periferica che vuole ricevere i dati
        #100000 ps2c = 1;
        #50000 ps2c = 0;
        #50000 ps2c = 1;
        #50000 ps2c = 0;
        #50000 ps2c = 1;
        #50000 ps2c = 0;
        #50000 ps2c = 1;
        #50000 ps2c = 0;
        #50000 ps2c = 1;
        #50000 ps2c = 0;
        #50000 ps2c = 1;
        #50000 ps2c = 0;
        #50000 ps2c = 1;
        #50000 ps2c = 0;
        #50000 ps2c = 1;
        #50000 ps2c = 0;
        #50000 ps2c = 1;
        #50000 ps2c = 0;
        #50000 ps2c = 1;
        #50000 ps2c = 0;
        #50000 ps2c = 1;
        
        #50000 ps2c = 0; ps2d = 0;//segnale di ack che arriva dalla periferica
        #50000 ps2c = 1;
        
        #85000 $stop;
    end

    always #1 ck = ~ck;
    
    
endmodule