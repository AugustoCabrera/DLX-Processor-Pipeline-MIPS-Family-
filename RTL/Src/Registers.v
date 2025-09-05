module Registers
#(
    parameter NB_DATA = 32,
    parameter NB_ADDR = 5
)(
    input wire              clk                         ,
    input wire              i_reset                     ,
    
    //write
    input wire                i_we                          ,
    input wire  [NB_ADDR-1:0] i_wr_addr                   ,
    input wire  [NB_DATA-1:0] i_wr_data                   ,
    
    //read               
    input wire  [NB_ADDR-1:0] i_read_reg1                  ,
    input wire  [NB_ADDR-1:0] i_read_reg2                  ,

    output wire [NB_DATA-1:0] o_ReadData1                  ,
    output wire [NB_DATA-1:0] o_ReadData2
);

    reg [NB_DATA-1:0] registers[2**NB_ADDR-1:0]          ;
    integer i;


        /*  VALORES DEL FOR:
        $zero = 0, $at = 1, $v0 = 2, $v1 = 3, $a0 = 4, $a1 = 5, $a2 = 6, $a3 = 7,  
        $t0 = 8, $t1 = 9, $t2 = 10, $t3 = 11, $t4 = 12, $t5 = 13, $t6 = 14, $t7 = 15,  
        $s0 = 16, $s1 = 17, $s2 = 18, $s3 = 19, $s4 = 20, $s5 = 21, $s6 = 22, $s7 = 23,  
        $t8 = 24, $t9 = 25, $k0 = 26, $k1 = 27, $gp = 28, $sp = 29, $fp = 30, $ra = 31  
        */


    //! writing block
    always @(negedge clk)
    begin
        if(~i_reset)
        begin
            for( i = 0; i < 2**NB_ADDR; i = i+1)
            begin
                registers[i] <= 0                        ;
            end
        end
        else
        begin
            if(i_we)
            begin
                registers[i_wr_addr] <= i_wr_data        ;
            end
        end
    end

    assign o_ReadData1 = registers[i_read_reg1]            ;
    assign o_ReadData2 = registers[i_read_reg2]            ;

endmodule