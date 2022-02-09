`timescale 1ns / 1ps

//---------------------------------
//per il READER:

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

//-------------------------------------------------------------------------
//Per il sender:
module testbench;
    reg ck, reset;
    reg clock1, endclock;
    wire data;
    wire clock;
    assign clock = clock1 || endclock;
    reg [9:0]dataToSend = 11'b0101011011;
    reg send;
   
    wire clockIn;
    wire inoutClock;
    assign inoutClock = clockIn ? clock : 1'bz;
    
    USBSender dut(ck, reset, send, dataToSend, data, inoutClock ,busy, clockIn);

    initial
    begin
        send = 0;
        reset = 0;
        clock1 = 1;
        endclock = 0;
        ck = 0;
        //clockIn = 1;
        #5 reset = 1;
        #5 reset = 0;
        #20 send = 1;
        #5 send = 0;
        //clockIn = 0;
        //#20 clockIn = 1;
        #105000 $stop;
    end

    always #1 ck = ~ck;
    
    always
    begin
        #3334 clock1 = ~clock1;
    end
    
    always #100000 endclock = 1;

endmodule

