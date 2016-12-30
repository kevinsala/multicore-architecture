import ctypes

class InvalidInstruction(Exception):
    def __init__(self, value):
        self.value = value

    def __str__(self):
        return self.value

class Instruction:

    def _reg_to_num(self, reg):
        if reg[0] != 'r' and reg[0] != 'R':
            raise InvalidInstruction(self.asm)
        else:
            r = int(reg[1:])
            if r < 0 or r > 31:
                raise InvalidInstruction(sel.fasm)

            return r

    def __init__(self, asm):
        self.r1 = -1
        self.r2 = -1
        self.dst = -1
        self.offset = 0
        self.offset_set = False
        self.label = ""
        self.asm = asm
        self.icode, args = self.asm.split(" ", 1)
        args = args.replace(" ","").split(",")

        if self.icode == "add" or self.icode == "sub" or self.icode == "mul":
            if len(args) != 3:
                raise InvalidInstruction(self.asm)

            self.itype = "r"
            self.dst = self._reg_to_num(args[0])
            self.r1 = self._reg_to_num(args[1])
            self.r2 = self._reg_to_num(args[2])
        elif self.icode == "ldb" or self.icode == "ldw" or self.icode == "stb" or self.icode == "stw":
            if len(args) != 2:
                raise InvalidInstruction(self.asm)

            self.itype = "m"
            self.dst = self._reg_to_num(args[0])

            # Process the memory part
            mem_offset, mem_reg = args[1].split("(")
            mem_reg = mem_reg[:-1]
            self.set_offset(int(mem_offset, 0))
            self.r1 = self._reg_to_num(mem_reg)
        elif self.icode == "mov":
            if len(args) != 2:
                raise InvalidInstruction(self.asm)

            self.itype = "m"
            self.dst = self._reg_to_num(args[0])
            self.r1 = self._reg_to_num(args[1])
            self.set_offset(0)
        elif self.icode == "beq" or self.icode == "bne":
            if len(args) != 3:
                raise InvalidInstruction(self.asm)

            self.itype = "b"
            self.r1 = self._reg_to_num(args[0])
            self.r2 = self._reg_to_num(args[1])
            self.label = args[2]
        elif self.icode == "jmp":
            if len(args) != 1:
                raise InvalidInstruction(self.asm)

            self.itype = "j"
            self.label = args[0]
        elif self.icode == "li":
            if len(args) != 2:
                raise InvalidInstruction(self.asm)

            self.itype = "i"
            self.dst = self._reg_to_num(args[0])
            self.set_offset(int(args[1], 0))
        elif self.icode == "nop":
            if len(args != 0):
                raise InvalidInstruction(self.asm)

            self.itype = "n"
        else:
            raise InvalidInstruction(self.asm)

    def set_offset(self, offset):
        self.offset_set = True
        if self.itype == "m" or self.itype == "b":
            if offset > (2**14 - 1) or offset < (-1 * (2**15)):
                raise InvalidInstruction(self.asm)
        elif self.itype == "j":
            if offset > (2**19 - 1) or offset < (-1 * (2**20)):
                raise InvalidInstruction(self.asm)

        self.offset = offset

    def is_set_offset(self):
        return self.offset_set

    def to_binary(self):
        encoded = 0
        if self.itype == "r":
            if self.icode == "add":
                eicode = 0
            elif self.icode == "sub":
                eicode = 1
            elif self.icode == "mul":
                eicode = 2
            else:
                raise

            encoded = (eicode << 25) | (self.dst << 20) | (self.r1 << 15) | (self.r2 << 10)
        elif self.itype == "m":
            if self.icode == "ldb":
                eicode = 16
            elif self.icode == "ldw":
                eicode = 17
            elif self.icode == "stb":
                eicode = 18
            elif self.icode == "stw":
                eicode = 19
            elif self.icode == "mov":
                eicode = 20
            else:
                raise

            encoded = (eicode << 25) | (self.dst << 20) | (self.r1 << 15) | (self.offset & (2**15 - 1))
        elif self.itype == "b":
            if self.icode == "beq":
                eicode = 48
            elif self.icode == "bne":
                eicode = 50
            else:
                raise

            offsetlo = self.offset & (2**10 - 1)
            offsethi = (self.offset >> 10) & (2**5 -1)
            encoded = (eicode << 25) | (offsethi << 20) | (self.r1 << 15) | (self.r2 << 10) | offsetlo
        elif self.itype == "j":
            if self.icode == "jmp":
                eicode = 49
            else:
                raise

            offsetlo = self.offset & (2**15 - 1)
            offsethi = (self.offset >> 15) & (2**5 -1)

            encoded = (eicode << 25) | (offsethi << 20) | offsetlo
        elif self.itype == "i":
            if self.icode == "li":
                eicode = 15
            else:
                raise

            encoded = (eicode << 25) | (self.dst << 20) | (self.offset & (2**20 - 1))
        elif self.itype == "n":
            encoded = 0xFE000000

        else:
            raise

        return encoded
