#!/bin/bash
wcll () {
    i=0
    y=""
    z=""
    for s in $( ls -x "$1" )
    do
        y=$( stat "$1/$s" | grep "regular file" )
        z=$( stat "$1/$s" | grep "directory" )
        if [ "$z" != ""  ]; then
           k=$( wcll "$1/$s")
           i=$(( $i + $k ))
        elif [ "$y" != "" ]; then
            x=$( wc -l "$1/$s" | grep -o -E "[0-9]+[[:space:]]" | grep -o -E "[0-9]+" | xargs expr )
            if [ "$x" != "" ]; then
                i=$(( $i + $x ))
            fi
        fi
    done
    echo "$i"
    return 0;
}
l=$(wcll "$PWD" | xargs expr)
echo "line count is "
echo $l
exit 0
