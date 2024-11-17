#!/bin/bash

nasm -f elf64 "$1" -o /tmp/temp.o && gcc -no-pie /tmp/temp.o -o /tmp/temp && /tmp/temp
