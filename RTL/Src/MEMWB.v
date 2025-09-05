module MEMWB #(
    parameter NB_DATA = 32
)(
    input  wire              clk,
    input  wire              i_reset,
    input  wire              i_step,

    // Entradas del pipeline
    input  wire [NB_DATA-1:0] i_reg_read,
    input  wire [NB_DATA-1:0] i_result,
    input  wire [4:0]         i_reg2write,
    input  wire               i_mem2reg,
    input  wire               i_regWrite,

    // Salidas del pipeline
    output reg  [NB_DATA-1:0] o_reg_read,
    output reg  [NB_DATA-1:0] o_ALUresult,
    output reg  [4:0]         o_reg2write,
    output reg                o_mem2reg,
    output reg                o_regWrite
);

    always @(posedge clk) begin
        if (!i_reset) begin
            o_reg_read  <= {NB_DATA{1'b0}};
            o_ALUresult <= {NB_DATA{1'b0}};
            o_reg2write <= 5'b0;
            o_mem2reg   <= 1'b0;
            o_regWrite  <= 1'b0;
        end else if (!i_step) begin
            o_reg_read  <= i_reg_read;
            o_ALUresult <= i_result;
            o_reg2write <= i_reg2write;
            o_mem2reg   <= i_mem2reg;
            o_regWrite  <= i_regWrite;
        end
    end

endmodule
