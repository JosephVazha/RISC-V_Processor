#!/usr/bin/env bash
set -euo pipefail

src="${1:-program.c}"

riscv64-elf-gcc \
   -march=rv32i -mabi=ilp32 \
   -nostdlib -T link.ld \
   -o program.elf "$src"

riscv64-elf-objcopy \
   -O binary program.elf program.bin

python3 bin_to_memh.py program.bin program.memh

echo "Created program.memh" 

