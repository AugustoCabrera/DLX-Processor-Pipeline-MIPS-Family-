/*
    UART data reception process
    Assuming a total of N data bits and M stop bits:

    1) Wait until the input signal goes low, 
       indicating the start bit. Start tick counter. ---> IDLE

    2) When the counter reaches 7, the input signal will be 
       at the middle of the start bit. Reset the counter. ---> START
    
    3) When it reaches 15, the input signal will have advanced 
       one bit and be at the middle of the first data bit. 
       Capture and store this bit in a shift register. Reset counter. ---> RECEIVE
    
    4) Repeat step 3 a total of N-1 times to capture the remaining data bits.
    
    5) If a parity bit is used, repeat step 3 one more time.
    
    6) Repeat step 3 a total of M times to process the stop bits. ---> STOP
*/

module uart_rx
#(
    parameter NB_DATA  = 8,  // Number of data bits
    parameter NB_STOP  = 16  // Number of stop bits
)(
    input   wire                    clk,        // Clock signal
    input   wire                    i_reset,    // Active-low reset
    input   wire                    i_tick,     // Synchronization tick
    input   wire                    i_data,     // Serial data input
    output  wire [NB_DATA - 1 : 0]  o_data,     // Received data
    output  wire                    o_rxdone    // Reception complete signal
);

    reg [3:0]   tick_counter;       // Tick counter
    reg [3:0]   next_tick_counter;  // Next tick counter value
    
    reg [3:0]   state, next_state;  // Current and next state

    reg [3:0]   recBits;            // Received bits counter
    reg [3:0]   next_recBits;

    reg [NB_DATA-1:0] recByte;       // Register to store received data
    reg [NB_DATA-1:0] next_recByte;

    reg          done_bit, next_done_bit; // Reception complete signal

    // State definitions
    localparam [3:0] 
                    IDLE    = 4'b0001, // Waiting for start bit
                    START   = 4'b0010, // Start bit synchronization
                    RECEIVE = 4'b0100, // Data bit reception
                    STOP    = 4'b1000; // Stop bit reception
 
    // State and data register
    always @(posedge clk or negedge i_reset) begin
        if(!i_reset) begin
            state         <= IDLE;
            tick_counter  <= 0;
            recBits       <= 0;
            recByte       <= 8'b00000000;
            done_bit      <= 0;
        end else begin              
            state         <= next_state;
            tick_counter  <= next_tick_counter;
            recBits       <= next_recBits;
            recByte       <= next_recByte;
            done_bit      <= next_done_bit;
        end
    end

    // Finite State Machine
    always @(*) begin
        next_state         = state;
        next_tick_counter  = tick_counter;
        next_recBits       = recBits;
        next_recByte       = recByte;
        next_done_bit      = done_bit; 

        case (state) 
            IDLE: begin
                next_done_bit = 0; 
                if(!i_data) begin  // Start bit detection
                    next_state        = START;
                    next_tick_counter = 0;
                end
            end
            START: begin
                if(i_tick) begin
                    if(tick_counter == 7) begin  // Synchronize to middle of start bit
                        next_state        = RECEIVE;
                        next_tick_counter = 0;
                        next_recBits      = 0;
                    end else begin 
                        next_tick_counter = tick_counter + 1;
                    end
                end
            end
            RECEIVE: begin
                if(i_tick) begin
                    if(tick_counter == 15) begin  // Sample in the middle of the bit
                        next_tick_counter = 0;
                        next_recByte = {i_data, recByte[NB_DATA-1:1]}; // Shift register
                        if(recBits == (NB_DATA-1)) begin 
                            next_state = STOP; // Go to STOP state after all bits are received
                        end else begin 
                            next_recBits = recBits + 1;
                        end
                    end else begin 
                        next_tick_counter = tick_counter + 1;
                    end
                end
            end
            STOP: begin
                if(i_tick) begin
                    if(tick_counter == (NB_STOP-1)) begin  // End of frame
                        next_state = IDLE;
                        if(i_data) next_done_bit = 1;  // Data correctly received
                    end else begin
                        next_tick_counter = tick_counter + 1;
                    end
                end
            end
            default: begin 
                next_state = IDLE;
            end
        endcase
    end

    assign o_data   = recByte;   // Output received data
    assign o_rxdone = done_bit;  // Reception complete indicator
    
endmodule
