def sign_extend(value, bits):
    sign_bit = 1 << (bits - 1)
    return (value & (sign_bit - 1)) - (value & sign_bit)

class InkelPentiun:
    memory = []

    cache_i_v = [False, False, False, False]
    cache_i_tag = [0, 0, 0, 0]
    cache_i_data = ["", "", "", ""]

    cache_d_v = [False, False, False, False]
    cache_d_d = [False, False, False, False]
    cache_d_tag = [0, 0, 0, 0]
    cache_d_lru = [0, 1, 2, 3]
    cache_d_data = ["", "", "", ""]

    b_reg = [0] * 32
    pc = 0x1000

    def _read_from_mem(self, addr):
        line = addr >> 4

        if line > 16384:
            print "WARNING: Out of bounds memory access to address 0x%08x" % addr
            return "0"*32

        i = 0
        while i < len(self.memory) and self.memory[i][0] < line:
            i = i + 1

        if i < len(self.memory) and self.memory[i][0] == line:
            return self.memory[i][1]
        else:
            print "WARNING: Accessing an uninitialized memory position 0x%08x" % addr
            return "0"*32


    def _write_to_mem(self, data, addr):
        line = addr >> 4

        if line > 16384:
            print "WARNING: Out of bounds memory access to address 0x%08x" % addr
            return

        i = 0
        while i < len(self.memory) and self.memory[i][0] < line:
            i = i + 1

        if i < len(self.memory) and self.memory[i][0] == line:
            return self.memory[i][1]
        else:
            self.memory.append((line, data))
            self.memory.sort(key = lambda x: x[0])


    def _read_from_cache_i(self, addr):
        if addr % 4 != 0:
            print "WARNING: Unaligned cache access to address 0x%08x" % addr

        elem = (addr >> 2) & (2**2 - 1) # Bits 2 and 3
        line = (addr >> 4) & (2**2 - 1) # Bits 4 and 5
        tag = addr >> 6

        if not self.cache_i_v[line] or self.cache_i_tag[line] != tag:
            self.cache_i_v[line] = True
            self.cache_i_tag[line] = tag
            self.cache_i_data[line] = self._read_from_mem(addr)

        return self.cache_i_data[line][elem * 8 : (elem + 1) * 8]


    def _update_cache_d(self, addr):
        elem = (addr >> 2) & (2**2 - 1) # Bits 2 and 3
        tag = addr >> 4

        index = -1
        for i in range(4):
            if self.cache_d_v[i] and self.cache_d_tag[i] == tag:
                index = i
                break

        if index == -1:
            for i in range(4):
                if not self.cache_d_v[i]:
                    index = i
                    break

            if index == -1:
                index = self.cache_d_lru.index(3)
                if self.cache_d_d[index]:
                    self._write_to_mem(self.cache_d_data[index], self.cache_d_tag[index] << 4)

            for i in range(4):
                self.cache_d_lru[i] = self.cache_d_lru[i] + 1

            self.cache_d_v[index] = True
            self.cache_d_d[index] = False
            self.cache_d_tag[index] = tag
            self.cache_d_lru[index] = 0
            self.cache_d_data[index] = self._read_from_mem(addr)

        return index


    def _read_from_cache_d(self, addr):
        if addr % 4 != 0:
            print "WARNING: Unaligned cache access to address 0x%08x" % addr

        elem = (addr >> 2) & (2**2 - 1) # Bits 2 and 3

        index = self._update_cache_d(addr)
        return self.cache_d_data[index][elem * 8 : (elem + 1) * 8]


    def _write_to_cache_d(self, addr, data, is_byte):
        if not is_byte and addr % 4 != 0:
            print "WARNING: Unaligned cache access to address 0x%08x" % addr

        index = self._update_cache_d(addr)
        cache_line = self.cache_d_data[index]

        if is_byte:
            byte = addr & (2**4 - 1)
            data_s = "%02x" % (data & (-1 * 2**8))
            msb = (byte + 1) * 2
            lsb = byte * 2
        else:
            elem = addr & 0xC
            data_s = "%08x" % data
            msb = (elem + 1) * 4
            lsb = elem * 4

        cache_line = cache_line[0:(lsb * 2)] + data_s + cache_line[(msb * 2):len(cache_line)]
        self.cache_d_data[index] = cache_line
        self.cache_d_d[index] = True


    def __init__(self, mem_boot, mem_sys = ""):
        pos = 0x100
        with open(mem_boot, "r") as f:
            i = 0
            mem_line = ""
            for l in f:
                l = l[:-1]
                mem_line = mem_line + l
                i = i + 1

                if i == 4:
                    self.memory.append((pos, mem_line))
                    mem_line = ""
                    i = 0
                    pos = pos + 1

            if i != 4:
                while i < 4:
                    mem_line = mem_line + "00000000"
                    i = i + 1

                self.memory.append((pos, mem_line))


        if mem_sys != "":
            pos = 0x200
            with open(mem_sys, "r") as f:
                i = 0
                mem_line = ""
                for l in f:
                    if i < 3:
                        mem_line = l + mem_line
                        i = i + 1
                    else:
                        i = 0
                        mem_line = ""
                        self.memory.append((pos, mem_line))
                        pos = pos + 1

                if i != 0:
                    while i < 4:
                        mem_line = "00000000" + mem_line
                        i = i + 1

                    self.memory.append((pos, mem_line))


    def step(self):
        inst_s = self._read_from_cache_i(self.pc)
        inst = int(inst_s, 16)

        if inst == 0:
            print("Finished simulation")
            return 0

        icode = inst >> 25
        rdest = (inst >> 20) & (2**5 - 1)
        r1 = (inst >> 15) & (2**5 - 1)
        r2 = (inst >> 10) & (2**5 - 1)
        offsetlo = inst & (2**15 - 1)
        offsetlo_b = inst & (2**10 - 1)
        offsethi = (inst >> 20) & (2**5 - 1)
        offset_i = inst & (2**20 -1)
        next_pc = self.pc + 4

        if icode == 0:
            # add
            self.b_reg[rdest] = self.b_reg[r1] + self.b_reg[r2]
        elif icode == 1:
            # sub
            self.b_reg[rdest] = self.b_reg[r1] - self.b_reg[r2]
        elif icode == 2:
            # mul
            data_r1 = sign_extend(self.b_reg[r1] & (2**16 - 1), 16)
            data_r2 = sign_extend(self.b_reg[r2] & (2**16 - 1), 16)
            self.b_reg[rdest] = data_r1 * data_r2
        elif icode == 15:
            # li
            self.b_reg[rdest] = sign_extend(offset_i, 20)
        elif icode == 16:
            # ldb
            addr = sign_extend(offsetlo, 15) + self.b_reg[r1]
            align_addr = addr & (-1 * 2**2)
            byte = addr & (2**2 - 1)
            data = int(self._read_from_cache_d(align_addr), 16)
            self.b_reg[rdest] = sign_extend(data & (2**8 - 1), 8)
        elif icode == 17:
            # ldw
            addr = sign_extend(offsetlo, 15) + self.b_reg[r1]
            data = int(self._read_from_cache_d(addr), 16)
            self.b_reg[rdest] = sign_extend(data, 32)
        elif icode == 18:
            # stb
            addr = sign_extend(offsetlo, 15) + self.b_reg[r1]
            self._write_to_cache_d(addr, self.b_reg[rdest], True)
        elif icode == 19:
            # stw
            addr = sign_extend(offsetlo, 15) + self.b_reg[r1]
            self._write_to_cache_d(addr, self.b_reg[rdest], False)
        elif icode == 48:
            # beq
            if self.b_reg[r1] == self.b_reg[r2]:
                next_pc = sign_extend((offsethi << 10) | offsetlo_b, 15) + self.pc
        elif icode == 49:
            # jmp
            next_pc = (sign_extend((offsethi << 15) | offsetlo, 20) * 4) + self.pc
        else:
            # nop / error
            if icode != (2**7 - 1):
                print "WARNING: non-valid instruction. Will halt simulation"
                return 0

        cur_pc = self.pc
        self.pc = next_pc
        return cur_pc
