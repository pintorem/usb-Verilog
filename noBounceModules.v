`timescale 1ns / 1ps

/*
module top(
    input CK100,[0:0] SW,TASTO,
    output [7:0] AN,
    output CA,CB,CC,CD,CE,CF,CG);
    
    wire [31:0] cnt;
    wire refresh;
    wire EN;
    
    
    eightDisplay x0(CK100,SW[0],refresh,cnt[3:0],cnt[7:4],cnt[11:8],cnt[15:12],cnt[19:16],cnt[23:20],cnt[27:24],cnt[31:28],AN,CA,CB,CC,CD,CE,CF,CG);
    genRefresh x1(CK100,SW[0],refresh);
    countHEX x2(CK100,SW[0],EN,cnt);
    noBounce x3(CK100,SW[0],TASTO,EN);
   
 endmodule
 */

module count(
    input ck,clr,
    output reg hit);
    
    reg [16:0] count,count_nxt;
    
    always @(posedge ck)
        count <= count_nxt;
        
    always @(clr,count)
        if(clr) count_nxt = 0;
        else if(count<4) count_nxt = count+1;
             else count_nxt = count;
    always @(count)
        if(count==4) hit = 1;
        else hit = 0;
            
endmodule

module macstati(
    input ck,reset,TASTO,HIT,
    output reg CLR,EN
);
    reg [2:0] state,state_nxt;
    parameter [2:0] IDLE0=0,UNO=1,WAIT1=2,IDLE1=3,WAIT0=4;
    
    always @(posedge ck, posedge reset)
    if(reset) state<=IDLE0;
        else state<=state_nxt;
    //Comportamento rispetto agli ingressi
    always @(state,TASTO,HIT)
        case(state)
        IDLE0: if(TASTO) state_nxt = UNO;
               else state_nxt = IDLE0;
        UNO: state_nxt = WAIT1;
        WAIT1: if(HIT) state_nxt = IDLE1;
               else state_nxt = WAIT1;
        IDLE1:if(TASTO) state_nxt = IDLE1;
               else state_nxt = WAIT0;
        WAIT0:if(HIT) state_nxt = IDLE0;
               else state_nxt = WAIT0;
        default: state_nxt=3'bxxx;
        endcase
    //variabili in uscita in base agli stati
    always @(state)
        case(state)
        IDLE0:{CLR,EN}=2'b10;
        UNO:{CLR,EN}=2'b01; //01-> necessriamente en=1, clr=0 così quando arriviamo a wait1 il contatore che conta i 100000 è gia arrivato a 2 (ha già fatto un colpo), in pratica si ignora l'ingresso da subito
        WAIT1:{CLR,EN}=2'b00; // clr andrà a 0 solo solo quando è nello stato di wait, ergo si farebbe un conteggio in più di clock (quello per cui si sta nello stato uno)
        IDLE1:{CLR,EN}=2'b10; 
        WAIT0:{CLR,EN}=2'b00;
        default: {CLR,EN}=2'bxx;
        endcase 
endmodule

//topnobounce
module noBounce(
    input ck,reset,TASTO,
    output EN //EN AL POSTO DI NOBOUNCE PERCHE' IL SEGNALE EN RIMANE SOLO PER UN COLPO DI CLOCK
);

    wire CLR,HIT;
    
    //datapath
    count x0(ck,CLR,HIT);
    //controllo
    macstati x1(ck,reset,TASTO,HIT,CLR,EN);
    
endmodule
 

 module countHEX(
    input ck,reset,EN,
    output reg [31:0] cnt);
    
    reg [31:0] cnt_nxt;
    
    always @(posedge ck,posedge reset)
        if(reset) cnt<=0;
        else cnt<= cnt_nxt;
    always @(cnt,EN)
        if(EN) cnt_nxt = cnt+1;
        else cnt_nxt = cnt;
 endmodule
