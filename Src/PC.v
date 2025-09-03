module PC (
    input   wire                    clk,
    input   wire                    i_reset,
    input   wire    [32-1:0]  i_jump_address,
    input   wire                    i_jump,   // pc <= addr2jump (for jumps)
    output  reg     [32-1:0]  o_pc,
    
    input   wire                    i_halt,
    input   wire                    i_stall
);


    always @(posedge clk or negedge i_reset) begin
        if (!i_reset) begin
            o_pc <= 32'b0;        // Reset PC to 0
        end
        else if (!i_halt && !i_stall) begin
            if (i_jump) begin
                // Jump to address in i_jump_address
                o_pc <= i_jump_address;
            end else begin
                // Normal increment by 4
                o_pc <= o_pc + 4;
            end
        end
    end
endmodule
