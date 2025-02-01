#!/bin/bash

make clean
make &> build.log

rm -rf asm bin outputs
mkdir -p asm bin outputs
for i in $(seq 1 6)
do 
    echo example $i
    mkdir -p asm/inc_example$i

    #echo building...
    ./rx-cc tests/example$i/main.cmm
    if [ $? -ne 0  ]; then
        echo failed to build example$i
        echo
        continue
    fi
    mv main.rsk asm/example$i.rsk

    if [ -n "$( ls -A tests/example$i/includes )" ]; then
        for filename in tests/example$i/includes/*.cmm; do
            export name=`basename $filename .cmm`
            ./rx-cc $filename
            mv $name.rsk asm/inc_example$i
        done
    fi

    #echo linking...
    if [ -n "$( ls -A tests/example$i/includes )" ]; then
        ./rx-linker asm/example$i.rsk asm/inc_example$i/*
    else
        ./rx-linker asm/example$i.rsk      
    fi

    #echo running...
    mv asm/example$i.e bin
    ./rx-vm bin/example$i.e < tests/example$i/input.in 1> outputs/example$i.out
    if [ $? -ne 0 ]; then
        echo Runtime error on example $i
        continue
    fi

    #echo comparing...
    diff tests/example$i/output.out outputs/example$i.out 1>outputs/example$i.diff
    if [ $? -ne 0 ]; then
        echo example$i failed! Different outputs.
    else
        echo example$i succeeded!
    fi

    echo
done

rm -rf main.rsk *.e
