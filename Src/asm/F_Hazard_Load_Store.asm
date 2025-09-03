
ADDI R1,R0,2     
ADDU R2,R1,R1       
ADDI R3,R0,8      
ADDI R4,R0,6      
ADDI R5,R0,12    
ADDI R6,R0,10    
SW   R6, 14(R4)      
SW  R3, 24(R2)      
LW  R7, 16(R2)       
SW  R2, 14(R7)       
LW  R8, 16(R5)       
ADDU R1,R2,R7       
ADDU R9,R8,R1       
HALT                
