module Control
#( 
    parameter NB_OP = 6
)(
    input wire [NB_OP-1:0] i_opcode       , //[31:26] instruction
    input wire [NB_OP-1:0] i_funct        , // for R-type [5:0] field

   // Outputs
    output wire         o_jump       , //! Controls whether a jump should be performed
    output wire [1:0]   o_aluSrc     , //! Selects ALU operand source (00: Register, 01: Immediate, etc.)
    output wire [1:0]   o_aluOp      , //! ALU operation (00: ADD | 01: OR | 10: SUB | 11: SLT)
    output wire         o_branch     , //! Branch instruction flag (1: Perform branch)
    output wire         o_regDst     , //! Register destination selector (1: rt, 0: rd for WB stage)
    output wire         o_mem2Reg    , //! Data source for writing back to register file (1: Memory, 0: ALU)
    output wire         o_regWrite   , //! Register file write enable (1: Write to register file)
    output wire         o_memRead    , //! Memory read enable (1: Read from memory)
    output wire         o_memWrite   , //! Memory write enable (1: Write to memory, used for store instructions)
    output wire [1:0]   o_width      , //! Memory access width (10: Word, 01: Half-word, 00: Byte)
    output wire         o_sign_flag  , //! Sign flag for memory operations (0: Signed, 1: Unsigned)
    output wire         o_immediate  //! Immediate instruction flag (0: Register-based, 1: Immediate-based)
);  
    
    localparam [5:0]
                    R_TYPE      = 6'b000000,
                    LW_TYPE     = 6'b100011,
                    SW_TYPE     = 6'b101011,
                    BEQ_TYPE    = 6'b000100,
                    ADDI_TYPE   = 6'b001000,
                    ADDIU_TYPE  = 6'b001001,
                    J_TYPE      = 6'b000010,
                    JAL_TYPE    = 6'b000011,
                    LHU_TYPE    = 6'b100101,
                    LBU_TYPE    = 6'b100100,
                    LWU_TYPE    = 6'b100111,
                    SB_TYPE     = 6'b101000,
                    SH_TYPE     = 6'b101001,
                    ORI_TYPE    = 6'b001101,
                    XORI_TYPE   = 6'b001110,
                    LUI_TYPE    = 6'b001111,
                    LB_TYPE     = 6'b100000,
                    LH_TYPE     = 6'b100001,
                    BNE_TYPE    = 6'b000101,
                    ANDI_TYPE   = 6'b001100,
                    STLI_TYPE   = 6'b001010,
                    STLIU_TYPE  = 6'b001011,
                    JR_TYPE     = 6'b001000,
                    JARL_TYPE   = 6'b001001;

    reg r_jump, r_ALUSrc, r_branch, r_regDst, r_mem2Reg, r_regWrite, r_memRead, r_memWrite, r_immediate, r_sign_flag;
    reg [1:0] r_aluOP;
    reg [1:0] r_width;

    always @(*) begin
        r_immediate = 1'b0;
        r_regDst    = 1'b0; 
        r_ALUSrc    = 1'b0; 
        r_mem2Reg   = 1'b0; 
        r_regWrite  = 1'b0;
        r_memRead   = 1'b0;
        r_memWrite  = 1'b0;
        r_branch    = 1'b0;
        r_jump      = 1'b0;
        r_aluOP     = 2'b00 ; 
        r_width     = 2'b11 ;
        r_sign_flag = 1'b0;

        case (i_opcode)

            R_TYPE: begin
                r_regDst    = 1'b0 ;
                r_ALUSrc    = 1'b0 ;
                r_mem2Reg   = 1'b0                          ;
                r_regWrite  = 1'b1 ; //always asserted except for jr type
                r_memRead   = 1'b0 ;
                r_memWrite  = 1'b0 ;
                r_branch    = 1'b0 ;
                r_jump      = 1'b0 ;
                r_aluOP     =  2'b10 ;

                if((i_funct == JARL_TYPE)) begin
                    r_aluOP = 2'b00;
                end
                if((i_funct == JR_TYPE) || (i_funct == JARL_TYPE)) r_jump = 1'b1;
                if(i_funct == JR_TYPE) begin 
                    r_regWrite = 1'b0;
                    r_mem2Reg  = 1'b1;
                end
            end
            LW_TYPE: begin
                r_regDst    = 1'b1 ;
                r_ALUSrc    = 1'b1 ;
                r_mem2Reg   = 1'b1 ;
                r_regWrite  = 1'b1 ;
                r_memRead   = 1'b1 ;
                r_memWrite  = 1'b0 ;
                r_branch    = 1'b0 ;
                r_jump      = 1'b0 ;
                r_aluOP     = 2'b00;
                r_width     = 2'b10;   // word
                r_sign_flag = 1'b0 ;   // signed
                r_immediate = 1'b1 ;
            end                                     
            SW_TYPE: begin                                      
                r_regDst    = 1'b1 ; // X: unknown o don't care
                r_ALUSrc    = 1'b1 ;
                r_mem2Reg   = 1'b0 ; // X: unknown o don't care
                r_regWrite  = 1'b0 ;
                r_memRead   = 1'b0 ;
                r_memWrite  = 1'b1 ;
                r_branch    = 1'b0 ;
                r_jump      = 1'b0 ;
                r_aluOP     = 2'b00;
                r_width     = 2'b10;   // word
                r_sign_flag = 1'b0 ;   // signed
                r_immediate = 1'b1 ;
            end                                     
            BEQ_TYPE: begin                                     
                r_regDst    = 1'b0 ; // X: unknown o don't care
                r_ALUSrc    = 1'b0 ; //--
                r_mem2Reg   = 1'b0 ; // X: unknown o don't care
                r_regWrite  = 1'b0 ;
                r_memRead   = 1'b0 ;
                r_memWrite  = 1'b0 ;
                r_branch    = 1'b1 ; //--
                r_jump      = 1'b0 ;
                r_aluOP     = 2'b01; //--
                r_immediate = 1'b1 ;
            end                                     
            BNE_TYPE: begin //                                      
                r_ALUSrc    = 1'b0 ;
                r_branch    = 1'b1 ;
                r_aluOP     = 2'b01;
                r_immediate = 1'b1 ;
            end
            ADDI_TYPE: begin
                r_regDst    = 1'b1 ;
                r_ALUSrc    = 1'b1 ;
                r_mem2Reg   = 1'b0 ;
                r_regWrite  = 1'b1 ;
                r_memRead   = 1'b0 ;
                r_memWrite  = 1'b0 ;
                r_branch    = 1'b0 ;
                r_jump      = 1'b0 ;
                r_aluOP     = 2'b11;
                r_immediate = 1'b1 ;
            end
            ORI_TYPE: begin // 
                r_regDst    = 1'b1 ;
                r_ALUSrc    = 1'b1 ;
                r_mem2Reg   = 1'b0 ;
                r_regWrite  = 1'b1 ;
                r_aluOP     = 2'b11;  // Logical OR
                r_immediate = 1'b1 ;
            end
            ANDI_TYPE: begin
                r_regDst    = 1'b1 ;
                r_ALUSrc    = 1'b1 ;
                r_mem2Reg   = 1'b0 ;
                r_regWrite  = 1'b1 ;
                r_aluOP     = 2'b11;  // Logical OR
                r_immediate = 1'b1 ;

            end
            ADDIU_TYPE: begin
                r_regDst    = 1'b1 ;
                r_ALUSrc    = 1'b1 ;
                r_mem2Reg   = 1'b0 ;
                r_regWrite  = 1'b1 ;
                r_memRead   = 1'b0 ;
                r_memWrite  = 1'b0 ;
                r_branch    = 1'b0 ;
                r_jump      = 1'b0 ;
                r_aluOP     = 2'b11;
                r_immediate = 1'b1 ;
                r_sign_flag = 1'b1 ;
            end
            STLIU_TYPE: begin
                r_regDst    = 1'b1 ;
                r_ALUSrc    = 1'b1 ;
                r_mem2Reg   = 1'b0 ;
                r_regWrite  = 1'b1 ;
                r_aluOP     = 2'b11;  // Set Less Than Immediate
                r_immediate = 1'b1 ;
                r_sign_flag = 1'b1 ;
            end
            XORI_TYPE: begin
                r_regDst    = 1'b1 ;
                r_ALUSrc    = 1'b1 ;
                r_mem2Reg   = 1'b0 ;
                r_regWrite  = 1'b1 ;
                r_aluOP     = 2'b11;  // Logical XOR
                r_immediate = 1'b1 ;
            end

            LUI_TYPE: begin 
                r_regDst    = 1'b1 ;
                r_ALUSrc    = 1'b1 ;
                r_mem2Reg   = 1'b0 ;
                r_regWrite  = 1'b1 ;
                r_immediate = 1'b1 ;  // Load Upper Immediate
                r_sign_flag = 1'b1 ;
                r_aluOP     = 2'b11;
            end

            STLI_TYPE: begin 
                r_regDst    = 1'b1 ;
                r_ALUSrc    = 1'b1 ;
                r_mem2Reg   = 1'b0 ;
                r_regWrite  = 1'b1 ;
                r_aluOP     = 2'b11;  // Set Less Than Immediate
                r_immediate = 1'b1 ;

            end
            JAL_TYPE: begin
                r_regDst    = 1'b1 ;
                r_jump      = 1'b1 ;
                r_regWrite  = 1'b1 ;
                r_aluOP     = 2'b00;
                r_regDst    = 1'b1 ;
            end

            LB_TYPE: begin
                r_regDst    = 1'b1 ; 
                r_ALUSrc    = 1'b1 ;
                r_mem2Reg   = 1'b1 ;
                r_regWrite  = 1'b1 ;
                r_memRead   = 1'b1 ;
                r_width     = 2'b00;  // Byte
                r_sign_flag = 1'b0 ;
                r_immediate = 1'b1 ;
            end

            LH_TYPE: begin
                r_regDst    = 1'b1 ;
                r_ALUSrc    = 1'b1 ;
                r_mem2Reg   = 1'b1 ;
                r_regWrite  = 1'b1 ;
                r_memRead   = 1'b1 ;
                r_width     = 2'b01;  // Half Word
                r_sign_flag = 1'b0 ;
                r_immediate = 1'b1 ;
            end

            LBU_TYPE: begin
                r_regDst    = 1'b1 ;
                r_ALUSrc    = 1'b1 ;
                r_mem2Reg   = 1'b1 ;
                r_regWrite  = 1'b1 ;
                r_memRead   = 1'b1 ;
                r_width     = 2'b00;  // Byte (Unsigned)
                r_sign_flag = 1'b1 ;
                r_immediate = 1'b1 ;
            end

            LHU_TYPE: begin
                r_regDst    = 1'b1 ;
                r_ALUSrc    = 1'b1 ;
                r_mem2Reg   = 1'b1 ;
                r_regWrite  = 1'b1 ;
                r_memRead   = 1'b1 ;
                r_width     = 2'b01;  // Half Word (Unsigned)
                r_sign_flag = 1'b1 ;
                r_immediate = 1'b1 ;
            end

            LWU_TYPE: begin
                r_regDst    = 1'b1 ;
                r_ALUSrc    = 1'b1 ;
                r_mem2Reg   = 1'b1 ;
                r_regWrite  = 1'b1 ;
                r_memRead   = 1'b1 ;
                r_width     = 2'b10;  // Word (Unsigned)
                r_sign_flag = 1'b1 ;
                r_immediate = 1'b1 ;
            end

            SB_TYPE: begin // rs para mem access - rt dirección del dato a guardar
                r_ALUSrc    = 1'b1 ;
                r_memWrite  = 1'b1 ;
                r_width     = 2'b00;  // Byte
                r_sign_flag = 1'b0 ;
                r_immediate = 1'b1 ;
            end                                             

            SH_TYPE: begin                                              
                r_ALUSrc    = 1'b1 ;
                r_memWrite  = 1'b1 ;
                r_width     = 2'b01;  // Half Word
                r_sign_flag = 1'b0 ;
                r_immediate = 1'b1 ;
            end
            J_TYPE: begin
                r_regDst    = 1'b0 ; // X: unknown o don't care
                r_ALUSrc    = 1'b0 ; // X: unknown o don't care
                r_mem2Reg   = 1'b0 ; // X: unknown o don't care
                r_regWrite  = 1'b0 ;
                r_memRead   = 1'b0 ;
                r_memWrite  = 1'b0 ;
                r_branch    = 1'b0 ;
                r_jump      = 1'b1 ;
                r_aluOP     = 2'b00; // X: unknown o don't care
            end

             // *** add this ***
            default: begin
            // cover opcodes not listed (e.g. REGIMM = 6'b000001, etc.)
            // keep defaults (no jump/branch, no mem, no writeback)
            end

        endcase
    end

    assign o_aluOp         = r_aluOP ;
    assign o_aluSrc        = r_ALUSrc;
    assign o_branch        = r_branch;
    assign o_immediate     = r_immediate ;
    assign o_jump          = r_jump;
    assign o_mem2Reg       = r_mem2Reg   ;
    assign o_memRead       = r_memRead   ;
    assign o_memWrite      = r_memWrite  ;
    assign o_regDst        = r_regDst;
    assign o_regWrite      = r_regWrite  ;
    assign o_width         = r_width ;
    assign o_sign_flag     = r_sign_flag ;
    
endmodule
