#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd "$SCRIPT_DIR"
. venv-gsis/bin/activate

if [ "$#" -ne 1 ]; then
    echo "specify account as argument"
    exit
fi
venv-gsis/bin/python3 efka.py --account "$1"
