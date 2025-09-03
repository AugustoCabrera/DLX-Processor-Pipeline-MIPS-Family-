`timescale 1ns / 1ps

module tb_MIPS_Registers;

// Entradas del sistema
reg ClockIn;
reg Reset;


// Señales para monitorear el banco de registros
wire [31:0] ReadData1, ReadData2; // Datos leídos de los registros
wire [4:0] WriteRegister, WriteRegister_reg;         // Registro de destino para escritura
wire [31:0] WriteData;            // Datos escritos en el registro
wire RegWrite;                    // Señal de escritura habilitada

// Instancia del módulo principal MIPS
MIPS uut (
    .ClockIn(ClockIn),
    .Reset(Reset)
);

// Rutas para acceder a las señales del banco de registros dentro de ID_Stage
assign ReadData1 = uut.ID_Stage.ReadData1;
assign ReadData2 = uut.ID_Stage.ReadData2;
assign WriteRegister = uut.ID_Stage.Registers.WriteRegister;
assign WriteRegister_reg = uut.ID_Stage.Registers.WriteRegister_reg;
assign WriteData = uut.ID_Stage.Registers.WriteData;
assign RegWrite = uut.ID_Stage.Registers.RegWrite;


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

    // Simulación de instrucciones para probar el banco de registros
    #20; // Esperar sincronización del primer ciclo



    // Finalizar la simulación
    #50;
    $stop;
end

endmodule


