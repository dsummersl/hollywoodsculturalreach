#!/bin/sh

ls -1 public/data/*csv > csvFiles.txt
while read line
do
  json=`echo $line | sed 's/csv/json/'`
  echo "converting $line to $json"
  python bin/CSVtoJSON.py $line > $json
done < csvFiles.txt

#find public/data -maxdepth 1 -type d -exec mkdir -p {} \;
find public/data -maxdepth 2 -name \*csv > csvFiles.txt
while read line
do
  json=`echo $line | sed 's/csv/json/'`
  echo "converting $line to $json"
  python bin/CSVtoJSON.py $line > $json
done < csvFiles.txt
