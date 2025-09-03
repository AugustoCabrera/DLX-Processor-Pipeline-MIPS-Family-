module ALU
#(
    parameter NB_DATA   = 32, //! BITs de datos y LEDs
    parameter NB_OP     = 6  //! BITs de operaciones
)
(
    input   wire    signed [NB_DATA-1:0]   i_data_A        , //! Dato de entrada
    input   wire    signed [NB_DATA-1:0]   i_data_B        , //! Dato de entrada
    input   wire           [NB_OP - 1:0]   i_op           , //! Operación a realizar    
    input   wire    signed [4:0]   i_shamt                , //! Shift amount
    output  wire    signed [NB_DATA-1:0]   o_resultALU     //! output  
);

    reg signed [NB_DATA-1:0] result                  ; //! Resultado de la operación
    reg        [NB_DATA-1:0] result_U                ; //! Resultado de la operación unsigned
    wire                     is_unsigned             ; //! Señal para saber si es unsigned
    wire       [NB_DATA-1:0] data_A_u = i_data_A      ; //! Dato A unsigned
    wire       [NB_DATA-1:0] data_B_u = i_data_B      ; //! Dato B unsigned
    
    localparam [NB_OP-1:0] //! Operation cases
        IDLE_OP = 6'b111111    ,  
        ADD_OP  = 6'b100000    , //! R-type add operation
        SUB_OP  = 6'b100010    , //! R-type sub operation
        SLL_OP  = 6'b000000    , //! R-type sll operation
        SRL_OP  = 6'b000010    , //! R-type srl operation
        SRA_OP  = 6'b000011    , //! R-type sra operation
        SLLV_OP = 6'b000100    , //! R-type sllv operation
        SRLV_OP = 6'b000110    , //! R-type srlv operation
        SRAV_OP = 6'b000111    , //! R-type srav operation
        ADDU_OP = 6'b100001    , //! R-type addu operation 
        SUBU_OP = 6'b100011    , //! R-type subu operation
        AND_OP  = 6'b100100    , //! R-type and operation  
        OR_OP   = 6'b100101    , //! R-type or operation
        XOR_OP  = 6'b100110    , //! R-type xor operation
        NOR_OP  = 6'b100111    , //! R-type nor operation
        SLT_OP  = 6'b101010    , //! R-type slt operation
        SLTU_OP = 6'b101011    , //! R-type sltu operation
    
        ADDI_OP  = 6'b001000   , //! I-type add operation
        ADDIU_OP = 6'b001001   , //! I-type addiu operation
        ANDI_OP  = 6'b001100   , //! I-type and operation
        ORI_OP   = 6'b001101   , //! I-type or operation
        XORI_OP  = 6'b001110   , //! I-type xor operation
        LUI_OP   = 6'b001111   , //! I-type lui operation
        SLTI_OP  = 6'b001010   , //! I-type slti operation
        SLTIU_OP = 6'b001011   ; //! I-type sltiu operation


  always @(*) begin
    result = 0;
    result_U = 0;
    case(i_op)
        ADD_OP:   result   = i_data_A + i_data_B             ; // Signed addition
        SUB_OP:   result   = i_data_A - i_data_B             ; // Signed subtraction
        SLL_OP:   result   = i_data_B << i_shamt            ; // Logical shift left by shift amount
        SRL_OP:   result   = i_data_B >> i_shamt            ; // Logical shift right by shift amount
        SRA_OP:   result   = i_data_B >>> i_shamt           ; // Arithmetic shift right by shift amount
        SLLV_OP:  result   = i_data_B << i_data_A            ; // Logical shift left by variable amount
        SRLV_OP:  result   = i_data_B >> i_data_A            ; // Logical shift right by variable amount
        SRAV_OP:  result   = i_data_B >>> i_data_A           ; // Arithmetic shift right by variable amount
        ADDU_OP:  result_U = data_A_u + data_B_u           ; // Unsigned addition
        SUBU_OP:  result_U = data_A_u - data_B_u           ; // Unsigned subtraction
        AND_OP:   result   = i_data_A & i_data_B             ; // Bitwise AND
        OR_OP:    result   = i_data_A | i_data_B             ; // Bitwise OR
        XOR_OP:   result   = i_data_A ^ i_data_B             ; // Bitwise XOR
        NOR_OP:   result   = ~(i_data_A | i_data_B)          ; // Bitwise NOR
        SLT_OP:   result   = (i_data_A < i_data_B) ? 1 : 0   ; // Set on less than (signed)
        SLTU_OP:  result_U = (data_A_u < data_B_u) ? 1 : 0 ; // Set on less than (unsigned)
        ADDI_OP:  result   = i_data_A + i_data_B             ; // Add immediate (signed)
        ADDIU_OP: result_U = data_A_u + data_B_u           ; // Add immediate (unsigned)
        ANDI_OP:  result   = i_data_A & i_data_B             ; // AND immediate
        ORI_OP:   result   = i_data_A | i_data_B             ; // OR immediate
        XORI_OP:  result   = i_data_A ^ i_data_B             ; // XOR immediate
        LUI_OP:   result   = i_data_B << 16                 ; // Load upper immediate
        SLTI_OP:  result   = (i_data_A < i_data_B) ? 1 : 0   ; // Set less than immediate (signed)
        SLTIU_OP: result_U = (data_A_u < data_B_u) ? 1 : 0 ; // Set less than immediate (unsigned)
        default: begin
            result   = result                              ; // Default: keep previous values
            result_U = result_U                            ;
        end   
    endcase
end

// Determine if the operation is unsigned
assign is_unsigned = (i_op == ADDU_OP) || (i_op == SUBU_OP) || (i_op == SLTU_OP)
                  || (i_op == SLTIU_OP) || (i_op == ADDIU_OP);

// Select the correct result based on whether the operation is unsigned
assign o_resultALU = is_unsigned ? result_U : result;


endmodule
