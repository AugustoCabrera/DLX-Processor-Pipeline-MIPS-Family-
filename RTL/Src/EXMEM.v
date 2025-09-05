module EXMEM #(
    parameter NB_DATA = 32,
    parameter NB_REG  = 5
)(
    input  wire                 clk,
    input  wire                 i_reset,
    input  wire                 i_step,

    // Control and data signals
    input  wire                 i_mem2reg,
    input  wire                 i_memWrite,
    input  wire                 i_regWrite,
    input  wire [1:0]           i_width,
    input  wire                 i_sign_flag,
    input  wire [NB_DATA-1:0]   i_result,
    input  wire [NB_DATA-1:0]   i_data4Mem,

    // Write register
    input  wire                 i_regDst,
    input  wire [NB_REG-1:0]    i_rd,
    input  wire [NB_REG-1:0]    i_rt,

    output reg                  o_mem2reg,
    output reg                  o_memWrite,
    output reg                  o_regWrite,
    output reg [1:0]            o_width,
    output reg                  o_sign_flag,
    output reg [NB_DATA-1:0]    o_result,
    output reg [NB_DATA-1:0]    o_data4Mem,
    output reg [NB_REG-1:0]     o_write_reg
);

    // o_write_reg register (updated on positive clock edge)
    //! When asserted, the write register number comes from the rt field.
    //! When deasserted, the write register number comes from the rd field.
    always @(posedge clk) begin
        if (!i_reset) begin
            o_write_reg <= {NB_REG{1'b0}};
        end else if (!i_step) begin
            o_write_reg <= i_regDst ? i_rt : i_rd;
        end
    end

    // Registers for remaining signals (with asynchronous reset)
    always @(posedge clk) begin
        if (!i_reset) begin
            o_mem2reg    <= 1'b0;
            o_memWrite   <= 1'b0;
            o_regWrite   <= 1'b0;
            o_width      <= 2'b11;
            o_sign_flag  <= 1'b0;
            o_result     <= {NB_DATA{1'b0}};
            o_data4Mem   <= {NB_DATA{1'b0}};
        end else if (!i_step) begin
            o_mem2reg    <= i_mem2reg;
            o_memWrite   <= i_memWrite;
            o_regWrite   <= i_regWrite;
            o_width      <= i_width;
            o_sign_flag  <= i_sign_flag;
            o_result     <= i_result;
            o_data4Mem   <= i_data4Mem;
        end
    end

endmodule
