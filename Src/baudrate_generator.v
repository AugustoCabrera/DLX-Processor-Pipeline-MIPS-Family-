module baudrate_generator
#(
    parameter BAUD_RATE   = 19200,        // Tasa de baudios (bits por segundo)
    parameter CLK_FREQ    = 45_000_000,   // Frecuencia del reloj de entrada (Hz)
    parameter OVERSAMPLING = 16           // Factor de sobremuestreo
)
(
    input   wire clk,       // Señal de reloj
    input   wire i_reset,   // Señal de reset activa en bajo
    output  wire o_tick     // Pulso generado a la frecuencia deseada
);

// Cálculo del número de ciclos de reloj por tick de muestreo
localparam NC_PER_TICK = CLK_FREQ / BAUD_RATE / OVERSAMPLING;   // CLOCK /(16*19200)
localparam NB_COUNTER = 8; // Número de bits del contador
reg [NB_COUNTER:0] counter; // Registro para el contador

// Lógica secuencial del contador
always @(posedge clk or negedge i_reset) begin
    if(!i_reset) begin 
        counter <= {NB_COUNTER {1'b0}}; // Reinicia el contador en reset
    end else begin
        if(counter == NC_PER_TICK) 
            counter <= {NB_COUNTER {1'b0}}; // Reinicia el contador cuando alcanza el límite
        else                        
            counter <= counter + 1; // Incrementa el contador en cada ciclo de reloj
    end
end

// Generación del pulso o_tick cuando el contador alcanza NC_PER_TICK
assign o_tick = (counter == NC_PER_TICK);

endmodule
