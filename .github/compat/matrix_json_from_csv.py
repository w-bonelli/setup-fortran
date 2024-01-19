import csv
import json
import sys
from pathlib import Path

csv_path = Path(sys.argv[1])  # path to CSV file
jsn_path = Path(sys.argv[2])  # path to JSON file

runners = set()
toolchain = set()
exclude = [
    {"os": "macos-13", "toolchain": {"compiler": "intel"}},
    {"os": "macos-12", "toolchain": {"compiler": "intel"}},
    {"os": "macos-11", "toolchain": {"compiler": "intel"}},
    {"os": "macos-13", "toolchain": {"compiler": "nvidia-hpc"}},
    {"os": "macos-12", "toolchain": {"compiler": "nvidia-hpc"}},
    {"os": "macos-11", "toolchain": {"compiler": "nvidia-hpc"}},
    {"os": "windows-2022", "toolchain": {"compiler": "nvidia-hpc"}},
    {"os": "windows-2019", "toolchain": {"compiler": "nvidia-hpc"}},
]

with open(csv_path, "r") as csv_file:
    reader = csv.DictReader(csv_file)
    for row in reader:
        if not any(row["support"].strip()):
            continue
        runners.add(row["runner"])
        toolchain.add({
            "compiler": row["compiler"],
            "version": row["version"]
        })

json.dump(jsn_path, {
    "matrix": {
        "os": list(runners),
        "toolchain": list(toolchain),
        "exclude": exclude
    }
})
