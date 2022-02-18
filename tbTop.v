`timescale 1ns / 1ps

module tbTop;

    reg ck,reset;
     
    tri1 ps2_clk;
    tri1 ps2_data;
    reg ps2c;
    reg ps2d;
    reg send;
    
    //wire [7:0] data = 8'hee;
    
    assign ps2_clk = ps2c==0 ? 0 : 1'bz;
    //assign ps2_data = ps2d==0 ? 0 : 1'bz;
   
    wire hit01ms,hit7,clr01ms,en7,clr7;
    
    wire busyRead = 0;
    
    top dut(ck,reset,ps2_clk,ps2_data,send,CA,CB,CC,CD,CE,CF,CG,AN);
    initial
    begin
        ck = 0;
        #1 reset = 1;
        #3 reset = 0;
        
        send = 0;
        ps2c = 1;
        ps2d = 1'bz;
        
        #1 reset = 1;
        #3 reset = 0;
        #3 send = 1;
        #3 send = 0;
        
        //Simulazione di una generazione di clock generato dalla periferica che vuole ricevere i dati
        #150009 ps2c = 1;
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
        
        #50000 ps2d= 0;
        //#50000 ps2c = 0; ps2d = 0;//segnale di ack che arriva dalla periferica
        #50000 ps2c = 1;
        
        #85000 $stop;
        
    end
    
    always #1 ck = ~ck;
    
endmodule
