`timescale 1ns / 1ps

// FUNCIONA!!!

// Testbench para verificar el funcionamiento del módulo ProgramCounter
module tb_ProgramCounter();

    // Entradas del módulo
    reg [31:0] PC_In;          // Dirección de entrada al contador de programa
    reg Reset;                 // Señal de reinicio
    reg Clock;                 // Señal de reloj
    reg Enable;                // Señal de habilitación

    // Salida del módulo
    wire [31:0] PCResult;      // Valor actual del contador de programa

    // Instancia del módulo ProgramCounter
    PC u0(
        .PC_In(PC_In), 
        .PCResult(PCResult), 
        .Enable(Enable),
        .Reset(Reset), 
        .Clock(Clock)
    );

    // Generación de la señal de reloj
    // El reloj alterna entre 0 y 1 cada 100 unidades de tiempo
    initial begin
        Clock <= 1'b0;              // Inicializa el reloj en bajo
        forever #100 Clock <= ~Clock; // Alterna el estado del reloj cada 100 unidades de tiempo
    end

    // Proceso para aplicar estímulos al módulo
    initial begin
        // Inicialización y reinicio
        PC_In <= 32'd0;             // Inicializa la entrada en 0
        Reset <= 1'b1;              // Activa el reinicio
        Enable <= 1'b0;             // Inicializa Enable en bajo
        #200;                       // Espera 200 unidades de tiempo
        Reset <= 1'b0;              // Desactiva el reinicio

        // Activa Enable y aplica cambios en la dirección del contador
        Enable <= 1'b1;             // Habilita el contador
        #100 PC_In <= 32'd4;        // Cambia la dirección a 4
        @ (posedge Clock);          // Espera un flanco positivo del reloj

        #100 PC_In <= 32'd8;        // Cambia la dirección a 8
        @ (posedge Clock);          // Espera un flanco positivo del reloj

        #100 PC_In <= 32'd12;       // Cambia la dirección a 12
        @ (posedge Clock);          // Espera un flanco positivo del reloj

        #100 PC_In <= 32'd16;       // Cambia la dirección a 16
        @ (posedge Clock);          // Espera un flanco positivo del reloj

        #100 PC_In <= 32'h00000AA1; // Cambia la dirección a un valor hexadecimal arbitrario
        @ (posedge Clock);          // Espera un flanco positivo del reloj

        // Desactiva Enable y verifica que el PC no cambie
        Enable <= 1'b0;
        #100 PC_In <= 32'd20;       // Cambia la dirección a 20 pero no se actualiza porque Enable está desactivado
        @ (posedge Clock);

        // Finaliza la simulación
        #100 $finish;               // Detiene la simulación después de completar los estímulos
    end

    // Monitoreo de señales
    initial begin
        $monitor("Time: %0t | Reset: %b | Enable: %b | PC_In: %h | PCResult: %h", $time, Reset, Enable, PC_In, PCResult);
    end
endmodule
