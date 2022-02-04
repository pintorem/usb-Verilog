`timescale 1ns / 1ps

module tbUSB;

    reg ck,reset;
    reg clock;
    reg dataIn = 1;
    
    always #5 ck = ~ck;
    always #15 clock = ~clock;
    
    wire hit11,hit34us,shiftL, en11,en34us,clr11,clr34us;
    wire [31:0] data;
    
    controllo dut0(ck,reset,clock,hit11,hit34us,shiftL, en11,en34us,clr11,clr34us); 
    shReg dut1(ck,dataIn,shiftL,data);
    cnt11 dut2(ck,clr11,en11,hit11);
    cnt34us dut3(ck,clr34us,hit34us);
    
    initial
        begin
            ck = 0;
            clock = 0;
            reset = 0;
            dataIn = 1;
            
            #200000 $stop;
        end
endmodule
