module IDEX (
    input wire clk,
    input wire i_reset,
    input wire i_step,
    input wire i_stall,

    input wire [31:0] ReadData1,
    input wire [31:0] ReadData2,
    input wire [4:0] rd, rs, rt,
    input wire [5:0] opcode, func,
    input wire [31:0] w_immediat,
    input wire w_branch, w_regDst, w_mem2Reg, w_memRead, w_memWrite,
    input wire w_immediate,
    input wire w_regWrite,
    input wire [1:0] w_aluSrc, w_aluOp, w_width,
    input wire w_sign_flag,
    input wire [31:0] i_pc,
    input wire [31:0] i_instruction,

    output reg [31:0] o_reg_DA,
    output reg [31:0] o_reg_DB,
    output reg [4:0] o_rd, o_rs, o_rt,
    output reg [5:0] o_opcode, o_func,
    output reg [4:0] o_shamt,
    output reg [31:0] o_immediate,
    output reg o_branch, o_regDst, o_mem2Reg, o_memRead, o_memWrite,
    output reg o_immediate_flag,
    output reg o_regWrite,
    output reg [1:0] o_aluSrc, o_aluOp, o_width,
    output reg o_sign_flag
);
    localparam [5:0] JAL_TYPE = 6'b000011;
    localparam [5:0] R_TYPE   = 6'b000000;
    localparam [5:0] JARL_TYPE = 6'b011111;

    (* keep *) wire _unused_idex_instr_bits = |{ i_instruction[31:11], i_instruction[5:0] };

    always @(posedge clk or negedge i_reset) begin
        if (!i_reset) begin
            o_reg_DA         <= 32'b0;
            o_reg_DB         <= 32'b0;
            o_rd             <= 5'b0;
            o_rs             <= 5'b0;
            o_rt             <= 5'b0;
            o_opcode         <= 6'b0;
            o_shamt          <= 5'b0;
            o_func           <= 6'b0;
            o_width          <= 2'b00;
            o_immediate      <= 0;
            o_immediate_flag <= 1'b0;
        end else begin
            if (!i_step) begin
                o_reg_DA         <= ReadData1;
                o_reg_DB         <= ReadData2;
                o_rd             <= rd;
                o_rs             <= rs;
                o_rt             <= rt;
                o_opcode         <= opcode;
                o_shamt          <= i_instruction[10:6];
                o_func           <= func;
                o_immediate      <= w_immediat;
                o_branch         <= w_branch;
                o_regDst         <= w_regDst;
                o_mem2Reg        <= w_mem2Reg;
                o_memRead        <= w_memRead;
                o_memWrite       <= w_memWrite;
                o_immediate_flag <= w_immediate;
                o_regWrite       <= w_regWrite;
                o_aluSrc         <= w_aluSrc;
                o_aluOp          <= w_aluOp;
                o_width          <= w_width;
                o_sign_flag      <= w_sign_flag;

                if ((opcode == JAL_TYPE) || ((opcode == R_TYPE) && (func == JARL_TYPE))) begin
                    o_reg_DA <= i_pc;
                    o_rs     <= 5'b0;
                    o_reg_DB <= 32'd4;
                end
                if (opcode == JAL_TYPE) begin
                    o_rt <= 5'b11111;
                end

                if (i_stall) begin
                    o_branch         <= 1'b0;
                    o_regDst         <= 1'b0;
                    o_mem2Reg        <= 1'b0;
                    o_memRead        <= 1'b0;
                    o_memWrite       <= 1'b0;
                    o_immediate_flag <= 1'b0;
                    o_regWrite       <= 1'b0;
                    o_aluSrc         <= 2'b00;
                    o_aluOp          <= 2'b00;
                    o_width          <= 2'b00;
                    o_sign_flag      <= 1'b0;
                end
            end
        end
    end
endmodule
