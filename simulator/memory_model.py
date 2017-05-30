import os

class MemoryModel:
    state_unavailable = 0
    state_available = 1

    def _swap_mem_line_endianness(self, mem_line):
        if len(mem_line) % 8:
            print "WARNING: tring to swap endianness of a memory line of wrong size"

        new_mem_line = ""
        for i in range(0, len(mem_line), 8):
            new_mem_line = mem_line[i:i+8] + new_mem_line

        return new_mem_line

    def _get_index(self, line):
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


    def __init__(self, mem_boot, mem_sys = ""):
        self.memory = []
        self.processors = []

        pos = 0x100
        with open(mem_boot, "r") as f:
            i = 0
            mem_line = ""
            for l in f:
                l = l[:-1]
                mem_line = mem_line + l
                i = i + 1

                if i == 4:
                    self.memory.append((pos, self.state_available, mem_line.lower()))
                    mem_line = ""
                    i = 0
                    pos = pos + 1

            if i != 0:
                while i < 4:
                    mem_line = mem_line + "00000000"
                    i = i + 1

                self.memory.append((pos, self.state_available, mem_line.lower()))


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
                        self.memory.append((pos, self.state_available, mem_line.lower()))
                        mem_line = ""
                        i = 0
                        pos = pos + 1

                if i != 4:
                    while i < 4:
                        mem_line = mem_line + "00000000"
                        i = i + 1

                    self.memory.append((pos, self.state_available, mem_line.lower()))


    def add_processor(self, proc):
        self.processors.append(proc)


    def get_inst(self, addr):
        line = addr >> 4
        idx = self._get_index(line)

        data = "0" * 32
        if idx == -1:
            self.memory.append((line, self.state_available, data))
            self.memory.sort(key = lambda x: x[0])
        else:
            data = self.memory[idx][2]

        return data


    def get(self, addr):
        line = addr >> 4
        idx = self._get_index(line)

        data = "0" * 32
        if idx == -1:
            self.memory.append((line, self.state_unavailable, data))
            self.memory.sort(key = lambda x: x[0])
        else:
            if self.memory[idx][1] == self.state_unavailable:
                for p in self.processors:
                    data = p.get(addr)
                    if data != None:
                        break
            else:
                data = self.memory[idx][2]

        return data


    def put(self, addr, data):
        line = addr >> 4
        idx = self._get_index(line)

        if idx == -1:
            self.memory.append((line, self.state_available, data))
            self.memory.sort(key = lambda x: x[0])
        else:
            self.memory[idx] = (line, self.state_available, data)

        # PUT request means eviction, update old_memory
        i = 0
        while i < len(self.old_memory) and self.old_memory[i][0] < line:
            i = i + 1

        if i < len(self.old_memory) and self.old_memory[i][0] == line:
            self.old_memory[i] = (line, self.state_available, data)
        else:
            self.old_memory.append((line, self.state_available, data))
            self.old_memory.sort(key = lambda x: x[0])


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
                    data_mod = self._swap_mem_line_endianness(self.old_memory[idx_mod][2])
                    if data_mod != data_proc:
                        print "ERROR: memory line %08x has not been updated properly" % line_proc
                        print "Expected data: %s. Received data: %s" % (data_mod, data_proc)
                        error = True

                idx_mod = idx_mod + 1
                while idx_mod != len(self.old_memory) and self.old_memory[idx_mod][1] == self.state_unavailable:
                    idx_mod = idx_mod + 1

                if idx_mod == len(self.old_memory):
                    break

        if not error:
            os.remove(dump_folder + "/ram")

        return error

    def dump_verbose(self):
        print "--- MEMORY ---"
        for m in self.memory:
            print "0x%04x (S %d) -> %s" % (m[0], m[1], m[2])
