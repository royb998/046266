#!/bin/bash

make clean
make &> build.log

rm -rf asm bin outputs diffs
mkdir -p asm bin outputs diffs
for testdir in tests/*
do 
    export testname=`basename $testdir`
    echo Testing $testname

    #echo building...
    ./rx-cc tests/$testname/test.cmm
    if [ $? -ne 0  ]; then
        echo failed to build $testname
        echo
        continue
    fi
    mv test.rsk asm/$testname.rsk

    if [[ -d "tests/$testname/includes" && -n "$( ls -A tests/$testname/includes )" ]]; then
        mkdir -p asm/inc_$testname
        for filename in tests/$testname/includes/*.cmm; do
            export name=`basename $filename .cmm`
            ./rx-cc $filename
            mv $name.rsk asm/inc_$testname
        done
    fi

    #echo linking...
    if [[ -d "tests/$testname/includes" && -n "$( ls -A tests/$testname/includes )" ]]; then
        ./rx-linker asm/$testname.rsk asm/inc_$testname/*
    else
        ./rx-linker asm/$testname.rsk      
    fi

    #echo running...
    mv asm/$testname.e bin
    touch tests/$testname/input.in tests/$testname/output.out
    ./rx-vm-nprints bin/$testname.e < tests/$testname/input.in 1> outputs/$testname.out
    if [ $? -ne 0 ]; then
        echo Runtime error on $testname
        echo
        continue
    fi

    #echo comparing...
    diff tests/$testname/output.out outputs/$testname.out 1>diffs/$testname.diff
    if [ $? -ne 0 ]; then
        echo $testname failed! Different outputs.
    else
        echo $testname succeeded!
    fi

    echo
done

rm -rf test.rsk *.e
