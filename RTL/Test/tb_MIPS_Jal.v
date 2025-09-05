`timescale 1ns / 1ps

module tb_MIPS_Jal;

// Entradas del sistema
reg ClockIn;
reg Reset;

// Salidas para monitoreo



wire [31:0]  IF_PCOut,IF_PCIn,IF_Instruction,IF_JumpAddress,IFID_Instruction,IFID_Enable,IFID_Flush,ID_JumpMux_A,ID_JumpMux_B,ID_JumpMux_sel,EX_Sel,WB_PCAdder,WB_sel;
wire RegWrite,IF_JumpFlag;



// Instancia del módulo principal MIPS
MIPS uut (
    .ClockIn(ClockIn),
    .Reset(Reset)
);

// Rutas para acceder a las señales de la etapa MEM



assign PC = uut.IF_Stage.PC.PCResult;
assign IF_Instruction = uut.IF_Stage.InstructionMemory.Instruction;
assign IFID_Instruction = uut.IFID.Out_Instruction;

assign IFID_Enable = uut.IFID.Enable;
assign IFID_Flush = uut.IFID.Flush;


assign IF_PCIn = uut.IF_Stage.PC.PC_In;
assign IF_PCOut = uut.IF_Stage.PC.PCResult;
assign IF_JumpFlag = uut.IF_Stage.JumpControl;
assign IF_JumpAddress = uut.IF_Stage.JumpAddress;


assign ID_JumpMux_A = uut.ID_Stage.JumpMux.inA;
assign ID_JumpMux_B = uut.ID_Stage.JumpMux.inB;
assign ID_JumpMux_sel = uut.ID_Stage.JumpMux.sel;

assign EX_Sel = uut.EX_Stage.RegDst;


assign WB_PCAdder = uut.WB_Stage.PCAdder;
assign WB_sel = uut.WB_Stage.MemToReg;






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
    
    #50;
    $stop;
end

endmodule
