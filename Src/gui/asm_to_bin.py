#  To execute the program, run the following command: python3 asm_to_bin.py test.asm output.bin

import logging as log
import re
import argparse

class Assembler:
    # Retorna una lista con los tokens para cada instrucción
    def tokenizer(self, asm_file):
            lines = asm_file.readlines()
            tokens = []
            self.labels = {}
            instruction_index = 0
          #  label_count = 0  # ← Cuenta cuántas etiquetas aparecieron hasta ahora

            gramatical_rules = (
                r'(?m)(\w+)\s+(-{0,1}\w+)\s*,\s*(-{0,1}\w+)\s*,\s*(-{0,1}\w+)\s*$'
                + r'|(\w+)\s+(-{0,1}\w+)\s*,\s*(-{0,1}\w+)\s*\(\s*(-{0,1}\w+)\)\s*$'
                + r'|(\w+)\s+(-{0,1}\w+)\s*,\s*(-{0,1}\w+)\s*$'
                + r'|(\w+)\s+(-{0,1}\w+)\s*$'
                + r'|(\w+)\s*$'
            )

            for line in lines:
                line = line.split('#')[0].strip()
                if not line:
                    continue

                line = line.upper()

                # Si hay etiqueta
                if ':' in line:
                    label_part, rest = line.split(':', 1)
                    label = label_part.strip()
                 #   self.labels[label] = instruction_index + label_count  # ← suma 1 por cada etiqueta previa
                    self.labels[label] = instruction_index   # ← suma 1 por cada etiqueta previa
                    #label_count += 1
                    line = rest.strip()
                    if not line:
                        continue

                # Instrucción real
                if line == 'HALT':
                    tokens.append(['HALT'])
                else:
                    token = list(filter(None, re.split(string=line, pattern=gramatical_rules)))
                    tokens.append(token)

                instruction_index += 1

            return tokens



    # Toma uno de los números de la instrucción o el número de registro y lo pasa a un string binario
    # SLL r1, 2, -3, por ejemplo acá si pedimos sa = "11101"
    def str_to_bin_str(self, str, n_bits):
        bin_str = ''

        matches = re.search(r'R{0,1}(-{0,1}\d+)', str)
        if matches == None:
            log.fatal(f'No se pudo matchear ningún valor para el str = {str}')

        num = int(matches[1])

        if num < 0:
            bin_str = format(num & 0xffffffff, '32b')
        else:
            bin_str = '{:032b}'.format(num)

        return bin_str[32-n_bits:]

    def instruction_generator(self, token):
        inst_bin = "00000000000000000000000000000000"
        i_name = token[0]
        if i_name == "SLL":
            inst_bin = self.set_rd(inst_bin, token[1])
            inst_bin = self.set_rt(inst_bin, token[2])
            inst_bin = self.set_shamt(inst_bin, token[3])
            inst_bin = self.set_func(inst_bin, "000000")
        elif i_name == "SRL":
            inst_bin = self.set_rd(inst_bin, token[1])
            inst_bin = self.set_rt(inst_bin, token[2])
            inst_bin = self.set_shamt(inst_bin, token[3])
            inst_bin = self.set_func(inst_bin, "000010")
        elif i_name == "SRA":
            inst_bin = self.set_rd(inst_bin, token[1])
            inst_bin = self.set_rt(inst_bin, token[2])
            inst_bin = self.set_shamt(inst_bin, token[3])
            inst_bin = self.set_func(inst_bin, "000011")
        elif i_name == "SLLV":
            inst_bin = self.set_rd(inst_bin, token[1])
            inst_bin = self.set_rt(inst_bin, token[2])
            inst_bin = self.set_rs(inst_bin, token[3])
            inst_bin = self.set_func(inst_bin, "000100")
        elif i_name == "SRLV":
            inst_bin = self.set_rd(inst_bin, token[1])
            inst_bin = self.set_rt(inst_bin, token[2])
            inst_bin = self.set_rs(inst_bin, token[3])
            inst_bin = self.set_func(inst_bin, "000110")
        elif i_name == "SRAV":
            inst_bin = self.set_rd(inst_bin, token[1])
            inst_bin = self.set_rt(inst_bin, token[2])
            inst_bin = self.set_rs(inst_bin, token[3])
            inst_bin = self.set_func(inst_bin, "000111")
        elif i_name == "ADDU":
            inst_bin = self.set_rd(inst_bin, token[1])
            inst_bin = self.set_rt(inst_bin, token[3])
            inst_bin = self.set_rs(inst_bin, token[2])
            inst_bin = self.set_func(inst_bin, "100001")
        elif i_name == "SUBU":
            inst_bin = self.set_rd(inst_bin, token[1])
            inst_bin = self.set_rt(inst_bin, token[3])
            inst_bin = self.set_rs(inst_bin, token[2])
            inst_bin = self.set_func(inst_bin, "100011")
        elif i_name == "AND":
            inst_bin = self.set_rd(inst_bin, token[1])
            inst_bin = self.set_rt(inst_bin, token[2])
            inst_bin = self.set_rs(inst_bin, token[3])
            inst_bin = self.set_func(inst_bin, "100100")
        elif i_name == "OR":
            inst_bin = self.set_rd(inst_bin, token[1])
            inst_bin = self.set_rt(inst_bin, token[2])
            inst_bin = self.set_rs(inst_bin, token[3])
            inst_bin = self.set_func(inst_bin, "100101")
        elif i_name == "XOR":
            inst_bin = self.set_rd(inst_bin, token[1])
            inst_bin = self.set_rt(inst_bin, token[3])
            inst_bin = self.set_rs(inst_bin, token[2])
            inst_bin = self.set_func(inst_bin, "100110")
        elif i_name == "NOR":
            inst_bin = self.set_rd(inst_bin, token[1])
            inst_bin = self.set_rt(inst_bin, token[3])
            inst_bin = self.set_rs(inst_bin, token[2])
            inst_bin = self.set_func(inst_bin, "100111")
        elif i_name == "SLT":
            inst_bin = self.set_rd(inst_bin, token[1])
            inst_bin = self.set_rt(inst_bin, token[3])
            inst_bin = self.set_rs(inst_bin, token[2])
            inst_bin = self.set_func(inst_bin, "101010")
        elif i_name == "LB":
            inst_bin = self.set_op_code(inst_bin, "100000")
            inst_bin = self.set_rt(inst_bin, token[1])
            inst_bin = self.set_offset_immed(inst_bin, token[2])
            inst_bin = self.set_rs(inst_bin, token[3])
        elif i_name == "LH":
            inst_bin = self.set_op_code(inst_bin, "100001")
            inst_bin = self.set_rt(inst_bin, token[1])
            inst_bin = self.set_offset_immed(inst_bin, token[2])
            inst_bin = self.set_rs(inst_bin, token[3])
        elif i_name == "LW":
            inst_bin = self.set_op_code(inst_bin, "100011")
            inst_bin = self.set_rt(inst_bin, token[1])
            inst_bin = self.set_offset_immed(inst_bin, token[2])
            inst_bin = self.set_rs(inst_bin, token[3])
        elif i_name == "LWU":
            inst_bin = self.set_op_code(inst_bin, "100111")
            inst_bin = self.set_rt(inst_bin, token[1])
            inst_bin = self.set_offset_immed(inst_bin, token[2])
            inst_bin = self.set_rs(inst_bin, token[3])
        elif i_name == "LHU":
            inst_bin = self.set_op_code(inst_bin, "100101")
            inst_bin = self.set_rt(inst_bin, token[1])
            inst_bin = self.set_offset_immed(inst_bin, token[2])
            inst_bin = self.set_rs(inst_bin, token[3])
        elif i_name == "LBU":
            inst_bin = self.set_op_code(inst_bin, "100100")
            inst_bin = self.set_rt(inst_bin, token[1])
            inst_bin = self.set_offset_immed(inst_bin, token[2])
            inst_bin = self.set_rs(inst_bin, token[3])
        elif i_name == "SB":
            inst_bin = self.set_op_code(inst_bin, "101000")
            inst_bin = self.set_rt(inst_bin, token[1])
            inst_bin = self.set_offset_immed(inst_bin, token[2])
            inst_bin = self.set_rs(inst_bin, token[3])
        elif i_name == "SH":
            inst_bin = self.set_op_code(inst_bin, "101001")
            inst_bin = self.set_rt(inst_bin, token[1])
            inst_bin = self.set_offset_immed(inst_bin, token[2])
            inst_bin = self.set_rs(inst_bin, token[3])
        elif i_name == "SW":
            inst_bin = self.set_op_code(inst_bin, "101011")
            inst_bin = self.set_rt(inst_bin, token[1])
            inst_bin = self.set_offset_immed(inst_bin, token[2])
            inst_bin = self.set_rs(inst_bin, token[3])

        elif i_name == "ADDI":
            inst_bin = self.set_op_code(inst_bin, "001000")
            inst_bin = self.set_rt(inst_bin, token[1])
            inst_bin = self.set_offset_immed(inst_bin, token[3])
            inst_bin = self.set_rs(inst_bin, token[2])
        elif i_name == "ANDI":
            inst_bin = self.set_op_code(inst_bin, "001100")
            inst_bin = self.set_rt(inst_bin, token[1])
            inst_bin = self.set_offset_immed(inst_bin, token[3])
            inst_bin = self.set_rs(inst_bin, token[2])
        elif i_name == "ORI":
            inst_bin = self.set_op_code(inst_bin, "001101")
            inst_bin = self.set_rt(inst_bin, token[1])
            inst_bin = self.set_offset_immed(inst_bin, token[3])
            inst_bin = self.set_rs(inst_bin, token[2])
        elif i_name == "XORI":
            inst_bin = self.set_op_code(inst_bin, "001110")
            inst_bin = self.set_rt(inst_bin, token[1])
            inst_bin = self.set_offset_immed(inst_bin, token[3])
            inst_bin = self.set_rs(inst_bin, token[2])
        elif i_name == "LUI":
            inst_bin = self.set_op_code(inst_bin, "001111")
            inst_bin = self.set_rt(inst_bin, token[1])
            inst_bin = self.set_offset_immed(inst_bin, token[2])
        elif i_name == "SLTI":
            inst_bin = self.set_op_code(inst_bin, "001010")
            inst_bin = self.set_rt(inst_bin, token[1])
            inst_bin = self.set_offset_immed(inst_bin, token[3])
            inst_bin = self.set_rs(inst_bin, token[2])
        elif i_name == "BEQ":
            inst_bin = self.set_op_code(inst_bin, "000100")
            inst_bin = self.set_rs(inst_bin, token[1])
            inst_bin = self.set_rt(inst_bin, token[2])
            label = token[3]
            if label.isdigit() or (label.startswith('-') and label[1:].isdigit()):
                inst_bin = self.set_offset_immed(inst_bin, label)
            elif label in self.labels:
                offset = self.labels[label] - 1 - (self.instruction_counter + 1)
                inst_bin = self.set_offset_immed(inst_bin, str(offset))
            else:
                log.fatal(f"Etiqueta '{label}' no encontrada para BEQ")
        elif i_name == "BNE":
            inst_bin = self.set_op_code(inst_bin, "000101")
            inst_bin = self.set_rs(inst_bin, token[1])
            inst_bin = self.set_rt(inst_bin, token[2])
            label = token[3]
            if label.isdigit() or (label.startswith('-') and label[1:].isdigit()):
                inst_bin = self.set_offset_immed(inst_bin, label)
            elif label in self.labels:
                offset = self.labels[label] - 1 - (self.instruction_counter + 1)
                inst_bin = self.set_offset_immed(inst_bin, str(offset))
            else:
                log.fatal(f"Etiqueta '{label}' no encontrada para BNE")
        elif i_name == "J":
            inst_bin = self.set_op_code(inst_bin, "000010")
            target = token[1]
            if not target.isdigit():
                if target in self.labels:
                    # suma 1 al target
                    target = str(self.labels[target] + 1)
                else:
                    log.fatal(f"Etiqueta '{target}' no encontrada")
            inst_bin = self.set_target(inst_bin, target)
        elif i_name == "JAL":
            inst_bin = self.set_op_code(inst_bin, "000011")
            target = token[1]
            if not target.isdigit():
                if target in self.labels:
                    # suma 1 al target
                    target = str(self.labels[target] + 1)
                else:
                    log.fatal(f"Etiqueta '{target}' no encontrada")
            inst_bin = self.set_target(inst_bin, target)
        elif i_name == "JR":
            print(f"DEBUG JR: token = {token}")
            inst_bin = self.set_func(inst_bin, "001000")
            inst_bin = self.set_rs(inst_bin, token[1])
        elif i_name == "JALR":
            inst_bin = self.set_op_code(inst_bin, "000000")   # tipo R
            inst_bin = self.set_func(inst_bin, "001001")       # funct = 0x09

            if len(token) > 2:
                # JALR rd, rs
                inst_bin = self.set_rd(inst_bin, token[1])     # guardar PC+8 en rd
                inst_bin = self.set_rs(inst_bin, token[2])     # saltar a dirección de rs
            else:
                # JALR rs → equivalente a JALR R31, rs
                inst_bin = self.set_rd(inst_bin, "31")
                inst_bin = self.set_rs(inst_bin, token[1])
        elif i_name == "HALT":
            inst_bin = "11111111111111111111111111111111"
        elif i_name == "NOP":
            inst_bin = inst_bin
        else:
            print(i_name)
            log.FATAL(f'Instrucción no reconocida {i_name}')

        return inst_bin

    def set_op_code(self, inst, opcode):
        return opcode + inst[6:]

    def set_rs(self, inst, rs):
        rs = self.str_to_bin_str(rs, 5)
        return inst[0:6] + rs + inst[11:]

    def set_rt(self, inst, rt):
        rt = self.str_to_bin_str(rt, 5)
        return inst[0:11] + rt + inst[16:]

    def set_rd(self, inst, rd):
        rd = self.str_to_bin_str(rd, 5)
        return inst[0:16] + rd + inst[21:]

    def set_shamt(self, inst, shamt):
        shamt = self.str_to_bin_str(shamt, 5)
        return inst[0:21] + shamt + inst[26:]

    def set_func(self, inst, aluFunc):
        return inst[0:26] + aluFunc

    def set_offset_immed(self, inst, offset):
        offset = self.str_to_bin_str(offset, 16)
        return inst[0:16] + offset

    def set_target(self, inst, target):
        target = self.str_to_bin_str(target, 26)
        return inst[0:6] + target

binary_code = ""
asm_tokens = []
asm = Assembler()
parser = argparse.ArgumentParser(description='Assembly to binary converter')
parser.add_argument('arg1', type=str, help='input file')
parser.add_argument('arg2', type=str, help='output file')
args = parser.parse_args()

try:
    asm_file = open(args.arg1, encoding='utf-8')
    asm_tokens = asm.tokenizer(asm_file)
finally:
    asm_file.close()

jump_ops = {"J", "JAL", "JR", "BEQ", "BNE", "JALR"}

asm.instruction_counter = 0  # Agregá esta línea antes del bucle

for inst in asm_tokens:
    binary_code += asm.instruction_generator(inst)
    asm.instruction_counter += 1


num_byte = []
for i in range(int(len(binary_code)/8)):
    num =   int(binary_code[i*8:(i+1)*8],2)
    num_byte.append(num)
try:
    out_file = open(args.arg2, "wb")
    out_file.write((''.join(chr(i) for i in num_byte)).encode('charmap'))
finally:
    out_file.close()