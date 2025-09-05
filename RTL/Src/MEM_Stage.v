module MEM_Stage 
#(
    parameter NB_DATA = 32,
    parameter NB_ADDR = 8
)(
    // Input control and data signals
    input wire                   clk,            // Clock signal
    input wire                   i_reset,        // Asynchronous active-low reset
    input wire                   i_step,         // Pipeline halt
    input wire [4:0]             i_reg2write,    // Destination register (from EX stage)
    input wire [NB_DATA-1:0]     i_result,       // ALU result from EX stage
    input wire [1:0]             i_width,        // Memory access width: 00=Byte, 01=Half, 10=Word
    input wire                   i_sign_flag,    // Sign flag: 1=unsigned, 0=signed
    input wire                   i_mem2reg,      // Selects between memory read or ALU result for WB
    input wire                   i_memWrite,     // If 1: store to memory
    input wire                   i_regWrite,     // Enables writing to register file
    input wire [NB_DATA-1:0]     i_data4Mem,     // Data to store (store operations)

    // Outputs to the next pipeline stage
    output wire [NB_DATA-1:0]    o_reg_read,     // Data read from memory
    output wire [NB_DATA-1:0]    o_ALUresult,    // ALU result from EX stage
    output wire [4:0]            o_reg2write,    // Destination register to write in WB stage
    output wire                  o_mem2reg,      // Selects memory result or ALU result
    output wire                  o_regWrite,     // Enables register file write-back

    // Outputs to data memory
    output wire [31:0]           o_data2mem,     // Masked data to write to memory
    output wire [7:0]            o_dataAddr,     // Memory address (lower 8 bits of ALU result)
    output wire                  o_memWrite      // Memory write enable
);

    // Internal registers
    reg [NB_DATA-1:0] data2mem, aligned_mem_read; // Data to store / aligned memory output
    wire [NB_DATA-1:0] reg_read;                  // Raw output from RAM
    wire writeEnable;                             // Internal control signal for memory write

    // Memory masking and alignment logic depending on width and signed/unsigned
    always @(*) begin : mem_access_logic
        data2mem = 0;
        aligned_mem_read = 0;

        case (i_width)
            2'b00: begin // Byte
                data2mem         = i_sign_flag ? {24'b0, i_data4Mem[7:0]}      : {{24{i_data4Mem[7]}}, i_data4Mem[7:0]};
                aligned_mem_read = i_sign_flag ? {24'b0, reg_read[7:0]}        : {{24{reg_read[7]}}, reg_read[7:0]};
            end
            2'b01: begin // Half-word
                data2mem         = i_sign_flag ? {16'b0, i_data4Mem[15:0]}     : {{16{i_data4Mem[15]}}, i_data4Mem[15:0]};
                aligned_mem_read = i_sign_flag ? {16'b0, reg_read[15:0]}       : {{16{reg_read[15]}}, reg_read[15:0]};
            end
            2'b10: begin // Word
                data2mem         = i_data4Mem;
                aligned_mem_read = reg_read;
            end
            default: begin // Invalid case
                data2mem         = 32'b0;
                aligned_mem_read = 32'b0;
            end
        endcase
    end

    // MEM/WB pipeline register: holds data for WB stage
    MEMWB #(
        .NB_DATA(NB_DATA)
    ) memwb_sreg (
        .clk         (clk),
        .i_reset     (i_reset),
        .i_step      (i_step),
        .i_reg_read  (aligned_mem_read),
        .i_result    (i_result),
        .i_reg2write (i_reg2write),
        .i_mem2reg   (i_mem2reg),
        .i_regWrite  (i_regWrite),
        .o_reg_read  (o_reg_read),
        .o_ALUresult (o_ALUresult),
        .o_reg2write (o_reg2write),
        .o_mem2reg   (o_mem2reg),
        .o_regWrite  (o_regWrite)
    );

    // Connections to memory
    assign writeEnable = i_memWrite;
    assign o_data2mem  = data2mem;
    assign o_dataAddr  = i_result[7:0]; // Address for load/store
    assign o_memWrite  = i_memWrite;

    // Data Memory instance
    RAM #(
        .NB_DATA(32),   // 32-bit data
        .NB_ADDR(8)     // 8-bit address space (256 entries)
    ) DataMemoryRAM (
        .clk            (clk),
        .i_write_enable (writeEnable),
        .i_data         (data2mem),
        .i_addr_w       (i_result[7:0]),
        .o_data         (reg_read)
    );

endmodule
