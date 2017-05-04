import os

def sign_extend(value, bits):
    sign_bit = 1 << (bits - 1)
    return (value & (sign_bit - 1)) - (value & sign_bit)

class InkelPentiun:
    verbose = False

    def _physical_addr(self, vaddr):
        return vaddr

    def _swap_mem_line_endianness(self, mem_line):
        if len(mem_line) % 8:
            print "WARNING: tring to swap endianness of a memory line of wrong size"

        new_mem_line = ""
        for i in range(0, len(mem_line), 8):
            new_mem_line = mem_line[i:i+8] + new_mem_line

        return new_mem_line


    def _save_old_memories(self):
        self.old_memory = list(self.memory)
        self.old_cache_i_v = list(self.cache_i_v)
        self.old_cache_i_tag = list(self.cache_i_tag)
        self.old_cache_i_data = list(self.cache_i_data)
        self.old_cache_d_v = list(self.cache_d_v)
        self.old_cache_d_d = list(self.cache_d_d)
        self.old_cache_d_tag = list(self.cache_d_tag)
        self.old_cache_d_data = list(self.cache_d_data)
        self.old_reg_b = list(self.reg_b)


    def _update_old_mem(self, data, addr):
        line = addr >> 4

        i = 0
        while i < len(self.old_memory) and self.old_memory[i][0] < line:
            i = i + 1

        if i < len(self.old_memory) and self.old_memory[i][0] == line:
            self.old_memory[i] = (line, data)
        else:
            self.old_memory.append((line, data))
            self.old_memory.sort(key = lambda x: x[0])


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
            self.memory[i] = (line, data)
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


    def _update_lru_cache_d(self, line):
        old_lru = self.cache_d_lru[line]
        for i in range(4):
            if self.cache_d_lru[i] < old_lru:
                self.cache_d_lru[i] = self.cache_d_lru[i] + 1

        self.cache_d_lru[line] = 0


    def _update_cache_d(self, addr):
        elem = (addr >> 2) & (2**2 - 1) # Bits 2 and 3
        tag = addr >> 4

        index = -1
        for i in range(4):
            if self.cache_d_v[i] and self.cache_d_tag[i] == tag:
                index = i
                break

        if index == -1:
            index = self.cache_d_lru.index(3)
            if self.cache_d_d[index]:
                self._write_to_mem(self.cache_d_data[index], self.cache_d_tag[index] << 4)

                # A dirty eviction is seen already at the end of the execution of the instruction
                # that it is being run, instead of the next one
                self._update_old_mem(self.cache_d_data[index], self.cache_d_tag[index] << 4)

            self.cache_d_v[index] = True
            self.cache_d_d[index] = False
            self.cache_d_tag[index] = tag
            self.cache_d_data[index] = self._read_from_mem(addr)

        self._update_lru_cache_d(index)

        return index


    def _read_from_cache_d(self, vaddr):
        if vaddr % 4 != 0:
            print "WARNING: Unaligned cache access to address 0x%08x" % addr

        paddr = self._physical_addr(vaddr)

        elem = (vaddr >> 2) & (2**2 - 1) # Bits 2 and 3

        index = self._update_cache_d(paddr)
        return self.cache_d_data[index][elem * 8 : (elem + 1) * 8]


    def _write_to_cache_d(self, vaddr, data, is_byte):
        if not is_byte and vaddr % 4 != 0:
            print "WARNING: Unaligned cache access to address 0x%08x" % addr

        paddr = self._physical_addr(vaddr)

        index = self._update_cache_d(paddr)
        cache_line = self.cache_d_data[index]

        if is_byte:
            byte = paddr & (2**4 - 1)
            data_s = "%02x" % (data & (-1 * 2**8))
            msb = (byte + 1) * 2
            lsb = byte * 2
        else:
            elem = (paddr & 0xC) >> 2
            data_s = "%08x" % data
            msb = (elem + 1) * 4
            lsb = elem * 4

        cache_line = cache_line[0:(lsb * 2)] + data_s + cache_line[(msb * 2):len(cache_line)]
        self.cache_d_data[index] = cache_line
        self.cache_d_d[index] = True


    def __init__(self, mem_boot, mem_sys = ""):
        self.memory = []

        self.cache_i_v = [False, False, False, False]
        self.cache_i_tag = [0, 0, 0, 0]
        self.cache_i_data = ["", "", "", ""]

        self.cache_d_v = [False, False, False, False]
        self.cache_d_d = [False, False, False, False]
        self.cache_d_tag = [0, 0, 0, 0]
        self.cache_d_lru = [0, 1, 2, 3]
        self.cache_d_data = ["", "", "", ""]

        self.reg_b = [0] * 32
        self.pc = 0x1000

        pos = 0x100
        with open(mem_boot, "r") as f:
            i = 0
            mem_line = ""
            for l in f:
                l = l[:-1]
                mem_line = mem_line + l
                i = i + 1

                if i == 4:
                    self.memory.append((pos, mem_line.lower()))
                    mem_line = ""
                    i = 0
                    pos = pos + 1

            if i != 4:
                while i < 4:
                    mem_line = mem_line + "00000000"
                    i = i + 1

                self.memory.append((pos, mem_line.lower()))


        if mem_sys != "":
            pos = 0x200
            with open(mem_sys, "r") as f:
                i = 0
                mem_line = ""
                for l in f:
                    l = l[:-1]
                    mem_line = mem_line + l
                    i = i + 1

                    if i == 4:
                        self.memory.append((pos, mem_line.lower()))
                        mem_line = ""
                        i = 0
                        pos = pos + 1

                if i != 4:
                    while i < 4:
                        mem_line = mem_line + "00000000"
                        i = i + 1

                    self.memory.append((pos, mem_line.lower()))


    def step(self):
        self._save_old_memories()

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
            self.reg_b[rdest] = self.reg_b[r1] + self.reg_b[r2]
        elif icode == 1:
            # sub
            self.reg_b[rdest] = self.reg_b[r1] - self.reg_b[r2]
        elif icode == 2:
            # mul
            data_r1 = sign_extend(self.reg_b[r1] & (2**16 - 1), 16)
            data_r2 = sign_extend(self.reg_b[r2] & (2**16 - 1), 16)
            self.reg_b[rdest] = data_r1 * data_r2
        elif icode == 15:
            # li
            self.reg_b[rdest] = sign_extend(offset_i, 20)
        elif icode == 16:
            # ldb
            addr = sign_extend(offsetlo, 15) + self.reg_b[r1]
            align_addr = addr & (-1 * 2**2)
            byte = addr & (2**2 - 1)
            data = int(self._read_from_cache_d(align_addr), 16)
            self.reg_b[rdest] = sign_extend(data & (2**8 - 1), 8)
        elif icode == 17:
            # ldw
            addr = sign_extend(offsetlo, 15) + self.reg_b[r1]
            data = int(self._read_from_cache_d(addr), 16)
            self.reg_b[rdest] = sign_extend(data, 32)
        elif icode == 18:
            # stb
            addr = sign_extend(offsetlo, 15) + self.reg_b[r1]
            self._write_to_cache_d(addr, self.reg_b[rdest], True)
        elif icode == 19:
            # stw
            addr = sign_extend(offsetlo, 15) + self.reg_b[r1]
            self._write_to_cache_d(addr, self.reg_b[rdest], False)
        elif icode == 20:
            # mov
            self.reg_b[rdest] = self.reg_b[r1]
        elif icode == 48:
            # beq
            if self.reg_b[r1] == self.reg_b[r2]:
                next_pc = (sign_extend((offsethi << 10) | offsetlo_b, 15) * 4) + self.pc
        elif icode == 49:
            # jmp
            next_pc = (sign_extend((offsethi << 15) | offsetlo, 20) * 4) + self.pc
        elif icode == 50:
            # bne
            if self.reg_b[r1] != self.reg_b[r2]:
                next_pc = (sign_extend((offsethi << 10) | offsetlo_b, 15) * 4) + self.pc
        else:
            # nop / error
            if icode != (2**7 - 1):
                print "WARNING: non-valid instruction. Will halt simulation"
                return 0

        if self.verbose:
            print "------------------------------"
            print self.memory
            print "------------------------------"
            print self.cache_i_v
            print self.cache_i_tag
            print self.cache_i_data
            print "------------------------------"
            print self.cache_d_v
            print self.cache_d_d
            print self.cache_d_tag
            print self.cache_d_data
            print "------------------------------"
            print self.reg_b
            print "------------------------------"
            print

        cur_pc = self.pc
        self.pc = next_pc
        return cur_pc

    def check_dump(self, dump_folder):
        # Dumps must be checked with the previous instruction
        error = False
        with open(dump_folder + "/ram", "r") as f:
            proc_mem_line = 0
            idx = 0
            for line in f:
                if self.old_memory[idx][0] == proc_mem_line:
                    line = line[:-1].lower()
                    mem_line = self._swap_mem_line_endianness(self.old_memory[idx][1])
                    if mem_line != line:
                        print "ERROR: memory line %08x has not been updated properly" % proc_mem_line
                        print "Expected data: %s. Received data: %s" % (mem_line, line)
                        error = True
                    idx = idx + 1
                    if idx == len(self.old_memory):
                        break
                proc_mem_line = proc_mem_line + 1

        with open(dump_folder + "/reg", "r") as f:
            reg_line = 0
            for line in f:
                if self.old_reg_b[reg_line]:
                    line = line[:-1].lower()
                    str_reg_line = "%08x" % self.old_reg_b[reg_line]
                    if str_reg_line != line:
                        print "ERROR: Register %d has not been updated properly" % reg_line
                        print "Expected data: %s. Received data: %s" % (str_reg_line, line)
                        error = True
                reg_line = reg_line + 1

        if not error:
            os.remove(dump_folder + "/ram")
            os.remove(dump_folder + "/reg")

        return error

    def dump_verbose(self):
        print "--- MEMORY ---"
        for m in self.memory:
            print "0x%04x -> %s" % (m[0], m[1])

        print "--- ICACHE ---"
        for i in range(len(self.cache_i_v)):
            if self.cache_i_v[i]:
                v = 'V'
            else:
                v = 'I'
            print "%d %s 0x%04x %s" % (i, v, self.cache_i_tag[i], self.cache_i_data[i])

        print "--- DCACHE ---"
        for i in range(len(self.cache_d_v)):
            if self.cache_d_v[i]:
                v = 'V'
            else:
                v = 'I'
            print "%d %s 0x%04x %s" % (i, v, self.cache_d_tag[i], self.cache_d_data[i])

        print "--- RB ---"
        for i in range(len(self.reg_b)):
            print "%d 0x%04x" % (i, self.reg_b[i])
