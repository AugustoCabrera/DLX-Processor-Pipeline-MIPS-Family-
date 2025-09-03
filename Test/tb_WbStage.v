`timescale 1ns / 1ps

module tb_WbStage();

    reg [1:0] MemToReg;
    reg [31:0] ALUResult, MemReadData, PCAdder;

    wire [31:0] MemToReg_Out;

    WB_Stage     WB_Stage(
        // --- Inputs ---
        MemToReg,       // Control Signal    
        ALUResult, MemReadData, PCAdder, 
        
        // --- Outputs ---         
        MemToReg_Out    // Write Back Data
        );


endmodule