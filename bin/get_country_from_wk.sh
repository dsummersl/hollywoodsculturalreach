country=$1
year=$2

curl "http://boxofficemojo.com/intl/$country/?yr=$year&p=.htm" > list.html
tidy list.html | xml fo -H > clean.html
cat clean.html | xml sel -T -t -m '//table/tr' -i 'count(./td)=6' -v './td[6]' -n > weeks.txt

mkdir -p data/$country
echo "movie,studio,grosstodate,week" > data/$country/$year.csv

while read week
do
  curl "http://boxofficemojo.com/intl/$country/?yr=$year&wk=$week&p=.htm" > list.html
  # something funky with the form
  grep -v form list.html | tidy | xml fo -H > clean.html
  cat clean.html | xml sel -T -t -m '//table/tr' -i 'count(./td)=11' -v "concat('START\"',./td[3],'\",',./td[4],',\"',./td[10],'\",',./td[11])" -n >> data/$country/$year.csv
done < weeks.txt

rm t.csv
cat data/$country/$year.csv | vim +"filetype off" +"v/^START/norm kJ" +"%s/^START//" +"w t.csv" +"q" -u NONE -
mv t.csv data/$country/$year.csv
