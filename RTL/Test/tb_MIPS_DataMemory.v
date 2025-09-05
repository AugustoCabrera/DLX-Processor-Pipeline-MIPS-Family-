`timescale 1ns / 1ps

module tb_MIPS_DataMemory;

// Entradas del sistema
reg ClockIn;
reg Reset;

// Salidas para monitoreo
wire MEM_MemWrite;
wire MEM_MemRead;
wire ID_RegWrite ;
wire [31:0] MEM_MemReadData, WB_MemToReg;
wire [31:0] MEM_Address,MEM_WriteData;
wire [3:0] ByteSig;
wire [31:0] RegRTData, ID_WriteRegister;
wire [31:0] ID_WriteData;


// Instancia del módulo principal MIPS
MIPS uut (
    .ClockIn(ClockIn),
    .Reset(Reset)
);

// Rutas para acceder a las señales de la etapa MEM
assign MEM_MemWrite = uut.MEM_Stage.MemWrite;
assign ByteSig = uut.MEM_Stage.ByteSig;
assign ID_RegWrite  = uut.ID_Stage.Registers.RegWrite;



assign MEM_MemRead = uut.MEM_Stage.MemRead;
assign MEM_MemReadData = uut.MEM_Stage.MemReadData;
assign MEM_Address = uut.MEM_Stage.ALUResult;
assign MEM_WriteData = uut.MEM_Stage.RegRTData;

assign WB_MemToReg = uut.WB_Stage.MemToReg_Out;
assign ID_WriteRegister = uut.ID_Stage.Registers.WriteRegister;
assign ID_WriteData =  uut.ID_Stage.Registers.WriteData;



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

    // Esperar sincronización inicial
    #20;

    // Monitoreo de la etapa MEM
    $display("Iniciando pruebas en la etapa MEM");

    // Monitorear escritura en memoria
    wait(MEM_MemWrite);
   // #1 $display("[Escritura] MEM_MemWrite = %b, ALUResult = %h, RegRTData = %h", MEM_MemWrite, Address, RegRTData);

    // Monitorear lectura de memoria
    wait(MEM_MemRead);
   // #1 $display("[Lectura] MemRead = %b, ALUResult = %h, MemReadData = %h", MemRead, Address, MemReadData);

    // Monitorear ByteSig
    #20;
    //$display("[ByteSig] ByteSig = %h", ByteSig);

    // Finalizar la simulación
    #50;
    $stop;
end

endmodule
