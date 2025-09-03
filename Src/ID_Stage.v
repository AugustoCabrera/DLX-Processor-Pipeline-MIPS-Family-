module ID_Stage
#(
    parameter NB_DATA = 32,
    parameter NB_ADDR = 5
)(
    input wire                 clk              ,
    input wire                 i_reset          ,
    input wire [NB_DATA-1:0]   i_instruction    ,
    input wire [NB_DATA-1:0]   i_pc      ,
    input wire                 i_we_wb          ,
    input wire                 i_we             ,
    input wire [NB_ADDR-1:0]   i_wr_addr        ,
    input wire [NB_DATA-1:0]   i_wr_data_WB     ,
    input wire                 i_stall          ,
    input wire                 i_step           ,
                                                                
    output wire [4:0]    o_rs                    ,    
    output wire [4:0]    o_rt                    ,
    output wire [4:0]    o_rd                    ,

    output wire [NB_DATA-1:0]   o_reg_DA         ,
    output wire [NB_DATA-1:0]   o_reg_DB         ,

    output wire [NB_DATA-1:0]   o_immediate      ,
    output wire [5 :0]           o_opcode        ,
    output wire [4 :0]           o_shamt         ,
    output wire [5 :0]           o_func          ,
    output reg [31:0]           o_addr2jump     ,
    output reg [1: 0]           o_jump_cases    , //! 00-> no JUMP | 01 -> BRANHC! | 10 -> jump & lINK
    //ctrl unit                                                         
    output reg                  o_jump          , 
    output wire                  o_branch        , 
    output wire                  o_regDst        , 
    output wire                  o_mem2Reg       , 
    output wire                  o_memRead       , 
    output wire                  o_memWrite      , 
    output wire                  o_immediate_flag, 
    output wire                  o_sign_flag     ,
    output wire                  o_regWrite      ,
    output wire [1:0]            o_aluSrc        ,
    output wire [1:0]            o_width         ,
    output wire [1:0]            o_aluOp         ,
    output wire                 o_stop

);
    localparam HALT = 32'hFFFFFFFF;            // last instruction of the program!!!

    wire [NB_DATA-1:0] ReadData1, ReadData2 ;  // VALORES LEIDOS DE LA "MEMORIA DE REGISTROS"

    
    localparam [5:0]                                                            
                    JR_TYPE     = 6'b001000     ,
                    JARL_TYPE   = 6'b001001     ,
                    R_TYPE      = 6'b000000     ,
                    BEQ_TYPE    = 6'b000100     ,
                    J_TYPE      = 6'b000010     ,
                    JAL_TYPE    = 6'b000011     ,
                    BNE_TYPE    = 6'b000101     ;

    // ---- ctrl unit ----
    //reg [5:0] reg_opcode, reg_funct;
    wire w_jump, w_branch, w_regDst, w_mem2Reg, w_memRead, w_memWrite, w_immediate, w_regWrite, w_sign_flag ;
    wire [1:0] w_aluSrc, w_aluOp, w_width;
    wire [NB_DATA -1: 0] w_immediat;

    // ============================================================================
    // |   31-26   |   25-21  |   20-16  |   15-11  | 10-6     |   5-0             |
    // |  opcode   |    rs    |    rt    |    rd    | shamt    |  funct           | ← type R
    // |  [5:0]    |  [4:0]   |  [4:0]   |  [4:0]   | [4:0]    |  [5:0]           |
    // ============================================================================
    // |  opcode   |    rs    |    rt    |           immediate / imm           | ← type I
    // |  [5:0]    |  [4:0]   |  [4:0]   |                 [15:0]                 |
    // ============================================================================
    // |  opcode   |                   jump address (target)                      | ← type J
    // |  [5:0]    |                         [25:0]                               |
    // ============================================================================

    
    wire [4 :0] rs, rt, rd          ;
    wire [5:0] opcode               ;
    wire [15:0] imm                 ;
    wire [5:0] func                 ;

    assign opcode = i_instruction[31:26]            ;
    assign imm    = i_instruction[15:0]             ;
    assign func   = i_instruction[5:0]              ;
    assign rs     = i_instruction[25:21]            ;
    assign rt     = i_instruction[20:16]            ;
    assign rd     = i_instruction[15:11]            ;

    //! registers file
    Registers #()                               
    regist(                               
        .clk        (clk        )               ,
        .i_reset    (i_reset    )               ,
        .i_we       (i_we       )               , 
        .i_wr_addr  (i_wr_addr  )               , 
        .i_wr_data  (i_wr_data_WB)              ,
        .i_read_reg1 (rs)                       ,
        .i_read_reg2 (rt)                       ,
        .o_ReadData1 (ReadData1)                ,   
        .o_ReadData2 (ReadData2)                                                           
    );                                                          

    //! control unit
    Control #()                                                            
    ctrl                                                           
    (                                                           
        .clk        (clk        )               ,
        .i_reset    (i_reset    )               ,
        .i_opcode   (opcode     )               ,
        .i_funct    (func       )               ,

        .o_jump     (w_jump     )               ,
        .o_aluSrc   (w_aluSrc   )               ,
        .o_aluOp    (w_aluOp    )               ,
        .o_branch   (w_branch   )               ,
        .o_regDst   (w_regDst   )               ,
        .o_mem2Reg  (w_mem2Reg  )               ,
        .o_regWrite (w_regWrite )               ,
        .o_memRead  (w_memRead  )               ,
        .o_memWrite (w_memWrite )               ,
        .o_width    (w_width    )               ,
        .o_sign_flag(w_sign_flag)               ,
        .o_immediate(w_immediate)
    );

    //! extends sign for immediate|
    SignExtension #()
    signExt
    (
        .i_immediate_flag   (w_immediate)       ,
        .i_immediate_value  (imm)    ,
        .o_data             (w_immediat)
    );


    //! jumps control
    always @(*) begin 

        o_jump       = 1'b0         ;   // does not jump
        o_jump_cases = 2'b00        ;   // does not jump
        o_addr2jump  = 0            ;   // does not jump
       
       
      if (w_jump || w_branch) begin
    // Execute only when a jump or branch opcode is detected
    case (opcode)

        R_TYPE: begin
            // R-type instruction: could be JR or JALR
            o_jump      = 1'b1;
            o_addr2jump = ReadData1; // Target address is the value in register rs
                  if (func == JARL_TYPE)
                      o_jump_cases = 2'b10; // Indicates a JALR case
            end

        BEQ_TYPE: begin
            // Branch if equal (BEQ)
            o_jump_cases = 2'b01; // BRANCH!!!

            if (ReadData1 == ReadData2) begin
                o_jump      = 1'b1;
                o_addr2jump = i_pc + (w_immediat << 2) + 4; // Calculated target address , immediate × 4 = w_immediat << 2
            end
        end

        BNE_TYPE: begin
            // Branch if not equal (BNE)
            o_jump_cases = 2'b01; // BRANCH!!!

            if (ReadData1 != ReadData2) begin
                o_jump      = 1'b1;
                o_addr2jump = i_pc + (w_immediat << 2) + 4; // Calculated target address
            end
        end

        JAL_TYPE: begin
            // Jump and Link: save return address and jump
            o_jump       = 1'b1;
            o_jump_cases = 2'b10; // JUMP & link!!!
            o_addr2jump  = {i_pc[NB_DATA-1:NB_DATA-4], i_instruction[25:0], 2'b00}; // Absolute jump address
        end

        J_TYPE: begin
            // Unconditional jump (J)
            o_jump      = 1'b1;
            o_addr2jump = {i_pc[NB_DATA-1:NB_DATA-4], i_instruction[25:0], 2'b00}; // Absolute jump address
        end

        endcase
    end
    end 

    IDEX idex_sreg (
    .clk(clk),
    .i_reset(i_reset),
    .i_step(i_step),
    .i_stall(i_stall),
    .ReadData1(ReadData1),
    .ReadData2(ReadData2),
    .rd(rd),
    .rs(rs),
    .rt(rt),
    .opcode(opcode),
    .func(func),
    .w_immediat(w_immediat),
    .w_branch(w_branch),
    .w_regDst(w_regDst),
    .w_mem2Reg(w_mem2Reg),
    .w_memRead(w_memRead),
    .w_memWrite(w_memWrite),
    .w_immediate(w_immediate),
    .w_regWrite(w_regWrite),
    .w_aluSrc(w_aluSrc),
    .w_aluOp(w_aluOp),
    .w_width(w_width),
    .w_sign_flag(w_sign_flag),
    .i_pc(i_pc),
    .i_instruction(i_instruction),
    .o_reg_DA(o_reg_DA),
    .o_reg_DB(o_reg_DB),
    .o_rd(o_rd),
    .o_rs(o_rs),
    .o_rt(o_rt),
    .o_opcode(o_opcode),
    .o_shamt(o_shamt),
    .o_func(o_func),
    .o_immediate(o_immediate),
    .o_branch(o_branch),
    .o_regDst(o_regDst),
    .o_mem2Reg(o_mem2Reg),
    .o_memRead(o_memRead),
    .o_memWrite(o_memWrite),
    .o_immediate_flag(o_immediate_flag),
    .o_regWrite(o_regWrite),
    .o_aluSrc(o_aluSrc),
    .o_aluOp(o_aluOp),
    .o_width(o_width),
    .o_sign_flag(o_sign_flag)
);



    assign o_stop = (i_instruction == HALT )? 1'b1: 1'b0;


endmodule
