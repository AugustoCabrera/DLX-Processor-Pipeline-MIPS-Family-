module top (
    input   wire clk_100MHz ,
    input   wire i_rst_n    , 
    input   wire i_rx       ,
    output  wire o_tx       ,
    output  [15:0] o_PC_IF  
);
    localparam  NB_DATA_32      = 32         ;
    localparam  NB_ADDR         = 5          ;
    localparam  NB_DATA_8       = 8          ;
    localparam  NB_STOP         = 16         ;
    localparam  NB_6            = 6          ;
    localparam  NB_5            = 5          ;
    localparam  NB_16           = 16         ;
    localparam  NB_STATES       = 4          ;
    localparam  NB_ID_EX        = 144        ;              
    localparam  NB_EX_MEM       = 32         ;              
    localparam  NB_MEM_WB       = 48         ;              
    localparam  NB_WB_ID        = 40         ;              
    localparam  NB_CONTROL      = 24         ;       
    localparam  BAUD_RATE       = 19200      ;
    localparam  CLK_FREQ        = 45_000_000 ; 
    localparam  OVERSAMPLING    = 16         ; 

    wire clk_45MHz;
    wire clk;
    wire tick;  //! Tick signal for the UART
    wire [NB_DATA_8-1:0] data_Rx2Interface;
    wire rxDone;
    wire [NB_DATA_8-1:0] data_Interface2Tx;
    wire txDone;
    wire tx_start;
    wire tx;    
    wire we;
    wire [NB_DATA_32-1:0] instruction;
    wire halt;
    wire start;
    wire i_end; //! End of program — TO VERIFY HOW THE PIPELINE FINISHES

    //ID_EX
    wire [NB_DATA_32 -1 : 0] reg_DA      ; //! Register A
    wire [NB_DATA_32 -1 : 0] reg_DB      ; //! Register B
    wire [NB_6  -1 : 0]      opcode      ; //! Opcode
    wire [NB_5  -1 : 0]      rs          ; //! rs
    wire [NB_5  -1 : 0]      rt          ; //! rt
    wire [NB_5  -1 : 0]      rd          ; //! rd
    wire [NB_5  -1 : 0]      shamt       ; //! shamt
    wire [NB_6  -1 : 0]      funct       ; //! funct
    wire [NB_16 -1 : 0]      immediate   ; //! immediate
    wire [NB_DATA_32 -1 : 0] addr2jump   ; //! jump address
    wire [NB_DATA_32 -1 : 0] ALUresult   ; //! ALU result    
    wire [NB_DATA_32 -1 : 0] data2mem    ; //! Memory data
    wire [NB_DATA_8-1: 0]    dataAddr    ; //! Memory address 
    wire memWriteDebug      ;    
    wire [NB_DATA_32  -1: 0] write_dataWB2ID    ; //! Write data
    wire [NB_5   -1: 0]      reg2writeWB2ID     ; //! Register to write
    wire write_enable       ; //! Write enable              
    wire jump        ; //! Jump
    wire branch      ; //! Branch
    wire regDst      ; //! RegDst
    wire mem2Reg     ; //! MemToReg
    wire memRead     ; //! MemRead
    wire memWrite    ; //! MemWrite
    wire inmediate_flag     ; //! Immediate flag
    wire sign_flag   ; //! Sign flag
    wire regWrite    ; //! RegWrite
    wire [ 1 : 0]      aluSrc      ; //! ALU source
    wire [ 1 : 0]      width       ; //! ALU operation width
    wire [ 1 : 0]      aluOp       ; //! ALU operation    
    wire [ 1 : 0]      fwA         ; //! Forward A
    wire [ 1 : 0]      fwB         ; //! Forward B

    wire [NB_ID_EX   -1 : 0] segment_registers_ID_EX    ; 
    wire [NB_EX_MEM  -1 : 0] segment_registers_EX_MEM   ;
    wire [NB_MEM_WB  -1 : 0] segment_registers_MEM_WB   ;
    wire [NB_WB_ID   -1 : 0] segment_registers_WB_ID    ; 
    wire [NB_CONTROL -1 : 0] control_registers_ID_EX  ;

    assign clk = clk_45MHz;

    clk_wiz_0 clk_wz_inst(
        .resetn(i_rst_n),
        .clk_in1(clk_100MHz),
        .clk_out1(clk_45MHz)
    );

    wire [31:0] inst_addr_from_interface;
    debug_unit #(
        .NB_DATA(NB_DATA_8),
        .NB_STOP(NB_STOP),
        .NB_32(NB_DATA_32),
        .NB_5(NB_5),
        .NB_STATES(NB_STATES),
        .NB_ID_EX(NB_ID_EX),
        .NB_EX_MEM(NB_EX_MEM),
        .NB_MEM_WB(NB_MEM_WB),
        .NB_WB_ID(NB_WB_ID),
        .NB_CONTROL(NB_CONTROL)
    ) debug_unit_inst (
        .clk                     (clk),
        .i_rx                   (data_Rx2Interface),
        .i_rxDone               (rxDone), 
        .i_txDone               (txDone),
        .i_rst_n                (i_rst_n),
        .o_tx_start             (tx_start),
        .o_data                 (data_Interface2Tx),
        .i_end                  (i_end), 
        .o_instruction          (instruction),   
        .o_instruction_address  (inst_addr_from_interface), 
        .o_valid                (we),
        .o_step                 (halt),
        .o_start                (start),
        .i_segment_registers_ID_EX     (segment_registers_ID_EX  ), 
        .i_segment_registers_EX_MEM    (segment_registers_EX_MEM ),
        .i_segment_registers_MEM_WB    (segment_registers_MEM_WB ),
        .i_segment_registers_WB_ID     (segment_registers_WB_ID  ), 
        .i_control_registers_ID_EX   (control_registers_ID_EX)
    );

    wire aux_halt;
    assign aux_halt = halt;

    MIPS MIPS_inst (
        .clk                           (clk),
        .i_reset                       (start), // This receives the interface's `o_start` signal to assert reset
        .i_we_IF                       (we),    // This receives the interface's `o_valid` signal
        .i_instruction_data            (instruction), // Instruction from interface
        .i_step                        (aux_halt), // This receives the interface's `o_step` signal
        .i_instruction_addr            (inst_addr_from_interface),
        .o_end                         (i_end),
        .o_segment_registers_ID_EX     (segment_registers_ID_EX),
        .o_segment_registers_EX_MEM    (segment_registers_EX_MEM),
        .o_segment_registers_MEM_WB    (segment_registers_MEM_WB),
        .o_segment_registers_WB_ID     (segment_registers_WB_ID),
        .o_control_registers_ID_EX   (control_registers_ID_EX),
        .o_pcounterIF2ID_LSB         (o_PC_IF)
    );

    assign o_tx = tx;

    uart #(
        .NB_DATA(NB_DATA_8),
        .NB_STOP(NB_STOP),
        .BAUD_RATE(BAUD_RATE),
        .CLK_FREQ(CLK_FREQ),
        .OVERSAMPLING(OVERSAMPLING)
    ) uart_inst (
        .clk(clk),
        .i_reset_n(i_rst_n),
        .o_Rx2debug(data_Rx2Interface),
        .i_debug2Tx(data_Interface2Tx),
        .tx_start(tx_start),
        .o_tx(tx),
        .o_rxdone(rxDone),
        .i_rx(i_rx),
        .o_txDone(txDone)
    );
    
endmodule
