#!/bin/sh
clear
echo "building Cython extensions!"
python setup_du.py build_ext --inplace
echo "building module egg distribution"
python setup.py bdist_egg