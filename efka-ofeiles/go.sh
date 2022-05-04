#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd "$SCRIPT_DIR"
. venv-gsis/bin/activate

if [ "$#" -ne 1 ]; then
    echo "specify account from credentials.json as argument. E.g. $0 account1"
    exit
fi
venv-gsis/bin/python3 efka.py --account "$1"
