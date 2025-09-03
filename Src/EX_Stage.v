module EX_Stage
#(
    parameter NB_DATA = 32
)
(
    input wire                  clk                             ,
    input wire                  i_reset                         ,
    input wire                  i_step                          ,
    input wire [4:0]            i_rt                            ,
    input wire [4:0]            i_rd                            ,
    input wire [NB_DATA-1:0]    i_reg_DA                        ,
    input wire [NB_DATA-1:0]    i_reg_DB                        ,
    input wire [NB_DATA-1:0]    i_immediate                     ,
    input wire [5 :0]           i_opcode                        ,
    input wire [4 :0]           i_shamt                         ,
    input wire [5 :0]           i_func                          ,
    //ctrl unit
    input wire                  i_regDst                        , 
    input wire                  i_mem2reg                       , 
    input wire                  i_memRead                       , 
    input wire                  i_memWrite                      , 
    input wire                  i_immediate_flag                , 
    input wire                  i_regWrite                      ,
    input wire [1:0]            i_aluOP                         ,
    input wire [1:0]            i_width                         ,
    input wire                  i_sign_flag                     ,
    //fwd unit
    input wire [1:0]            i_fw_a                          ,
    input wire [1:0]            i_fw_b                          ,
    input wire [NB_DATA-1:0]    i_output_MEMWB                  , //! result wb stage
    input wire [NB_DATA-1:0]    i_output_EXMEM                  , //! o_result 
    
    // ctrl signals
    output wire                  o_mem2reg                       ,
    output wire                  o_memWrite                      ,
    output wire                  o_regWrite                      ,
    //output wire                  o_jump                          ,

    output wire                  o_sign_flag                     ,
    output wire [1:0]            o_width                         ,
    output wire [4:0]            o_write_reg                     , //! EX/MEM.RegisterRd for control unit
    output wire [NB_DATA-1:0]    o_data4Mem                      ,
    output wire [NB_DATA-1:0]    o_result                        

);
    localparam [5:0]
                    OP_ADD  = 6'b100000                             ,
                    OP_IDLE= 6'b111111                             ;

    localparam [2:1]
                ADDI    = 3'b000                                ,
                ANDI    = 3'b100                                ,
                ORI     = 3'b101                                ,
                XORI    = 3'b110                                ,
                SLTI    = 3'b010                                ,
                LUI     = 3'b111                                ;

    localparam [5:0] 
                JARL_TYPE   = 6'b001001                         ,
                R_TYPE_OP   = 6'b000000                         ,
                JAL_TYPE    = 6'b000011                         ;

    localparam [1:0]
                    LOAD_STORE = 2'b00                           ,
                    BRANCH     = 2'b01                           ,
                    R_TYPE     = 2'b10                           ,
                    I_TYPE     = 2'b11                           ;

    reg  [5:0]           opcode                                  ;
    reg  signed [NB_DATA-1:0]   alu_data_A, alu_data_B, data4Mem ; //data4Mem_aux
    reg  [1:0]           aluOP                                   ;
    wire [NB_DATA-1:0]   alu_result                              ;

    //! state machine for alu
    always @(*) begin

         case (i_aluOP)
            LOAD_STORE: opcode = OP_ADD; // load - store - jalr - jal type
            BRANCH:     opcode = OP_IDLE;
            R_TYPE:     opcode = i_func;
            I_TYPE:     opcode = i_opcode;
            default:    opcode = 6'b0;
        endcase
    end

    //! mux to determine dato A.
    //!  For JAL or  JARL type there is no forwarding
    always @(*) begin
       
        case (i_fw_a)
            2'b00: alu_data_A = i_reg_DA;       // datoA = reg[rs]
            2'b10: alu_data_A = i_output_MEMWB; // datoA = datoB
            2'b11: alu_data_A = i_output_EXMEM; // datoA = datoB
            default: alu_data_A = 8'b0;         // nop
        endcase

        if((i_opcode == JAL_TYPE) || ((i_opcode== R_TYPE_OP) && (i_func == JARL_TYPE))) begin
            alu_data_A = i_reg_DA;
        end
    end


    //! mux to determine datoB. For JAL or JARL type there is no forwarding. 
    //! For immediate ops datoB = immediate value
    always @(*) begin

        case (i_fw_b)
            2'b00: alu_data_B = i_reg_DB;       // datoB = reg[rt]
            2'b10: alu_data_B = i_output_MEMWB; // datoB = datoB
            2'b11: alu_data_B = i_output_EXMEM; // datoB = datoB
            default: alu_data_B = 8'b0;         // nop
        endcase

        data4Mem = alu_data_B;

        if((i_opcode == JAL_TYPE) || ((i_opcode== R_TYPE_OP) && (i_func == JARL_TYPE))) begin
            alu_data_B = i_reg_DB;
        end

        if(i_immediate_flag) alu_data_B = i_immediate            ;

    end
    
   
    EXMEM #(
        .NB_DATA(NB_DATA),
        .NB_REG()
    ) exmem_sreg (
        .clk         (clk),
        .i_reset     (i_reset),
        .i_step      (i_step),

        .i_mem2reg   (i_mem2reg),
        .i_memWrite  (i_memWrite),
        .i_regWrite  (i_regWrite),
        .i_width     (i_width),
        .i_sign_flag (i_sign_flag),
        .i_result    (alu_result),
        .i_data4Mem  (data4Mem),     // para SW: este dato se va a la MEM

        .i_regDst    (i_regDst),
        .i_rt        (i_rt),
        .i_rd        (i_rd),

        .o_mem2reg   (o_mem2reg),
        .o_memWrite  (o_memWrite),
        .o_regWrite  (o_regWrite),
        .o_result    (o_result),
        .o_data4Mem  (o_data4Mem),
        .o_write_reg (o_write_reg),
        .o_width     (o_width),
        .o_sign_flag (o_sign_flag)
    );

    //! alu instance
    ALU #(
        .NB_DATA    (NB_DATA),
        .NB_OP      (6)
    ) alu1
    (
        .i_op       (opcode),
        .i_data_A    (alu_data_A),
        .i_data_B    (alu_data_B),
        .i_shamt    (i_shamt),
        .o_resultALU(alu_result)
    );


endmodule
