#!/bin/bash
make clean
make &> build.log

rm -rf asm bin outputs
mkdir -p asm bin outputs
for i in $(seq 1 10)
do 
    echo test $i

    #echo building...
    ./rx-cc tests/test$i/test.cmm
    if [ $? -ne 0  ]; then
        echo failed to build test$i
        echo
        continue
    fi

    #echo linking...
    mv test.rsk asm/test$i.rsk
    ./rx-linker asm/test$i.rsk

    #echo running...
    mv asm/test$i.e bin
    ./rx-vm bin/test$i.e < tests/test$i/input.in 1> outputs/test$i.out
    if [ $? -ne 0 ]; then
        echo Runtime error on test $i
        continue
    fi

    #echo comparing...
    diff tests/test$i/output.out outputs/test$i.out 1>outputs/test$i.diff
    if [ $? -ne 0 ]; then
        echo test$i failed! Different outputs.
    else
        echo test$1 succeeded!
    fi

    echo
done
