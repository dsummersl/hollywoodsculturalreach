#!/bin/sh

ls -1 data/*csv > csvFiles.txt
while read line
do
  json=`echo $line | sed 's/csv/json/'`
  echo "converting $line to $json"
  python ~/Documents/classes/vizlathon/testdata/CSVtoJSON.py $line > spine-hwb/public/$json
done < csvFiles.txt

find data -maxdepth 1 -type d -exec mkdir -p spine-hwb/public/{} \;
find data -maxdepth 2 -name \*csv > csvFiles.txt
while read line
do
  json=`echo $line | sed 's/csv/json/'`
  echo "converting $line to $json"
  python ~/Documents/classes/vizlathon/testdata/CSVtoJSON.py $line > spine-hwb/public/$json
done < csvFiles.txt
