import sys
import processor_model

def main():
    if len(sys.argv) != 2:
        print("Missing input file")

    proc = processor_model.InkelPentiun(sys.argv[1])

    while proc.step() != 0:
        pass

    proc.dump_verbose()

if __name__ == "__main__":
    main()
