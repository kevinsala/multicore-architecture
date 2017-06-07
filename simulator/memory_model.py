import os

class MemoryModel:
    def _swap_mem_line_endianness(self, mem_line):
        if len(mem_line) % 8:
            print "WARNING: tring to swap endianness of a memory line of wrong size"

        new_mem_line = ""
        for i in range(0, len(mem_line), 8):
            new_mem_line = mem_line[i:i+8] + new_mem_line

        return new_mem_line

    def _get_mem_index(self, line):
        if line > 16384:
            print "WARNING: Out of bounds memory access to line 0x%08x" % line
            return -1

        i = 0
        while i < len(self.memory) and self.memory[i][0] < line:
            i = i + 1

        if i < len(self.memory) and self.memory[i][0] == line:
            return i
        else:
            return -1

    def _get_from_mem(self, addr):
        line = addr >> 4
        idx = self._get_mem_index(line)

        if idx == -1:
            data = "0" * 32
            self.memory.append((line, data))
            self.memory.sort(key = lambda x: x[0])
        else:
            data = self.memory[idx][1]

        return data

    def _write_to_mem(self, addr, data):
        line = addr >> 4
        idx = self._get_mem_index(line)

        if idx == -1:
            self.memory.append((line, data))
            self.memory.sort(key = lambda x: x[0])
        else:
            self.memory[idx] = (line, data)

    def _update_lru_llc(self, line):
        old_lru = self.llc_lru[line]
        for i in range(32):
            if self.llc_lru[i] < old_lru:
                self.llc_lru[i] = self.llc_lru[i] + 1

        self.llc_lru[line] = 0

    def _update_llc(self, addr):
        tag = addr >> 4

        index = -1
        for i in range(32):
            if self.llc_v[i] and self.llc_tag[i] == tag:
                index = i
                break

        if index == -1:
            for i in range(32):
                if not self.llc_v[i]:
                    index = i
                    break

                if self.llc_lru[i] == 31:
                    index = i

            if self.llc_v[index]:
                rep_addr = self.llc_tag[index] << 4
                if self.llc_a[index]:
                    # LLC has the most recent copy, send to mem and forget
                    self._write_to_mem(rep_addr, self.llc_data[index])
                else:
                    # LLC doesn't have the most recent copy. Get it
                    for p in self.processors:
                        data = p.get(rep_addr)
                        if data != None:
                            break

                    self._write_to_mem(rep_addr, data)

            self.llc_data[index] = self._get_from_mem(addr)
            self.llc_v[index] = True
            self.llc_a[index] = True
            self.llc_tag[index] = tag

        self._update_lru_llc(index)

        return index

    def __init__(self, mem_boot, mem_sys = ""):
        self.memory = []
        self.processors = []

        self.llc_v = []
        self.llc_a = []
        self.llc_tag = []
        self.llc_lru = []
        self.llc_data = []

        for i in range(32):
            self.llc_v.append(False)
            self.llc_a.append(False)
            self.llc_tag.append(0)
            self.llc_lru.append(i)
            self.llc_data.append("")

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

            if i != 0:
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


    def add_processor(self, proc):
        self.processors.append(proc)


    def get_inst(self, addr):
        index = self._update_llc(addr)
        self.llc_a[index] = True
        return self.llc_data[index]


    def get(self, addr):
        index = self._update_llc(addr)
        
        if self.llc_a[index]:
            self.llc_a[index] = False
            return self.llc_data[index]
        else:
            for p in self.processors:
                data = p.get(addr)
                if data != None:
                    return data


    def put(self, addr, data):
        index = self._update_llc(addr)
        self.llc_data[index] = data
        self.llc_a[index] = True


    def commit(self):
        self.old_memory = list(self.memory)

    def check_dump(self, dump_folder):
        # Dumps must be checked with the previous instruction
        error = False

        with open(dump_folder + "/ram", "r") as f:
            proc_mem_line = 0
            idx_mod = 0
            for line in f:
                # Assuming both memories are sorted by address
                line_proc, data_proc = line.split()
                line_proc = int(line_proc)
                data_proc = data_proc.lower()

                # Memory lines that are in the processor but not in the model
                # are not a problem. They are the result of an eviction at stage
                # C, whereas the model is in stage "commit" of a previous instruction

                line_mod = self.old_memory[idx_mod][0]
                if line_proc < line_mod:
                    continue

                if line_proc > line_mod:
                    print "ERROR: memory line %08x has not been written when it should have" % line_mod
                    error = True
                else:
                    data_mod = self._swap_mem_line_endianness(self.old_memory[idx_mod][1])
                    if data_mod != data_proc:
                        print "ERROR: memory line %08x has not been updated properly" % line_proc
                        print "Expected data: %s. Received data: %s" % (data_mod, data_proc)
                        error = True

                idx_mod = idx_mod + 1
                while idx_mod != len(self.old_memory):
                    idx_mod = idx_mod + 1

                if idx_mod == len(self.old_memory):
                    break

        if not error:
            os.remove(dump_folder + "/ram")

        return error

    def dump_verbose(self):
        print "--- LLC ---"
        for i in range(32):
            v = "-"
            a = "-"
            if self.llc_v[i]:
                v = "V"
            if self.llc_a[i]:
                a = "A"

            print "(%c%c) 0x%04x -> %s" % (v, a, self.llc_tag[i], self.llc_data[i])

        print "--- MEMORY ---"
        for m in self.memory:
            print "0x%04x -> %s" % (m[0], m[1])
