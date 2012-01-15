#!/bin/sh

# get a list of all the countries that are on the movie mojo site.

firstLine=yes
while read line
do
  if [ $firstLine = 'yes' ]
  then
    firstLine='no'

  else
    echo "Processing: $line"
    key=`echo $line | sed 's/^.*|//'`
    baseurl='http://boxofficemojo.com'
    echo "$baseurl/intl/$key/yearly/"
    curl "$baseurl/intl/$key/yearly/" > list.html
    # the number of pages we have to get:
    tidy list.html | xml fo -H | xml sel -T -t -m '//a[contains(@href,"pagenum")]' -v @href -n | sort | uniq > additionalpages.txt
    # http://boxofficemojo.com/intl/france/yearly/
    # http://boxofficemojo.com/intl/france/yearly/?yr=2011&sort=gross&order=DESC&pagenum=3&p=.htm

    mkdir -p data/$key

    # NOTE: turns out OS X sed is not quite the same as GNU sed. Working out better now that I got gnu sed in...
    # clean up with tidy (but tidy introduces extra carrage returns | select the table rows of data and format as CSV | then use sed to fix the extra carriage returns | then use sed to fix up the first line
    tidy list.html | xml fo -H | xml sel -T -t -m '//table/tr' -i 'count(./td)=5' -v "concat('\"',str:replace(./td[2],'&#10;',''),'\",\"',./td[3],'\",\"',./td[4],'\",\"',./td[5],'\"')" -n | gsed -e '/^[^,]*$/ { N; s/\n/ / }' -e ':begin 1,4 { N; s/\n//; b begin }' > data/$key/data.csv

    while read additionalpage
    do
      curl "$baseurl/$additionalpage" > list.html
      tidy list.html | xml fo -H | xml sel -T -t -m '//table/tr' -i 'count(./td)=5' -v "concat('\"',str:replace(./td[2],'&#10;',''),'\",\"',./td[3],'\",\"',./td[4],'\",\"',./td[5],'\"')" -n | gsed -e '/^[^,]*$/ { N; s/\n/ / }' -e ':begin 1,4 { N; s/\n//; b begin }' -e '1,1 d' >> data/$key/data.csv
    done < additionalpages.txt
  fi
done < data/countries.csv
#done < c.txt
