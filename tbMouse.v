`timescale 1ns / 1ps

module tbMouse;
    reg ck, reset;
    reg clock1, endclock;
    wire clock;
    assign clock = clock1 || endclock;
    reg [32:0]data = 11'b01010110111;

    wire currentBit;
    assign currentBit = data[32];
    
    wire[10:0] word;
    wire [32:0] mouseData;
    wire word_ready, valid;
    
    USBReader dut0(ck,reset,currentBit,clock, word_ready, word);
    register dut1(ck,reset,word_ready,word,valid,mouseData);
    
    initial
    begin
        reset = 0;
        clock1 = 1;
        endclock = 0;
        #5 reset = 1;
        #5 reset = 0;
        ck = 0;
        #85000 $stop;
    end

    always
    begin
        #3334 clock1 = ~clock1;
    end
    
    always #230000 endclock = 1;
    
    always @(negedge clock)
    #55 data = {data[31:0], 1'bx};

    always
    #1 ck = ~ck;
    
    


endmodule
