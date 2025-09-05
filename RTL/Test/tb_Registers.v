`timescale 1ns / 1ps

module tb_Registers;

    reg [4:0] ReadRegister1, ReadRegister2, WriteRegister;
    reg [31:0] WriteData;
    reg RegWrite, Clock;
    wire [31:0] ReadData1, ReadData2;
    wire [31:0] V0, V1;

    // Instanciar el módulo Registers
    Registers uut (
        .ReadRegister1(ReadRegister1),
        .ReadRegister2(ReadRegister2),
        .WriteRegister(WriteRegister),
        .WriteData(WriteData),
        .RegWrite(RegWrite),
        .Clock(Clock),
        .ReadData1(ReadData1),
        .ReadData2(ReadData2),
        .V0(V0),
        .V1(V1)
    );

    // Generador de reloj
    initial begin
        Clock = 0;
        forever #5 Clock = ~Clock; // Reloj con periodo de 10 ns
    end

    // Simulación
    initial begin
        // Inicialización
        RegWrite = 0;
        WriteRegister = 0;
        WriteData = 0;
        ReadRegister1 = 0;
        ReadRegister2 = 0;

        #10;

        // Escritura en el registro 5
        WriteRegister = 5;
        WriteData = 32'hDEADBEEF;
        RegWrite = 1;
        #10;  // Espera un ciclo de reloj

        // Desactiva la escritura
        RegWrite = 0;

        // Lee el registro 5
        ReadRegister1 = 5;
        #5;  // Tiempo de estabilización para la lectura
        $display("ReadData1 (Reg 5): %h", ReadData1);

        // Escritura en el registro 10
        WriteRegister = 10;
        WriteData = 32'hCAFEBABE;
        RegWrite = 1;
        #10;

        // Desactiva la escritura
        RegWrite = 0;

        // Lee el registro 10
        ReadRegister2 = 10;
        #5;
        $display("ReadData2 (Reg 10): %h", ReadData2);

        // Fin de la simulación
        $finish;
    end

endmodule
