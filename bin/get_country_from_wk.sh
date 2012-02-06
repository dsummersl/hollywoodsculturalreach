country=$1
year=$2

curl http://boxofficemojo.com/intl/$country/?yr=$year&p=.htm > list.html
