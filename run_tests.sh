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
    ./rx-cc $testdir/test.cmm
    if [ $? -ne 0  ]; then
        if [ -a $testdir/semantic_error ]; then
            echo Probably PASSED\; check build to ensure
            echo
            continue
        fi
        echo FAILED to build $testname
        echo
        continue
    else
        if [ -a $testdir/semantic_error ]; then
            echo $testname FAILED! should not have built
            echo
            continue
        fi
    fi
    mv test.rsk asm/$testname.rsk

    if [[ -d "$testdir/includes" && -n "$( ls -A $testdir/includes )" ]]; then
        mkdir -p asm/inc_$testname
        for filename in $testdir/includes/*.cmm; do
            export name=`basename $filename .cmm`
            ./rx-cc $filename
            mv $name.rsk asm/inc_$testname
        done
    fi

    #echo linking...
    if [[ -d "$testdir/includes" && -n "$( ls -A $testdir/includes )" ]]; then
        ./rx-linker asm/$testname.rsk asm/inc_$testname/*
    else
        ./rx-linker asm/$testname.rsk      
    fi

    #echo running...
    mv asm/$testname.e bin
    touch $testdir/input.in $testdir/output.out
    ./rx-vm-nprints bin/$testname.e < $testdir/input.in 1> outputs/$testname.out
    if [ $? -ne 0 ]; then
        echo Runtime error on $testname
        echo
        continue
    fi

    #echo comparing...
    diff $testdir/output.out outputs/$testname.out 1>diffs/$testname.diff
    if [ $? -ne 0 ]; then
        echo $testname FAILED! Different outputs.
    else
        echo $testname PASSED!
    fi

    echo
done

rm -rf test.rsk *.e
