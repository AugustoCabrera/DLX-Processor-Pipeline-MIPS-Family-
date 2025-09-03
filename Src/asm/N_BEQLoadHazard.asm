ADDI R1,R0,4       
ADDI R2,R0,10
SW R2,20(R1)        
SW R2,16(R1)         
LW R3,20(R1)        
LW R4,16(R1)        
BEQ R3,R4,salto
NOP
ADDI R11,R0,24      
ADDI R13,R0,24    
ADDI R15,R0,24     
ADDI R17,R0,24      
salto:
ADDI R8,R0,8      
ADDI R10,R0,10   
ADDI R12,R0,12    
ADDI R14,R0,14    
HALT               