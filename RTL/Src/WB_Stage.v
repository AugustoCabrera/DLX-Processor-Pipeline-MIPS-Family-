module WB_Stage
#(
    parameter NB_DATA = 32, // Number of data bits
    parameter NB_ADDR = 5   // Number of address bits
)
(
    input   wire    [NB_DATA-1: 0]  i_reg_read,   // Data read from memory
    input   wire    [NB_DATA-1: 0]  i_ALUresult,  // ALU result
    input   wire    [4:0]           i_reg2write,  // Destination register (rd or rt)

    input   wire                    i_mem2reg,    // 1 -> Store value from memory, 0 -> Store ALU result
    input   wire                    i_regWrite,   // Control signal for register write

    output  wire    [NB_DATA-1: 0]  o_write_data, // Data to be written to the register
    output  wire    [4:0]           o_reg2write,  // Destination register
    output  wire                    o_regWrite    // Control signal for register write
);

    // Selects the data to write depending on i_mem2reg
    assign o_write_data = (i_mem2reg) ? i_reg_read : i_ALUresult;
    
    // Propagates the destination register
    assign o_reg2write = i_reg2write;
    
    // Propagates the write control signal
    assign o_regWrite  = i_regWrite;

endmodule
