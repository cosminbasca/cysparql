#!/bin/sh

clean() {
    echo "Cleaning $1 ..."
    if [ -d "$1" ]
    then
        rm -f ./$1/*.c
        rm -f ./$1/*.h
        rm -f ./$1/*.so
        rm -f ./$1/*.pyc
    fi
    echo "[ok]"
}

clear

cd build
rm -rf *
cd ..
clean   cysparql