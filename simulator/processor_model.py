import os

def sign_extend(value, bits):
    sign_bit = 1 << (bits - 1)
    return (value & (sign_bit - 1)) - (value & sign_bit)

class InkelPentiun:
    verbose = False

    def _read_from_cache_i(self, addr):
        if addr % 4 != 0:
            print "WARNING: Unaligned cache access to address 0x%08x" % addr

        elem = (addr >> 2) & (2**2 - 1) # Bits 2 and 3
        line = (addr >> 4) & (2**2 - 1) # Bits 4 and 5
        tag = addr >> 6

        if not self.cache_i_v[line] or self.cache_i_tag[line] != tag:
            self.cache_i_v[line] = True
            self.cache_i_tag[line] = tag
            self.cache_i_data[line] = self.memory.get_inst(addr)

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
            for i in range(4):
                if not self.cache_d_v[i]:
                    index = i
                    break

                if self.cache_d_lru[i] == 3:
                    index = i

            if self.cache_d_v[index]:
                self.memory.put(self.cache_d_tag[index] << 4, self.cache_d_data[index])

            self.cache_d_data[index] = self.memory.get(addr)
            self.cache_d_v[index] = True
            self.cache_d_tag[index] = tag

        self._update_lru_cache_d(index)

        return index


    def _read_from_cache_d(self, addr):
        if addr % 4 != 0:
            print "WARNING: Unaligned cache access to address 0x%08x" % addr

        elem = (addr >> 2) & (2**2 - 1) # Bits 2 and 3

        index = self._update_cache_d(addr)
        return self.cache_d_data[index][elem * 8 : (elem + 1) * 8]


    def _write_to_cache_d(self, addr, data):
        if addr % 4 != 0:
            print "WARNING: Unaligned cache access to address 0x%08x" % addr

        index = self._update_cache_d(addr)
        cache_line = self.cache_d_data[index]

        elem = (addr & 0xC) >> 2
        data_s = "%08x" % data
        msb = (elem + 1) * 4
        lsb = elem * 4

        cache_line = cache_line[0:(lsb * 2)] + data_s + cache_line[(msb * 2):len(cache_line)]
        self.cache_d_data[index] = cache_line


    def __init__(self, proc_id, memory):
        self.proc_id = proc_id
        self.memory = memory

        self.cache_i_v = [False, False, False, False]
        self.cache_i_tag = [0, 0, 0, 0]
        self.cache_i_data = ["", "", "", ""]

        self.cache_d_v = [False, False, False, False]
        self.cache_d_tag = [0, 0, 0, 0]
        self.cache_d_lru = [0, 1, 2, 3]
        self.cache_d_data = ["", "", "", ""]

        self.reg_b = [0] * 32
        self.pc = 0x1000


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
        elif icode == 17:
            # ldw
            addr = sign_extend(offsetlo, 15) + self.reg_b[r1]
            data = int(self._read_from_cache_d(addr), 16)
            self.reg_b[rdest] = sign_extend(data, 32)
        elif icode == 19:
            # stw
            addr = sign_extend(offsetlo, 15) + self.reg_b[r1]
            self._write_to_cache_d(addr, self.reg_b[rdest])
        elif icode == 20:
            # mov
            self.reg_b[rdest] = self.reg_b[r1]
        elif icode == 21:
            # tsl
            addr = sign_extend(offsetlo, 15) + self.reg_b[r1]
            data = int(self._read_from_cache_d(addr), 16)
            self.reg_b[rdest] = sign_extend(data, 32)
            self._write_to_cache_d(addr, 1)
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
        elif icode == 64:
            # pid
            self.reg_b[rdest] = self.proc_id;
        else:
            # nop / error
            if icode != (2**7 - 1):
                print "WARNING: non-valid instruction. Will halt simulation"
                return 0

        if self.verbose:
            print "------------------------------"
            print self.cache_i_v
            print self.cache_i_tag
            print self.cache_i_data
            print "------------------------------"
            print self.cache_d_v
            print self.cache_d_tag
            print self.cache_d_data
            print "------------------------------"
            print self.reg_b
            print "------------------------------"
            print

        self.pc = next_pc
        return self.pc


    def commit(self):
        self.old_reg_b = list(self.reg_b)


    def get(self, addr):
        tag = addr >> 4

        index = -1

        for i in range(4):
            if self.cache_d_v[i] and self.cache_d_tag[i] == tag:
                index = i
                break

        if index == -1:
            return None

        self.cache_d_v[index] = False
        return self.cache_d_data[index]


    def check_dump(self, dump_folder):
        # Dumps must be checked with the previous instruction
        error = False

        path = dump_folder + "/reg" + str(self.proc_id)
        with open(path, "r") as f:
            reg_line = 0
            for line in f:
                if self.old_reg_b[reg_line]:
                    line = line[:-1].lower()
                    unsigned_reg = self.old_reg_b[reg_line] & ((2**32) - 1)
                    str_reg_line = "%08x" % unsigned_reg
                    if str_reg_line != line:
                        print "ERROR: Register %d has not been updated properly" % reg_line
                        print "Expected data: %s. Received data: %s" % (str_reg_line, line)
                        error = True
                reg_line = reg_line + 1

        if not error:
            os.remove(path)

        return error


    def dump_verbose(self):
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
