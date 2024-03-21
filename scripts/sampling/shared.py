import sys
import os
import random
from rangedict import RangeDict

def exit_with_usage(filename):
    print(f"Usage: python {filename} <transcript> <log> <num_samples>")
    sys.exit(0)


def get_args(expected_length, filename):
    if len(sys.argv) != expected_length + 1:
        exit_with_usage(filename)
    return sys.argv[1:]


def coordinates_to_index(s, line, col):
    """Returns index of line `line` and column `col` in `s`."""
    if not len(s):
        return 0
    sp = s.splitlines(keepends=True)
    return sum(len(sp[i]) for i in range(line - 1)) + col - 1


def index_to_coordinates(s, index):
    """Returns (line_number, col) of `index` in `s`."""
    if not len(s):
        return 1, 1
    sp = s[: index + 1].splitlines(keepends=True)
    return len(sp), len(sp[-1])


def read_contents(filename):
    if not (os.path.exists(filename)):
        print("ERROR: File does not exist: " + filename)
        sys.exit(0)
    with open(filename, "r") as f:
        return f.read()


def get_source(transcript_dir):
    sources = {}
    source_boundaries = RangeDict()
    for file in os.listdir(transcript_dir):
        if os.path.isdir(file):
            print("ERROR: Invalid directory: " + file + " in transcripts directory.")
            sys.exit(0)
        if not file.split(".")[0].isdigit():
            print("ERROR: Invalid file: " + file + " in transcripts directory.")
            sys.exit(0)
        id = int(file.split(".")[0])
        if sources.get(id) is not None:
            print("ERROR: Duplicate file: " + file + " in transcripts directory.")
            sys.exit(0)
        source_text = read_contents(os.path.join(transcript_dir, file)).strip()
        sources[id] = source_text
    # get a sorted list of the keys in sources
    keys = list(sources.keys())
    keys.sort()
    text = ""
    start_index = 0
    for key in keys:
        contents = sources[key]
        text += contents
        source_boundaries[(start_index, start_index + len(contents))] = key
        start_index += len(contents) + 1
    return (text, source_boundaries)


def get_pulled(log_file, source):
    logs = read_contents(log_file).strip() + "\n"
    pulled = set()
    for line in logs.splitlines():
        if line.strip() == "":
            continue
        parts = line.strip().split(":")
        if len(parts) != 2:
            print("ERROR: Invalid line: " + line)
            sys.exit(0)
        line, col = parts
        if not line.isdigit():
            print("ERROR: Invalid line: " + line)
            sys.exit(0)
        if not col.isdigit():
            print("ERROR: Invalid col: " + col)
            sys.exit(0)
        index = coordinates_to_index(source, int(line), int(col))
        pulled.add(index)
    return pulled


# generate n random numbers that are not in pulled
def get_randoms(n, pulled, sources):
    randoms = set()
    while len(randoms) < n:
        new_pull = random.randint(1, len(sources))
        if new_pull not in pulled.union(randoms):
            randoms.add(new_pull)
    return randoms
