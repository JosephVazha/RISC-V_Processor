#!/usr/bin/env python3
from pathlib import Path
import sys

if len(sys.argv) != 3:
    print(f"Usage: {sys.argv[0]} input.bin output.memh")
    raise SystemExit(1)

input_path = Path(sys.argv[1])
output_path = Path(sys.argv[2])

data = input_path.read_bytes()

# Pad to a whole number of 32-bit words.
data += b"\x00" * ((-len(data)) % 4)

with output_path.open("w") as f:
    for offset in range(0, len(data), 4):
        # RISC-V binaries are little-endian.
        word = int.from_bytes(data[offset:offset + 4], byteorder="little")
        f.write(f"{word:08x}\n")

print(f"Wrote {len(data) // 4} words to {output_path}")

