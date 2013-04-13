#!/bin/sh
clear
echo "make dist"
./dist.sh
cd build
rm -rf *
cd ..
echo "pip - get dependencies"
pip install --upgrade --force-reinstall --no-install --download-cache=./deps -r ./dependencies.txt
echo "renaming dependencies"
cd ./deps
rename -f 's/.*%2F//' ./*
rm *.content-type
cd ..