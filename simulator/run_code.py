import sys
import processor_model
import memory_model

def main():
    if len(sys.argv) != 2:
        print("Missing input file")

    mem = memory_model.MemoryModel(sys.argv[1])
    proc0 = processor_model.InkelPentiun(0, mem)
    proc1 = processor_model.InkelPentiun(1, mem)

    mem.add_processor(proc0)
    mem.add_processor(proc1)

    step0 = -1
    step1 = -1
    while step0 != 0 and step1 != 0:
        if step0 != 0:
            step0 = proc0.step()

        if step1 != 0:
            step1 = proc1.step()


    print("---------- PROCESSOR 0 ----------")
    proc0.dump_verbose()

    print("---------- PROCESSOR 1 ----------")
    proc1.dump_verbose()

    print("---------- MEMORY ----------")
    mem.dump_verbose()

if __name__ == "__main__":
    main()
