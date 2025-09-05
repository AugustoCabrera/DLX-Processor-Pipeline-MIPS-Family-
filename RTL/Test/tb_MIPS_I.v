`timescale 1ns / 1ps

module tb_MIPS_I();

    // Inputs
    reg ClockIn;
    reg Reset;

    // Outputs and monitored wires
    wire [31:0] PCAdder_ID;
    wire [31:0] Instruction_ID;
    wire [31:0] ReadData1_ID;
    wire [31:0] ReadData2_ID;
    wire [31:0] WriteRegister_ID;
    wire [31:0] WriteRegister2_ID;
    wire  FLAG;
    wire [31:0] ALUResult_MEM_ID;

    // Instantiate the MIPS module
    MIPS uut (
        .ClockIn(ClockIn),
        .Reset(Reset)
    );

    // Assign wires from the internal signals of the MIPS module
    assign PCAdder_ID = uut.PCAdder_ID;
    assign Instruction_ID = uut.Instruction_ID;
    assign ReadData1_ID = uut.ReadData1_ID;
    assign ReadData2_ID = uut.ReadData2_ID;
    assign WriteRegister_ID = uut.RegDst_MEM;
    assign WriteRegister2_ID = uut.RegDst_WB; 
    assign FLAG = uut.ControlSignal_WB[2];
    assign ALUResult_MEM_ID = uut.ALUResult_MEM;

    // Clock generation
    initial begin
        ClockIn = 0;
        forever #5 ClockIn = ~ClockIn; // 10 ns period (100 MHz)
    end

    // Testbench logic
    initial begin
        // Initialize inputs
        Reset = 1;

        // Apply reset
        #10; // Wait for 10 ns
        Reset = 0;

        // Simulation runtime
        #1000; // Run simulation for 1000 ns

        // Finish simulation
        $finish;
    end

    // Monitor key signals
    initial begin
        $monitor($time, " PCAdder_ID: %h | Instruction_ID: %h | ReadData1_ID: %h | ReadData2_ID: %h | WriteRegister_ID: %h | WriteRegister2_ID: %h | FLAG: %h | ALUResult_MEM: %h ", PCAdder_ID, Instruction_ID, ReadData1_ID, ReadData2_ID, WriteRegister_ID,WriteRegister2_ID , FLAG, ALUResult_MEM_ID );
    end

endmodule
