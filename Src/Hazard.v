module Hazard (
    // Inputs
    input wire [4:0] i_ID_EX_RegisterRt , //! Destination register of the EX-stage instruction (used for load-use hazard)
    input wire [4:0] i_IF_ID_RegisterRs , //! Source register of the ID-stage instruction
    input wire [4:0] i_IF_ID_RegisterRt , //! Another source register of the ID-stage instruction
    input wire       i_ID_EX_MemRead    , //! Indicates if the EX-stage instruction is a load instruction

    input wire [1:0] i_jumpType         , //! Indicates type of jump/branch (00: none, 01: BEQ/BNE, 10: JR/JALR)

    input wire [4:0] i_EX_RegisterRd    , //! Destination register of the EX-stage instruction
    input wire [4:0] i_MEM_RegisterRd   , //! Destination register of the MEM-stage instruction
    input wire [4:0] i_WB_RegisterRd    , //! Destination register of the WB-stage instruction
    input wire       i_EX_WB_Write      , //! EX-stage writes to register
    input wire       i_MEM_WB_Write     , //! MEM-stage writes to register
    input wire       i_WB_WB_Write      , //! WB-stage writes to register

    // Output
    output reg o_stall                  // Signal to stall the pipeline
);

    // Hazard detection logic
    always @(*) begin
        o_stall = 1'b0; // Default: No stall

        // Data hazard: Load-use hazard detection
        if (i_ID_EX_MemRead && (
                (i_ID_EX_RegisterRt == i_IF_ID_RegisterRs) || // Load followed by instruction that uses the same source
                (i_ID_EX_RegisterRt == i_IF_ID_RegisterRt)
        )) begin
            o_stall = 1'b1;
        end

        // Control hazard: Branch-type instructions (e.g., BEQ, BNE)
        else if (i_jumpType == 2'b01) begin
            // Check if Rs or Rt are being written by instructions in later stages
            if ((i_IF_ID_RegisterRs == i_EX_RegisterRd  && i_EX_WB_Write ) ||
                (i_IF_ID_RegisterRs == i_MEM_RegisterRd && i_MEM_WB_Write) ||
                (i_IF_ID_RegisterRs == i_WB_RegisterRd  && i_WB_WB_Write ) ||
                (i_IF_ID_RegisterRt == i_EX_RegisterRd  && i_EX_WB_Write ) ||
                (i_IF_ID_RegisterRt == i_MEM_RegisterRd && i_MEM_WB_Write) ||
                (i_IF_ID_RegisterRt == i_WB_RegisterRd  && i_WB_WB_Write )) 
            begin
                o_stall = 1'b1;
            end

        // Control hazard: Register-indirect jump (e.g., JR, JALR)
        end else if (i_jumpType == 2'b10) begin
            // Only Rs is used
            if ((i_IF_ID_RegisterRs == i_EX_RegisterRd  && i_EX_WB_Write ) ||
                (i_IF_ID_RegisterRs == i_MEM_RegisterRd && i_MEM_WB_Write) ||
                (i_IF_ID_RegisterRs == i_WB_RegisterRd  && i_WB_WB_Write ) ||
                (i_IF_ID_RegisterRs != 0 && i_ID_EX_MemRead)               // Additional load-use hazard for Rs
            ) begin
                o_stall = 1'b1;
            end
        end

    end

endmodule
