import sys
import os
import shared

TRANSCRIPT_DIR, LOG_FILE, NUM_SAMPLES = shared.get_args(3, "choose.py")

if not os.path.exists(TRANSCRIPT_DIR):
    print("ERROR: Transcript directory: " + TRANSCRIPT_DIR + " does not exist.")
    sys.exit(0)
if not os.path.exists(LOG_FILE):
    with open(LOG_FILE, "w") as f:
        pass
if not NUM_SAMPLES.isdigit() or int(NUM_SAMPLES) <= 0:
    print("ERROR: Invalid number of samples: " + NUM_SAMPLES)
    sys.exit(0)

NUM_SAMPLES = int(NUM_SAMPLES)
SOURCE, BOUNDARIES = shared.get_source(TRANSCRIPT_DIR)
PULLED = shared.get_pulled(LOG_FILE, SOURCE)
CHOICES = shared.get_randoms(NUM_SAMPLES, PULLED, SOURCE)


def append_choices(log, choices):
    with open(log, "a") as f:
        for choice in choices:
            line, col = shared.index_to_coordinates(SOURCE, choice)
            choice_txt = str(f"{line}:{col}")
            print(choice_txt)
            f.write(choice_txt + "\n")


append_choices(LOG_FILE, CHOICES)
