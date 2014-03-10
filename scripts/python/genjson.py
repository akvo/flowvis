#!/usr/bin/env python
# Parses data in csv form to json

import sys
import csv
import json

filename = "data/liberia-data.csv"
count = 10

if len(sys.argv) > 1:
    filename = sys.argv[1]
if len(sys.argv) > 2:
    count = int(sys.argv[2])

f = open(filename, "r")
fieldnames = [n.lstrip('"').rstrip().rstrip('"') for n in f.readline().split(",")]
reader = csv.DictReader(f, fieldnames=fieldnames)
out = []
while count > 0:
    od = {}
    for k,v in reader.next().items():
        if k == "Instance":
            od['id'] = v
        else:
            od[k[0].lower() + k[1:]] = v
    out.append(od)
    count -= 1
print json.dumps(out, indent=True)
