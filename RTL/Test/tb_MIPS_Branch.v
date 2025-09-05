`timescale 1ns / 1ps

module tb_MIPS_Branch;

// Entradas del sistema
reg ClockIn;
reg Reset;

// Salidas para monitoreo
wire [31:0]  FORW_RegDst_MEMWB, IF_PC, IF_Instruction, IFID_Instruction, ID_ReadData1, ID_ReadData2, ID_FORWA_A, ID_FORWA_B, ID_FORWB_A, MEMWB_ALURESULT, ID_FORWB_B, ID_FORWB_SEL, ID_FORWA_SEL, EX_ALUResult, IDEX_ReadData1, IDEX_ReadData2;
wire IFID_Flush, IFID_Branch, IDEX_Branch, ID_CompareFlag;

// Instancia del módulo principal MIPS
MIPS uut (
    .ClockIn(ClockIn),
    .Reset(Reset)
);

// Rutas para acceder a las señales de la etapa MEM
assign IF_PC = uut.IF_Stage.PC.PCResult;
assign IF_Instruction = uut.IF_Stage.InstructionMemory.Instruction;
assign IFID_Instruction = uut.IFID.Out_Instruction;
assign IFID_Branch = uut.IFID.Out_Branch;
assign IDEX_ReadData1 = uut.IDEX.Out_ReadData1;
assign IDEX_ReadData2 = uut.IDEX.Out_ReadData2;
assign IDEX_Branch = uut.IDEX.Out_isBranch;


assign ID_CompareFlag = uut.ID_Stage.BranchCompare.CompareFlag;

assign ID_FORWA_A = uut.ID_Stage.ForwardMuxA_ID.inA;
assign ID_FORWA_B = uut.ID_Stage.ForwardMuxA_ID.inB;
assign ID_FORWB_B = uut.ID_Stage.ForwardMuxB_ID.inB;
assign ID_FORWB_A = uut.ID_Stage.ForwardMuxB_ID.inA;
assign ID_FORWB_SEL = uut.ID_Stage.ForwardMuxB_ID.sel;
assign ID_FORWA_SEL = uut.ID_Stage.ForwardMuxA_ID.sel;

assign ID_ReadData1 = uut.ID_Stage.ReadData1_out;
assign ID_ReadData2 = uut.ID_Stage.ReadData2_out;

assign FORW_RegDst_MEMWB = uut.Forward.RegDst_MEMWB;
assign EX_ALUResult = uut.EX_Stage.ALU.ALUResult;
assign IFID_Flush = uut.IFID.Flush;
assign MEMWB_ALURESULT = uut.MEMWB.Out_ALUResult;

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
/*
// Monitor de señales
initial begin
    $monitor("Time: %d, isBranch: %b, RegDst_MEMWB: %b, RegRS_IFID: %b, RegRT_IFID: %b", 
             $time, IDEX_Branch, FORW_RegDst_MEMWB, ID_ReadData1[4:0], ID_ReadData2[4:0]);
end */

endmodule