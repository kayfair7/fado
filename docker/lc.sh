#!/bin/bash
wcll () {
    i=0
    for s in $( ls -x "$1" )
    do
        y=$( stat "$1/$s" | grep "regular file" )
        z=$( stat "$1/$s" | grep "directory" )
        if [ "$z" != ""  ]; then
            m=$( wcll "$1/$s")
        elif [ "$y" != "" ]; then
            m=$( wc -l "$1/$s" | grep -o -E "[0-9]+[[:space:]]" | grep -o -E "[0-9]+" )
        fi
        i=$(( $i + $m ))
    done
    echo "$i"
    return 0
}
l=$(wcll "$PWD")
echo "line count is $l"
exit 0
