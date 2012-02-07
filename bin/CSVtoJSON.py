#!/usr/bin/env python

import sys, os
import csv

if __name__ == '__main__':
    r = csv.reader(open(sys.argv[1], 'r'))
    firstRow = True
    result = "{"
    cnt = 0
    columns = []
    for row in r:
        if firstRow:
          firstRow = False
          for v in row:
              columns.append(v)
          continue
        result = result + "\"row%d\": {" % cnt
        for i in range(len(columns)):
            if len(row) < i+1:
                result = result + "\"badrow\":\"\""
                continue
            parts = row[i].split('|')
            if len(parts) > 1:
                result = result + "\"%s\": [" % (columns[i])
                for p in parts:
                    result = result +"\"%s\"," % p
                result = result[0:-1] #snap off the extra comma
                result = result + "]"
            else:
                result = result + "\"%s\": \"%s\"" % (columns[i],row[i].replace("\"",""))
            if i != len(columns)-1:
                result = result +","
        result = result + "},\n"
        cnt = cnt + 1
    result = result[0:-2] #snap off the extra comma
    result = result + "}"
    print result
