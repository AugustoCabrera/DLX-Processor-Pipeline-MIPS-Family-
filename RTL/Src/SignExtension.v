module SignExtension
#(
    parameter NB_IMM  = 16, // Number of bits in the immediate value
    parameter NB_DATA = 32  // Number of bits in the output data
)
(
    input  wire                 i_immediate_flag,   // Indicates whether the immediate is signed or unsigned
    input  wire [NB_IMM-1:0]    i_immediate_value,  // Input immediate value
    output wire [NB_DATA-1:0]   o_data              // 32-bit extended output value
);

// Sign-extension or zero-extension depending on i_immediate_flag
assign o_data = i_immediate_flag ? 
                {{16{i_immediate_value[NB_IMM-1]}}, i_immediate_value} : // Sign-extend
                {16'b0, i_immediate_value}; // Zero-extend

endmodule