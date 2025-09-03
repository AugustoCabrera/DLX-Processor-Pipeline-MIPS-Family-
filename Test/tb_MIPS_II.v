`timescale 1ns / 1ps

module tb_MIPS_II;

// Entradas del sistema
reg ClockIn;
reg Reset;

// Instancia del módulo principal MIPS
MIPS uut (
    .ClockIn(ClockIn),
    .Reset(Reset)
);


// Generador de reloj
initial begin
    ClockIn = 0;
    forever #5 ClockIn = ~ClockIn; // Periodo de reloj: 10 ns
end

// Proceso de pruebas
initial begin
    // Inicialización
    Reset = 1;
    #15 Reset = 0;

    #50;
    $stop;
end

endmodule


