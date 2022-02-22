#!/bin/bash
. gsis/bin/activate

if [ "$#" -ne 1 ]; then
    echo "specify account as argument"
    exit
fi
gsis/bin/python3 efka.py --account "$1"
