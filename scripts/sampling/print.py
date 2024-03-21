import sys
import random
import shared

CHOICES_FILE, TRANSCRIPT_DIR = shared.get_args(2, "print.py")
SOURCE, BOUNDARIES = shared.get_source(TRANSCRIPT_DIR)


def get_choices(choices_file):
    choices = []
    with open(choices_file, "r") as f:
        lines = f.readlines()
        for line in lines:
            if line.strip() != "":
                parts = line.strip().split(":")
                if len(parts) != 2:
                    print("ERROR: Invalid line: " + line)
                    sys.exit(0)
                line, col = parts
                # get contents of file map, error if key not found
                choices.append((line, col))
    return choices


CHOICES = get_choices(CHOICES_FILE)
random.shuffle(CHOICES)


def get_substring(string, index):
    # Get the start and end indices for the substring
    start_index = max(0, index - 250)
    end_index = min(len(string), index + 250)
    # Get the substring
    return string[start_index:end_index]


def print_choices(md, csv, choices, source, boundaries):
    csv.write("quote_id,transcript_id,line,column,detail_ids,notes\n")
    for i, (line, col) in enumerate(choices):
        index = shared.coordinates_to_index(source, int(line), int(col))
        if index not in boundaries:
            print("ERROR: Invalid index: " + str(index))
            sys.exit(0)
        id = boundaries[index]
        md.write(f"## {i+1} \\- {id}:{line}:{col}\n")
        window = get_substring(source, index)
        md.write(f"{window}\n\n")
        csv.write(f"{i+1},{id},{line},{col},,\n")


md = open("output.md", "w")
csv = open("output.csv", "w")
print_choices(md, csv, CHOICES, SOURCE, BOUNDARIES)
md.close()
csv.close()
