#!/bin/bash

../compile.sh

if [[ -n $1 ]]; then
    ./main test
else
    ./main
fi