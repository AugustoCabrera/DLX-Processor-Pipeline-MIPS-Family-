module MIPS
(
    input wire          clk                 ,
    input wire          i_reset             ,
    input wire          i_we_IF             ,
    input wire [31:0]   i_instruction_data  ,
    input wire          i_step              , 
    input wire [31:0]   i_instruction_addr  ,
    // IF

    output  [143:0] o_segment_registers_ID_EX,
    output  [31:0]  o_segment_registers_EX_MEM,
    output  [47:0]  o_segment_registers_MEM_WB,
    output  [39:0]  o_segment_registers_WB_ID,
    output  [23:0]  o_control_registers_ID_EX,
    output  [15:0]  o_pcounterIF2ID_LSB,

    output wire                 o_end           
);

    localparam  NB_DATA = 32, NB_ADDR = 5 ;
    wire haltIF;

    // IF 2 ID
    wire [31:0] pcounterIF2ID , instructionIF2ID , addr2jumpID2IF;
    
    // ID 2 EX
    wire stop;
     wire [4:0] rsID2EX, rtID2EX, rdID2EX;


    wire [NB_DATA-1:0]
                        datoAID2EX                          ,
                        datoBID2EX                          ,
                        immediateID2EX                      ;
    //ctrl out
    wire jumpID2EX, branchID2EX, regDstID2EX, mem2RegID2EX  , 
         memWriteID2EX, immediate_flagID2EX, sign_flagID2EX , 
         regWriteID2EX, memReadID2EX                        ;

    wire [5:0]
                opcodeID2EX                                 ,
                funcID2EX                                   ;

    wire [4:0]
                shamtID2EX                                  ;
    wire [1:0]
                aluSrcID2EX                                 , 
                widthID2EX                                  , 
                aluOpID2EX                                  ;
        
    parameter NB_FW = 2;
    wire [NB_FW-1 : 0] fwB_FU2EX, fwA_FU2EX;
    wire [1:0] aluSrcEX2MEM ,  widthEX2MEM  ;
    wire    jumpEX2MEM, branchEX2MEM, regDstEX2MEM, mem2RegEX2MEM   , 
            memWriteEX2MEM, immediate_flagEX2MEM, sign_flagEX2MEM   , 
            regWriteEX2MEM, memReadEX2MEM                           ;
    wire [4:0] write_regEX2MEM;
    wire [NB_DATA-1:0] data4MemEX2MEM, resultALUEX2MEM;
    wire [NB_DATA-1:0] reg_readMEM2WB, resultALUMEM2WB;
    wire [NB_ADDR-1:0] reg2writeMEM2WB;
    wire mem2regMEM2WB, regWriteMEM2WB;
    wire [NB_DATA-1:0] write_dataWB2ID  ;
    wire [NB_ADDR-1:0] reg2writeWB2ID   ;
    wire               regWriteWB2ID    ;

    wire stall;
    wire [4:0] rsIF2ID;
    wire [4:0] rtIF2ID;
    wire [1:0] jumpType;
    wire [31:0] inst_addr_from_interface;
    wire [4 :0] aux_rdEX;
    assign inst_addr_from_interface = i_instruction_addr;
    assign aux_rdEX = regDstID2EX ? rtID2EX : rdID2EX;
    assign o_pcounterIF2ID_LSB = pcounterIF2ID[15:0];




    wire [31:0] data2mem_wire;
    wire [7:0]  dataAddr_wire;
    wire        memWriteDebug_wire;




    Hazard Hazard_unit (
        .i_ID_EX_RegisterRt (rtID2EX),
        .i_IF_ID_RegisterRs (rsIF2ID),
        .i_IF_ID_RegisterRt (rtIF2ID),
        .i_ID_EX_MemRead    (memReadID2EX),
        .i_jumpType         (jumpType),
        .i_EX_RegisterRd    (aux_rdEX),
        .i_MEM_RegisterRd   (write_regEX2MEM),
        .i_WB_RegisterRd    (reg2writeMEM2WB),
        .i_EX_WB_Write      (regWriteID2EX), 
        .i_MEM_WB_Write     (regWriteEX2MEM ),
        .i_WB_WB_Write      (regWriteMEM2WB ),
        .o_stall            (stall)     
    );

    IF_Stage IF_inst (
        .clk            (clk),
        .i_reset        (i_reset),
        .i_jump         (jumpID2EX),
        .i_we           (i_we_IF),  
        .i_jump_address (addr2jumpID2IF),  
        .i_inst_data   (i_instruction_data ),  
        .i_instruction_addr    (inst_addr_from_interface),
        .i_halt         (haltIF),
        .i_stall        (stall), 
        .o_instruction  (instructionIF2ID),
        .o_pc      (pcounterIF2ID)
    );
    
    assign rsIF2ID = instructionIF2ID[25:21];
    assign rtIF2ID = instructionIF2ID[20:16];
    
    ID_Stage #(
        .NB_DATA        (NB_DATA),
        .NB_ADDR        (NB_ADDR)
    ) ID_inst (
        .clk                      (clk ),
        .i_reset                  (i_reset),
        .i_instruction            (instructionIF2ID ),
        .i_pc                     (pcounterIF2ID ),
        .i_we_wb                  ( ),
        .i_we                     (regWriteWB2ID ),
        .i_wr_addr                (reg2writeWB2ID),
        .i_wr_data_WB             (write_dataWB2ID),
        .i_stall                  (stall || stop),
        .i_step                   (i_step ),
        .o_rs                     (rsID2EX),
        .o_rt                     (rtID2EX),
        .o_rd                     (rdID2EX),
        .o_reg_DA                 (datoAID2EX),
        .o_reg_DB                 (datoBID2EX),
        .o_immediate              (immediateID2EX),
        .o_opcode                 (opcodeID2EX),
        .o_shamt                  (shamtID2EX),
        .o_func                   (funcID2EX ),
        .o_addr2jump              (addr2jumpID2IF),
        .o_jump_cases             (jumpType),
        .o_jump                   (jumpID2EX), 
        .o_branch                 (branchID2EX), 
        .o_regDst                 (regDstID2EX), 
        .o_mem2Reg                (mem2RegID2EX), 
        .o_memRead                (memReadID2EX), 
        .o_memWrite               (memWriteID2EX ), 
        .o_immediate_flag         (immediate_flagID2EX), 
        .o_sign_flag              (sign_flagID2EX),
        .o_regWrite               (regWriteID2EX ),
        .o_aluSrc                 (aluSrcID2EX),
        .o_width                  (widthID2EX ),
        .o_aluOp                  (aluOpID2EX ),
        .o_stop                   (stop)
    );

    EX_Stage #(
        .NB_DATA(NB_DATA)
    ) EX_inst
    (
        .clk                             (clk),
        .i_reset                         (i_reset),
        .i_step                          (i_step),
        .i_rt                            (rtID2EX),
        .i_rd                            (rdID2EX),
        .i_reg_DA                        (datoAID2EX),
        .i_reg_DB                        (datoBID2EX),
        .i_immediate                     (immediateID2EX ),
        .i_opcode                        (opcodeID2EX ),
        .i_shamt                         (shamtID2EX),
        .i_func                          (funcID2EX),
        .i_regDst                        (regDstID2EX ), 
        .i_mem2reg                       (mem2RegID2EX), 
        .i_memRead                       (memReadID2EX), 
        .i_memWrite                      (memWriteID2EX), 
        .i_immediate_flag                (immediate_flagID2EX), 
        .i_regWrite                      (regWriteID2EX),
        .i_aluOP                         (aluOpID2EX),
        .i_width                         (widthID2EX),
        .i_sign_flag                     (sign_flagID2EX ),
        .i_fw_a                          (fwA_FU2EX),
        .i_fw_b                          (fwB_FU2EX),
        .i_output_MEMWB                  (write_dataWB2ID), 
        .i_output_EXMEM                  (resultALUEX2MEM), 
        .o_mem2reg                       (mem2RegEX2MEM),
        .o_memWrite                      (memWriteEX2MEM ),
        .o_regWrite                      (regWriteEX2MEM ),
        .o_sign_flag                     (sign_flagEX2MEM),
        .o_width                         (widthEX2MEM ),
        .o_write_reg                     (write_regEX2MEM), 
        .o_data4Mem                      (data4MemEX2MEM ),
        .o_result                        (resultALUEX2MEM)
    
    );
    
    Forward #(
        .NB_ADDR(NB_ADDR),
        .NB_FW  (NB_FW)

    ) Forward_inst ( 
        .i_rs_IFID       (rsID2EX),
        .i_rt_IFID       (rtID2EX),
        .i_rd_IDEX       (write_regEX2MEM), 
        .i_rd_EX_MEMWB   (reg2writeMEM2WB), 
        .i_wr_WB         (regWriteEX2MEM),
        .i_wr_MEM        (regWriteMEM2WB),
        .o_fw_b          (fwB_FU2EX),
        .o_fw_a          (fwA_FU2EX)
    );

    MEM_Stage  #(
        .NB_DATA(),
        .NB_ADDR()
    ) MEM_inst (
        .clk                             (clk),
        .i_reset                         (i_reset),
        .i_step                          (i_step),
        .i_reg2write                     (write_regEX2MEM), //! o_write_reg from instruction_execute
        .i_result                        (resultALUEX2MEM), //! o_result from instruction_execute
        .i_width                         (widthEX2MEM), //! width
        .i_sign_flag                     (sign_flagEX2MEM), //! sign flag || 1 = signed, 0 = unsigned
        .i_mem2reg                       (mem2RegEX2MEM),
        .i_memWrite                      (memWriteEX2MEM ), //! Si 1 -> STORE || escribo en memoria
        .i_regWrite                      (regWriteEX2MEM ),
        .i_data4Mem                      (data4MemEX2MEM ), //! src data for store ops
        .o_reg_read                      (reg_readMEM2WB ), 
        .o_ALUresult                     (resultALUMEM2WB), 
        .o_reg2write                     (reg2writeMEM2WB),
        .o_mem2reg                       (mem2regMEM2WB), //! 0-> guardo el valor de leído || 1-> guardo valor de alu
        .o_regWrite                      (regWriteMEM2WB ),  
        .o_data2mem                      (data2mem_wire ),
        .o_dataAddr                      (dataAddr_wire ),
        .o_memWrite                      (memWriteDebug_wire)
    );
    
    WB_Stage #(
        .NB_DATA (NB_DATA),
        .NB_ADDR (NB_ADDR)
    ) WB_inst
    (
        .i_reg_read      (reg_readMEM2WB ),
        .i_ALUresult     (resultALUMEM2WB),
        .i_reg2write     (reg2writeMEM2WB),

        .i_mem2reg       (mem2regMEM2WB), //! 1-> guardo el valor de leído || 0-> guardo valor de alu
        .i_regWrite      (regWriteMEM2WB ), 

        .o_write_data    (write_dataWB2ID),
        .o_reg2write     (reg2writeWB2ID ), 
        .o_regWrite      (regWriteWB2ID)  
    );


    // program finishHHHHHH

    assign o_end = stop;
    assign haltIF = (i_step || stop) ? 1 : 0;


  // ID -> EX
assign o_segment_registers_ID_EX = {
    datoAID2EX         , // 32 bits
    datoBID2EX         , // 32 bits
    opcodeID2EX        , // 6 bits
    rsID2EX            , // 5 bits
    rtID2EX            , // 5 bits
    rdID2EX            , // 5 bits
    shamtID2EX         , // 5 bits
    funcID2EX          , // 6 bits
    immediateID2EX[15:0], // 16 bits
    addr2jumpID2IF       // 32 bits
};

// EX -> MEM
assign o_segment_registers_EX_MEM = {
    resultALUEX2MEM      // 32 bits
};

// MEM -> WB
assign o_segment_registers_MEM_WB = {
    data2mem_wire,  // 32 bits
    dataAddr_wire,  // 8 bits
    memWriteDebug_wire, // 1 bit
    7'b0000000
};


// WB -> ID
assign o_segment_registers_WB_ID = {
    write_dataWB2ID     , // 32 bits
    reg2writeWB2ID      , // 5 bits
    regWriteWB2ID       , // 1 bit
    2'b00                 // Padding
};

// Control signals (ID -> EX)
assign o_control_registers_ID_EX = {
    jumpID2EX           , // 1 bit
    branchID2EX         , // 1 bit
    regDstID2EX         , // 1 bit
    mem2RegID2EX        , // 1 bit
    memReadID2EX        , // 1 bit  
    memWriteID2EX       , // 1 bit
    immediate_flagID2EX , // 1 bit
    sign_flagID2EX      , // 1 bit
    regWriteID2EX       , // 1 bit
    aluSrcID2EX         , // 2 bits
    widthID2EX          , // 2 bits
    aluOpID2EX          , // 2 bits
    fwA_FU2EX           , // 2 bits
    fwB_FU2EX           , // 2 bits
    5'b00000              // Padding
};

endmodule