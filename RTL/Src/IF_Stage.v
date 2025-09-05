module IF_Stage
(
    input wire          clk,
    input wire          i_reset,   
    input wire          i_jump,             //! 1 = jump asserted | 0 = normal PC increment
    input wire          i_we,               //! Write enable to initialize memory
    input wire [31:0]   i_jump_address,     //! Address to jump
    input wire [31:0]   i_inst_data,        //! Data to write if i_we is 1
    input wire [7:0]    i_instruction_addr, //! Address to write instruction
    input wire          i_halt,             //! Pipeline halt
    input wire          i_stall,            //! Pipeline stall
    output wire [31:0]  o_instruction,      //! Registered instruction (IFID output)
    output wire [31:0]  o_pc                //! Program counter
);

    wire [31:0] instruction_data;
    wire [7:0]  instruction_addr;

    //! PC module
    PC programcounter (
        .clk            (clk),
        .i_reset        (i_reset),
        .i_jump_address (i_jump_address),
        .i_jump         (i_jump),
        .o_pc           (o_pc),
        .i_halt         (i_halt),
        .i_stall        (i_stall)
    );

    //! Instruction RAM
    RAM #(
        .NB_DATA(32),
        .NB_ADDR(8)
    ) InstructionMemory (
        .clk            (clk),
        .i_write_enable (i_we),
        .i_data         (i_inst_data),
        .i_addr_w       (instruction_addr),
        .o_data         (instruction_data)
    );

    //! Address selection: for writing (i_we) or for fetch
    assign instruction_addr = i_we ? i_instruction_addr : o_pc[7:0];

    //! IF/ID register instantiated internally
    IFID ifid_sreg (
        .clk           (clk),
        .i_reset       (i_reset),
        .i_halt        (i_halt),
        .i_stall       (i_stall),
        .i_instruction (instruction_data),
        .o_instruction (o_instruction)
    );

endmodule
