module uart 
 #(
    parameter NB_DATA = 32,       // Number of data bits
    parameter NB_STOP = 16,       // Number of stop bits
    parameter BAUD_RATE    = 19200,       // Baud rate
    parameter CLK_FREQ     = 45_000_000,  // Clock frequency
    parameter OVERSAMPLING = 16           // Oversampling factor
)(
    input  wire clk,              // Clock signal
    input  wire i_reset_n,          // Active-low reset signal
    input  wire i_rx,             // Serial data input (reception)
    input  [7:0] i_debug2Tx,      // Interface data for transmission
    input        tx_start,        // Transmission start signal
    output wire o_tx,             // Serial data output (transmission)
    output wire o_txDone,         // Transmission done indicator
    output wire o_rxdone,         // Reception done indicator
    output [7:0] o_Rx2debug       // Received data for the interface
);
 
// Baud rate generator instance
baudrate_generator #(
        .BAUD_RATE     (BAUD_RATE),    // Configured baud rate
        .CLK_FREQ      (CLK_FREQ),     // Clock frequency
        .OVERSAMPLING  (OVERSAMPLING)  // Oversampling factor
    ) baudrate_generator_inst (
        .clk      (clk),      // Clock signal connection
        .i_reset  (i_reset_n),  // Reset signal
        .o_tick   (tick)      // Tick signal for synchronization
    );

// UART receiver module instance
uart_rx #(
        .NB_DATA (NB_DATA),   // Number of data bits
        .NB_STOP (NB_STOP)    // Number of stop bits
    ) uart_rx_inst (
        .clk       (clk),         // Clock
        .i_reset   (i_reset_n),     // Active-low reset
        .i_tick    (tick),        // Synchronization tick signal
        .i_data    (i_rx),        // Serial input data
        .o_data    (o_Rx2debug),  // Output received data
        .o_rxdone  (o_rxdone)     // Signal indicating successful data reception
    );

// UART transmitter module instance
uart_tx #(
        .NB_DATA (NB_DATA),   // Number of data bits
        .NB_STOP (NB_STOP)    // Number of stop bits
    ) uart_tx_inst (
        .clk        (clk),          // Clock
        .i_reset    (i_reset_n),      // Active-low reset
        .i_tick     (tick),         // Synchronization tick signal
        .i_start_tx (tx_start),     // Signal to start transmission
        .i_data     (i_debug2Tx),   // Input data to be transmitted
        .o_txdone   (o_txDone),     // Signal indicating transmission is complete
        .o_data     (o_tx)          // Transmitted serial output data
    );
    
endmodule