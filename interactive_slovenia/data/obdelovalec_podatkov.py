import csv

regije = []

with open("povprecne-neto-place-regije-2020.csv") as fd:
    rd = csv.reader(fd, delimiter="\t", quotechar='"')
    for i,row in enumerate(rd):
        if i == 0 or i == 1:
            first = False
            continue
        regije.append([row[1],row[4]])


with open("aktivno-prebivalstvo-regija-dela-2020.csv") as fd:
    rd = csv.reader(fd, delimiter="\t", quotechar='"')
    for i,row in enumerate(rd):
        if i == 0:
            continue
        regije[i-1] = regije[i-1] + row[2:]


with open("clean-podatki.tsv", 'w+') as fd:
    for regija in regije:
        row = "";
        for el in regija:
            row += el + "\t"
        row.strip()
        row += "\n"
        fd.write(row)
# Regija, povprecna placa, st delavcev v doloceni regiji
