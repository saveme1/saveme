#!/bin/sh
DoExitAsm ()
{ echo "An error occurred while assembling $1"; exit 1; }
DoExitLink ()
{ echo "An error occurred while linking $1"; exit 1; }
echo Linking saveme
OFS=$IFS
IFS="
"
/usr/lib/hardening-wrapper/bin/ld -b elf64-x86-64 -m elf_x86_64  --dynamic-linker=/lib64/ld-linux-x86-64.so.2    -L. -o saveme link.res
if [ $? != 0 ]; then DoExitLink saveme; fi
IFS=$OFS
