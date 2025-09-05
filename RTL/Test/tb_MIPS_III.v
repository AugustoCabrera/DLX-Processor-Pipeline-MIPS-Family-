`timescale 1ns / 1ps

module tb_MIPS_III;

    // Entradas
    reg ClockIn;
    reg Reset;

    // Salidas
    wire [31:0] PCResult;
    wire [31:0] V0, V1;

    // Instancia del módulo bajo prueba
    MIPS uut (
        .ClockIn(ClockIn),
        .Reset(Reset)
    );

    // Generador de reloj
    initial begin
        ClockIn = 0;
        forever #5 ClockIn = ~ClockIn; // Periodo de reloj de 10ns
    end

    // Inicialización y reset
    initial begin
        $dumpfile("tb_MIPS_III.vcd");
        $dumpvars(0, tb_MIPS_III);

        Reset = 1; // Activa reset
        #10;
        Reset = 0; // Desactiva reset
    end

    // Monitoreo de los registros de interés
    initial begin
        $display("Time(ns)\tReg[0]\tReg[8]\tReg[4]\tReg[17]");
        $monitor("%t\t%h\t%h\t%h\t%h", 
                 $time,  
                 uut.ID_Stage.Registers.registers[0], 
                 uut.ID_Stage.Registers.registers[8], 
                 uut.ID_Stage.Registers.registers[4], 
                 uut.ID_Stage.Registers.registers[17]);
        #2000; // Simulación de 2000ns (200 ciclos)
        $finish;
    end

endmodule
