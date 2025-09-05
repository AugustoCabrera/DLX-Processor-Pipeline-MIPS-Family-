`timescale 1ns / 1ps

//FUNCIONAA!!
/*

La inicializacion usada en begin del instructionmemory.v es la correcta!, reproducir este resultado para data y linkear el .mem desde .sim NO crearlo, linkearlo de .sim
con la configuracion planteada en instructionmemory.v se generan solos los .mem

*/



module tb_InstructionMemory();

    // Inputs
    reg [31:0] Address; // Address input to access the instruction memory

    // Outputs
    wire [31:0] Instruction; // Instruction read from the memory

    // Instantiate the InstructionMemory module
    InstructionMemory uut (
        .Address(Address),
        .Instruction(Instruction)
    );

    // Memory initialization file (update path if needed)
    initial begin
        $readmemh("Instruction_memory.mem", uut.memory); // Load memory contents for simulation
    end

    // Test procedure
    initial begin
        // Initialize Address to zero
        Address = 32'b0;
        #10;

        // Test case 1: Address 0
        Address = 32'd0;
        #10;
        $display("Address: %h, Instruction: %h", Address, Instruction);

        // Test case 2: Address 4
        Address = 32'd4;
        #10;
        $display("Address: %h, Instruction: %h", Address, Instruction);

        // Test case 3: Address 8
        Address = 32'd8;
        #10;
        $display("Address: %h, Instruction: %h", Address, Instruction);

        // Test case 4: Address 12
        Address = 32'd12;
        #10;
        $display("Address: %h, Instruction: %h", Address, Instruction);

        // Add more test cases as needed

        // End simulation
        $finish;
    end

    // Monitor changes to Address and Instruction for debugging
    initial begin
        $monitor("Time: %t | Address: %h | Instruction: %h", $time, Address, Instruction);
    end

endmodule
