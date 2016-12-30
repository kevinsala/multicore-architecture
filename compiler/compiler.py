import sys
import instruction

OUT_FILE = "memory_boot"

class Label:
    def __init__(self, label, addr):
        self.label = label
        self.addr = addr

    def calc_offset(self, addr):
        return self.addr - addr

def main():
    if len(sys.argv) != 2:
        print("Missing input file")

    inst = []
    labels = []
    with open(sys.argv[1], "r") as f:
        for l in f:
            # Remove pre and post whitespace
            l = l.strip()

            if len(l) != 0 and l[0] != "#":
                if l[-1:] == ":":
                    # This is a label
                    label_text = l[:-1]
                    for label in labels:
                        if label.label == label_text:
                            raise instruction.InvalidInstruction(l)

                    labels.append(Label(label_text, len(inst)))
                else:
                    # This is an instruction
                    inst.append(instruction.Instruction(l))

    for i in range(len(inst)):
        if inst[i].label != "":
            for label in labels:
                if label.label == inst[i].label:
                    inst[i].set_offset(label.calc_offset(i))

            if not inst[i].is_set_offset():
                raise instruction.InvalidInstruction(inst[i].asm)

    with open(OUT_FILE, "w") as f:
        for i in inst:
            f.write("%08x\n" % i.to_binary())

if __name__ == "__main__":
    main()
