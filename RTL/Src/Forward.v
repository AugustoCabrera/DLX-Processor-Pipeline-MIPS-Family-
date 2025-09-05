module Forward
#(
    parameter NB_ADDR = 5,  // Number of bits for register addresses
    parameter NB_FW   = 2   // Number of bits for forwarding control signals
)
(
    // Register source addresses from IF/ID stage
    input wire [NB_ADDR-1 : 0]  i_rs_IFID,
    input wire [NB_ADDR-1 : 0]  i_rt_IFID,

    // Destination register addresses from IDEX and EX/MEMWB stages
    input wire [NB_ADDR-1 : 0]  i_rd_IDEX,
    input wire [NB_ADDR-1 : 0]  i_rd_EX_MEMWB,

    // Write enable flags from WB and MEM stages
    input wire                  i_wr_WB,     // Write-back stage write enable
    input wire                  i_wr_MEM,    // Memory stage write enable

    // Forwarding control outputs
    output reg [NB_FW  -1 : 0]  o_fw_b,      // Forwarding control for rt operand
    output reg [NB_FW  -1 : 0]  o_fw_a       // Forwarding control for rs operand
);

    // Forwarding logic block
    always @(*) begin : fwd_ctrl
        // Forwarding logic for operand A (rs)
        o_fw_a =    ((i_rd_IDEX     == i_rs_IFID) && i_wr_WB )  ? 2'b11 :  // Forward from WB stage
                    ((i_rd_EX_MEMWB == i_rs_IFID) && i_wr_MEM) ? 2'b10 :  // Forward from MEM stage
                                                                  2'b00 ;  // No forwarding

        // Forwarding logic for operand B (rt)
        o_fw_b =    ((i_rd_IDEX     == i_rt_IFID) && i_wr_WB )  ? 2'b11 :  // Forward from WB stage
                    ((i_rd_EX_MEMWB == i_rt_IFID) && i_wr_MEM) ? 2'b10 :  // Forward from MEM stage
                                                                  2'b00 ;  // No forwarding
    end

endmodule
