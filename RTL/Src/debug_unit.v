module debug_unit
#(
    NB_DATA   = 8                                                           , //! number bits data
    NB_STOP   = 16                                                          , //! stops at 16 count                               
    NB_32     = 32                                                          , //! parameter for 32 bits
    NB_5      = 5                                                           , //! parameter for 5 bits
    NB_STATES = 4                                                           , //! number of states
    NB_ID_EX  = 144                                                         , //! number of bits for ID_EX
    NB_EX_MEM = 32                                                          , //! number of bits for EX_MEM
    NB_MEM_WB = 48                                                          , //! number of bits for MEM_WB
    NB_WB_ID  = 40                                                          , //! number of bits for WB_ID
    NB_CONTROL = 24                                                           //! number of bits for CONTROL 

)(
    input       wire                            clk                         , //! project clock
    input       wire signed [NB_DATA - 1 : 0]   i_rx                        , //! Input from UART_RX module
    input       wire                            i_rxDone                    , //! UART_RX done bit
    input       wire                            i_txDone                    , //! UART_TX done bit
    input       wire                            i_rst_n                     , //! negative edge reset
    output      wire                            o_tx_start                  ,
    output      wire        [NB_DATA - 1 : 0]   o_data                      , //! Output for UART_TX module
    input       wire                            i_end                       , //! End of the program

    input wire [NB_ID_EX   -1 : 0] i_segment_registers_ID_EX    ,
    input wire [NB_EX_MEM  -1 : 0] i_segment_registers_EX_MEM   ,
    input wire [NB_MEM_WB  -1 : 0] i_segment_registers_MEM_WB   ,
    input wire [NB_WB_ID   -1 : 0] i_segment_registers_WB_ID    ,
    input wire [NB_CONTROL -1 : 0] i_control_registers_ID_EX  ,


   
    // Output
    output      wire        [NB_32 - 1 : 0]     o_instruction               , //! instruction received  
    output      wire        [NB_32 - 1 : 0]     o_instruction_address       , //! address where the instruction is going to be stored
    output      wire                            o_valid                     , //! enable to write
    output      wire                            o_step                      , //! Step for debug mode
    output      wire                            o_start                      //! Start program for continous mode
);

    // Estados de la máquina de estados
    localparam [NB_STATES -1 : 0] 
    STATE_IDLE            = 4'b0001, 
    STATE_LOAD_INSTR      = 4'b0010, //! Recibe la instruccion del RX de a 1 byte y cuando esta listo pasa a STOP y valid se pone en 1
    STATE_DEBUG_MODE      = 4'b0011, //! Manda señal de step y se envian todos los datos por uart en cada step
    STATE_CONTINOUS_MODE  = 4'b0100, //! Se ejecuta todo el programa y luego se envian los datos por uart
    STATE_SEND_ID_EX      = 4'b0101, //! Se envian los datos de ID_EX
    STATE_SEND_EX_MEM     = 4'b0110, //! Se envian los datos de EX_MEM
    STATE_SEND_MEM_WB     = 4'b0111, //! Se envian los datos de MEM_WB
    STATE_SEND_WB_ID      = 4'b1000, //! Se envian los datos de WB_ID
    STATE_SEND_CONTROL    = 4'b1001; //! Se envian los datos de control  

    //  para las señales de comando por UART ; CMD = COMANDO
    localparam [7:0]
    CMD_LOAD_INSTR  = 8'b00000001,
    CMD_ENTER_DEBUG = 8'b00000010,
    CONTINOUS_MODE  = 8'b00000100,
    STEP_MODE       = 8'b00001000,
    END_DEBUG_MODE  = 8'b00010000;


    localparam HALT_INSTR = 32'hffffffff;

    reg [NB_STATES -1 : 0]  state, next_state                                           ;
    reg [NB_32     -1 : 0]  done_counter,next_done_counter                              ;
    reg                     valid, next_valid                                           ;
    reg                     tx_start, next_tx_start                                     ;
    reg [NB_32 - 1 : 0]     instruction_address, next_instruction_address               ;         
    reg [NB_32 - 1 : 0]     instruction_register, next_instruction_register             ;   //! instrucción recibida  
    reg                     step, next_step                                             ;
    reg                     debug_flag, next_debug_flag                                 ;
    reg                     start, next_start                                           ; 
    reg [NB_DATA    -1 : 0] tx_data, next_tx_data                                       ; //! data to be sent 
    reg                     aux;


    always @(posedge clk) begin
        if(!i_rst_n) begin
            state <= STATE_IDLE                                                   ;
            done_counter <= 0                                               ;
            valid <= 0                                                      ;                                                    
            tx_start <= 0                                                   ;
            instruction_register <= 0                                       ;
            step <= 0                                                       ;
            debug_flag <= 0                                                 ;
            start <= 0                                                      ;

            tx_data <= 0                                                    ;
        end else begin              
            state <= next_state                                             ;
            done_counter <= next_done_counter                               ;
            valid <= next_valid                                             ;                                                 
            tx_start <= next_tx_start                                       ;
            instruction_address <= next_instruction_address                 ;  
            instruction_register <= next_instruction_register               ;
            step <= next_step                                               ;
            debug_flag <= next_debug_flag                                   ;
            start <= next_start                                             ;

            tx_data <= next_tx_data                                         ;
        end
    end

    always @(*) begin
        next_state = state                                          ;
        next_done_counter = done_counter                            ;
        next_valid = 0                                              ;
        next_tx_start = tx_start                                    ;
        next_instruction_address = instruction_address              ;
        next_instruction_register = instruction_register            ;
        next_step = step                                            ;
        next_debug_flag = debug_flag                                ;
        next_start = start                                          ; 
        next_tx_data = tx_data                                      ;

        case (state)
            STATE_IDLE: begin
                if (i_rxDone) begin 
                    case(i_rx)
                        CMD_LOAD_INSTR: next_state  = STATE_LOAD_INSTR              ;
                        CMD_ENTER_DEBUG:            next_state  = STATE_DEBUG_MODE        ; 
                        CONTINOUS_MODE:        next_state  = STATE_CONTINOUS_MODE    ; 

                        default:                next_state = STATE_IDLE               ;
                    endcase
                    
                end else begin                  
                    next_state = STATE_IDLE                                       ;
                    next_done_counter = 0                                   ;
                    next_valid = 0                                          ;
                    next_tx_start = 0                                       ; // Asegúrate de que tx_start se restablezca
                    next_instruction_register = 0                           ;
                    next_instruction_address = 0                            ;
                    next_step = 0                                           ;
                    next_debug_flag = 0                                     ;
                    next_start = 0                                          ;
                    next_tx_data = 0                                        ;
                    aux = 0;
                end
            end

            STATE_LOAD_INSTR: begin
                next_start = 1;
                if (i_rxDone) begin // Recibe la instrucción de 32 bits, un byte a la vez
                    next_done_counter = done_counter + 1;
                    next_instruction_register = {instruction_register[24:0], i_rx}; // Se van concatenando los datos
                end
                if (done_counter == 4) begin
                    if (instruction_register == HALT_INSTR) begin
                        next_state = STATE_IDLE;
                    end 
                    if(aux==0) begin
                        next_instruction_address = next_instruction_address;
                        aux = 1;
                    end else begin
                        next_instruction_address = instruction_address + 4; 
                    end 
                    next_done_counter = 0;
                    next_valid = 1; // se habilita para escribir
                end
            end

            STATE_DEBUG_MODE: begin
                next_step = 0;
                if(i_rxDone) begin
                    next_debug_flag = 1;
                    next_start = 1;
                    case(i_rx)
                        STEP_MODE: begin
                            next_step = 1;
                            next_state = STATE_SEND_ID_EX; // STATE_SEND_ID_EX
                        end
                        END_DEBUG_MODE: begin
                            next_debug_flag = 0;
                            next_state = STATE_SEND_ID_EX; 
                        end
                        default: begin
                            next_step = 0;
                        end
                    endcase
                end
            end

            STATE_CONTINOUS_MODE: begin
                next_step = 1;
                next_start = 1;
                if(i_end) begin 
                    next_state = STATE_SEND_ID_EX;
                end
            end
            
            STATE_SEND_ID_EX: begin
                next_step = 0;
                if(done_counter == 0) begin
                    next_tx_start = 1;
                    next_tx_data =  i_segment_registers_ID_EX[(NB_ID_EX) - 1 - done_counter * 8 -: 8];
                    next_done_counter = done_counter + 1;
                    next_state = STATE_SEND_ID_EX;                    
                end

                if (i_txDone) begin
                    if (done_counter == ((NB_ID_EX/8))) begin
                        next_state = STATE_SEND_EX_MEM;
                        next_done_counter = 0;
                        next_tx_start = 0;
                    end else begin
                        next_tx_start = 1;
                        next_tx_data = i_segment_registers_ID_EX[(NB_ID_EX) - 1 - done_counter * 8 -: 8];
                        next_done_counter = done_counter + 1;
                        next_state = STATE_SEND_ID_EX;                        
                    end
                end
            end
            
            STATE_SEND_EX_MEM: begin
                if(done_counter == 0)begin
                    next_done_counter = done_counter + 1;
                    next_tx_start = 1;
                    next_tx_data = i_segment_registers_EX_MEM[(NB_EX_MEM) - 1 - done_counter * 8 -: 8];
                    next_state = STATE_SEND_EX_MEM;                      
                end

                if (i_txDone) begin
                    if (done_counter == ((NB_EX_MEM/8))) begin
                        next_state = STATE_SEND_MEM_WB;
                        next_done_counter = 0;
                        next_tx_start = 0;
                    end else begin
                        next_done_counter = done_counter + 1;
                        next_tx_start = 1;
                        next_tx_data = i_segment_registers_EX_MEM[(NB_EX_MEM) - 1 - done_counter * 8 -: 8];
                        next_state = STATE_SEND_EX_MEM;                        
                    end          
                end
            end
            
            STATE_SEND_MEM_WB: begin
                if(done_counter == 0) begin
                    next_done_counter = done_counter + 1;        
                    next_tx_start = 1;
                    next_tx_data = i_segment_registers_MEM_WB[(NB_MEM_WB) - 1 - done_counter * 8 -: 8];
                    next_state = STATE_SEND_MEM_WB;                    
                end
                if (i_txDone) begin   
                    if (done_counter == ((NB_MEM_WB/8))) begin
                        next_state = STATE_SEND_WB_ID;
                        next_done_counter = 0;
                        next_tx_start = 0;
                    end else begin
                        next_done_counter = done_counter + 1;        
                        next_tx_start = 1;
                        next_tx_data = i_segment_registers_MEM_WB[(NB_MEM_WB) - 1 - done_counter * 8 -: 8];
                        next_state = STATE_SEND_MEM_WB;
                    end
                end
            end

            STATE_SEND_WB_ID: begin
                if (done_counter==0) begin
                    next_done_counter = done_counter + 1;         
                    next_tx_start = 1;
                    next_tx_data = i_segment_registers_WB_ID[(NB_WB_ID) - 1 - done_counter * 8 -: 8];
                    next_state = STATE_SEND_WB_ID;                    
                end
                if (i_txDone) begin   
                    if (done_counter == ((NB_WB_ID/8))) begin
                        next_state = STATE_SEND_CONTROL;
                        next_done_counter = 0;
                        next_tx_start = 0;
                    end else begin
                        next_done_counter = done_counter + 1;         
                        next_tx_start = 1;
                        next_tx_data = i_segment_registers_WB_ID[(NB_WB_ID) - 1 - done_counter * 8 -: 8];
                        next_state = STATE_SEND_WB_ID;
                    end
                end
            end
            
            STATE_SEND_CONTROL: begin
                if(done_counter==0) begin
                    next_tx_start = 1;
                    next_done_counter = done_counter + 1;          
                    next_tx_data = i_control_registers_ID_EX[(NB_CONTROL) - 1 - done_counter * 8 -: 8];
                    next_state = STATE_SEND_CONTROL;
                    
                end
                if (i_txDone) begin  
                    if (done_counter == ((NB_CONTROL/8))) begin
                        if (debug_flag) begin
                            next_state = STATE_DEBUG_MODE;
                        end else begin
                            next_state = STATE_IDLE;
                        end
                        next_done_counter = 0;
                        next_tx_start = 0;
                    end else begin
                        next_tx_start = 1;
                        next_done_counter = done_counter + 1;          
                        next_tx_data = i_control_registers_ID_EX[(NB_CONTROL) - 1 - done_counter * 8 -: 8];
                        next_state = STATE_SEND_CONTROL;
                    end
                end
            end
            

            default: begin
                next_state                     = next_state                     ;
                next_valid                     = next_valid                     ;
                next_done_counter              = next_done_counter              ;
                next_tx_start                  = next_tx_start                  ;
                next_instruction_address       = next_instruction_address       ;
                next_instruction_register      = next_instruction_register      ;
                next_step                      = next_step                      ;
                next_debug_flag                = next_debug_flag                ;
                next_start                     = next_start                     ;

                next_tx_data                   = next_tx_data                   ;
            end
        endcase
    end

        // assign
        assign o_instruction            = instruction_register          ; 
        assign o_instruction_address    = instruction_address           ; 
        assign o_valid                  = valid                         ; 
        assign o_tx_start               = tx_start                      ;
        assign o_data                   = tx_data                       ;
        assign o_step                   = ~step                         ;
        assign o_start                  = start                         ;

    endmodule