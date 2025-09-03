module IFID (
    input wire         clk,
    input wire         i_reset,
    input wire         i_halt,
    input wire         i_stall,
    input wire [31:0]  i_instruction,   // Raw instruction from IF stage
    output reg [31:0]  o_instruction    // Registered instruction for ID stage
);

    always @(posedge clk) begin
        if (!i_reset) begin
            o_instruction <= 32'b0;
        end
        else if (!i_halt && !i_stall) begin
            o_instruction <= i_instruction;
        end
    end

endmodule
