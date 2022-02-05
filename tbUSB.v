`timescale 1ns / 1ps

module testbench;
    reg ck, reset;
    reg clock1, endclock;
    wire clock;
    assign clock = clock1 || endclock;
    reg [10:0]data = 11'b01010110111;

    wire currentBit;
    assign currentBit = data[10];
    
    wire[10:0] word;
    wire word_ready;
    
    USBReader dut(ck,reset,currentBit,clock, word_ready, word);

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
    
    always #75000 endclock = 1;
    
    always @(negedge clock)
    #55 data = {data[9:0], 1'bx};

    always
    #1 ck = ~ck;


endmodule
