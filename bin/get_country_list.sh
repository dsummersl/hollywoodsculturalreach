#!/bin/sh

# get a list of all the countries that are on the movie mojo site.

year=$1
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
    curl "$baseurl/intl/$key/yearly/?yr=$year" > list.html

    # check that we actually got the $year back
    gotback=`tidy list.html | xml fo -H | xml sel -T -t -m '//head/title' -v "str:split(.)[1]"`

    if [ "$gotback" = "$year" ]
    then
      # the number of pages we have to get:
      tidy list.html | xml fo -H | xml sel -T -t -m '//a[contains(@href,"pagenum")]' -v @href -n | sort | uniq > additionalpages.txt
      # http://boxofficemojo.com/intl/france/yearly/?yr=2011
      # http://boxofficemojo.com/intl/france/yearly/?yr=2011&sort=gross&order=DESC&pagenum=3&p=.htm

      mkdir -p data/$key

      tidy list.html | xml fo -H | xml sel -T -t -m '//table/tr' -i 'count(./td)=5' -v "concat('START\"',str:replace(./td[2],'&#10;',''),'\",\"',./td[3],'\",\"',./td[4],'\",\"',./td[5],'\"')" -n > data/$key/$year.csv
      tidy list.html | xml fo -H | xml sel -T -t -m '//table/tr' -i 'count(./td)=4' -v "concat('START\"',str:replace(./td[2],'&#10;',''),'\",,\"',./td[3],'\",\"',./td[4],'\"')" -n >> data/$key/$year.csv

      while read additionalpage
      do
        curl "$baseurl/$additionalpage" > list.html
        tidy list.html | xml fo -H | xml sel -T -t -m '//table/tr' -i 'count(./td)=5' -v "concat('START\"',str:replace(./td[2],'&#10;',''),'\",\"',./td[3],'\",\"',./td[4],'\",\"',./td[5],'\"')" -n >> data/$key/$year.csv
        tidy list.html | xml fo -H | xml sel -T -t -m '//table/tr' -i 'count(./td)=4' -v "concat('START\"',str:replace(./td[2],'&#10;',''),'\",,\"',./td[3],'\",\"',./td[4],'\"')" -n >> data/$key/$year.csv
      done < additionalpages.txt

      # cleanup files
      # NOTE: turns out OS X sed is not quite the same as GNU sed. Working out better now that I got gnu sed in...
      # clean up with tidy (but tidy introduces extra carrage returns | select the table rows of data and format as CSV | then use sed to fix the extra carriage returns | then use sed to fix up the first line
      #cat data/$key/$year.csv | gsed -e '/^[^,]*$/ { N; s/\n/ / }' -e ':begin 1,4 { N; s/\n//; b begin }' -e '1,1 d' > t.csv

      # I had a lot of trouble getting VIM to do this command line w/o complaining - I had to pipe in, and then use the - at the end.
      rm t.csv
      cat data/$key/$year.csv | vim +"filetype off" +"g/^[^S][^T][^A]/norm kJ" +"%s/^START//" +"g/OPENING WEEKENDS/del" +"w t.csv" +"q" -u NONE -
      mv t.csv data/$key/$year.csv
    fi
  fi
done < data/countries.csv
