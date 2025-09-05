module uart_tx #(
    parameter NB_DATA = 8,  // Data width in bits
    parameter NB_STOP = 16  // Duration of stop bit
)(
    input  wire                   clk,         // System clock
    input  wire                   i_reset,     // Active-low reset
    input  wire                   i_tick,      // Clock pulse for transmission
    input  wire                   i_start_tx,  // Transmission start signal
    input  wire [NB_DATA - 1 : 0] i_data,      // Data to transmit
    output wire                   o_txdone,    // Indicates transmission is complete
    output wire                   o_data       // Serialized data output
);

    // Internal registers
    reg [3:0] tick_counter, next_tick_counter; // Tick counter for synchronization
    reg [3:0] state, next_state;               // Current and next state of FSM
    reg [2:0] txBits, next_txBits;             // Transmitted bits counter
    reg [NB_DATA-1:0] txByte, next_txByte;     // Register holding the byte to transmit
    reg done_bit, next_done_bit;               // Transmission done flag
    reg tx_reg, next_tx;                       // Output data register
    
    // FSM state definitions
    localparam [3:0] 
        IDLE     = 4'b0001, // Idle state
        START    = 4'b0010, // Sending start bit
        TRANSMIT = 4'b0100, // Transmitting data bits
        STOP     = 4'b1000; // Sending stop bit

    // Sequential logic: State update on clock edge
    always @(posedge clk) begin
        if (!i_reset) begin
            state         <= IDLE;
            tick_counter  <= 0;
            txBits        <= 0;
            txByte        <= 0;
            done_bit      <= 0;
            tx_reg        <= 1'b1; // Output stays high when idle
        end else begin  
            state         <= next_state;
            tick_counter  <= next_tick_counter;
            txBits        <= next_txBits;
            txByte        <= next_txByte;
            tx_reg        <= next_tx;
            done_bit      <= next_done_bit;
        end
    end

    // Combinational logic: Transmission control
    always @(*) begin
        next_done_bit      = 1'b0;
        next_state         = state;
        next_tick_counter  = tick_counter;
        next_txBits        = txBits;
        next_txByte        = txByte;
        next_tx            = tx_reg;
        
        case (state)
            IDLE: begin
                next_tx = 1'b1;
                if (i_start_tx) begin
                    next_state        = START;
                    next_tick_counter = 0;
                    next_txByte       = i_data; // Load data into buffer
                end
            end
            
            START: begin
                next_tx = 1'b0; // Send start bit
                if (i_tick) begin
                    if (tick_counter == (NB_STOP - 1)) begin
                        next_state        = TRANSMIT;
                        next_tick_counter = 0;
                        next_txBits       = 0;
                    end else begin
                        next_tick_counter = tick_counter + 1;
                    end
                end
            end
            
            TRANSMIT: begin
                next_tx = txByte[0]; // Send least significant bit
                if (i_tick) begin
                    if (tick_counter == (NB_STOP - 1)) begin
                        next_tick_counter = 0;
                        next_txByte       = txByte >> 1; // Shift bits right
                        if (txBits == (NB_DATA - 1)) begin
                            next_state = STOP;
                        end else begin
                            next_txBits = txBits + 1;
                        end
                    end else begin
                        next_tick_counter = tick_counter + 1;
                    end
                end
            end
            
            STOP: begin 
                next_tx = 1'b1; // Send stop bit
                if (i_tick) begin
                    if (tick_counter == (NB_STOP - 1)) begin
                        next_state    = IDLE;
                        next_done_bit = 1'b1; // Indicate transmission complete
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

    // Output assignments
    assign o_data   = tx_reg;   // Serial data output
    assign o_txdone = done_bit; // Transmission done indicator

endmodule
