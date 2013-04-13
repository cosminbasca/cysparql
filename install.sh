#!/bin/sh
echo "-------------------------------------------------------------------------"
# echo "-     BUILDING the EGG"
# ./dist.sh
# echo "-------------------------------------------------------------------------"
# echo "-     INSTALLING the EGG"
# cd dist
# pip install --upgrade $(find ./cytokyotygr-*.tar.gz -mtime -3)
# echo "-     DONE"
python setup.py install
echo "-------------------------------------------------------------------------"