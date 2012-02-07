country=$1
year=$2

curl "http://boxofficemojo.com/intl/$country/?yr=$year&p=.htm" > list.html
tidy list.html | xml fo -H > clean.html
cat clean.html | xml sel -T -t -m '//table/tr' -i 'count(./td)=6' -v './td[6]' -n > weeks.txt

mkdir -p public/data/$country
rm public/data/$country/$year.csv
touch public/data/$country/$year.csv

while read week
do
  curl "http://boxofficemojo.com/intl/$country/?yr=$year&wk=$week&p=.htm" > list.html
  # something funky with the form
  grep -v form list.html | tidy | xml fo -H > clean.html

  # I don't know what all the columns look like - this extracts the whole <table>, as long as its first row has at least 10 columns
  columns=`cat clean.html | xml sel -T -t -m '//table' -i 'count(./tr[2]/td)>=10' -v 'count(./tr[2]/td)'`
  val="concat('START\"'"
  for i in `seq 1 $columns`
  do
    if [ $i -eq $columns ]
    then
      val="$val,./td[$i],'\"')"
    else
      val="$val,./td[$i],'\",\"'"
    fi
  done
  # do 9 instead of 10 b/c someimtes the header is smaller for some reason..
  cat clean.html | xml sel -T -t -m '//table/tr' -i 'count(./td)>=9' -v $val -n >> public/data/$country/$year.csv
done < weeks.txt

rm t.csv
cat public/data/$country/$year.csv | vim +"filetype off" +"v/^START/norm kJ" +"%s/^START//" +"w t.csv" +"q" -u NONE -
mv t.csv public/data/$country/$year.csv
