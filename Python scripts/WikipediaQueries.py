#!/usr/bin/python
# coding:utf-8
import requests
import json
from tabulate import tabulate
from fuzzywuzzy import process, fuzz


name = "Augustinermuseum"
lat = "47.9939479"
lon = "7.8525612"
radius = "1000"

ids = []
pageids = ""
table = [["Match", "Titolo", "Distanza", "UrlEng", "UrlIta"]]

url = "https://en.wikipedia.org/w/api.php"

params1 = dict(
    action="query",
    list="geosearch",
    gsradius=radius,
    gscoord=lat + "|" + lon,
    format="json",
    utf8="1"
)


def geosearch(lang):

        r = requests.get(url, params=params1)
        print (r.url)
        content = json.loads(r.content)
        # print (json.dumps(content, indent=2, sort_keys=True, ensure_ascii=False))
        print('\n')
        if lang == "it":
            pageids = ""
            for page in content["query"]["geosearch"]:
                titolo = page["title"]
                dist = "%s m" % page["dist"]
                pageid = page["pageid"]
                urlIT = "https://en.wikipedia.org/?curid=%d" % pageid
                row = ["", titolo, dist, "", urlIT]
                table.append(row)
                pageids += "%d|" % pageid
                ids.append(pageid)


def searchItaPage(pageids):
    pageids = pageids[:-1]
    params2 = dict(
        action="query",
        prop="langlinks",
        list="",
        pageids=pageids,
        llprop="url",
        lllang="it",
        format="json",
        utf8="1"
    )
    r = requests.get(url, params=params2)
    print (r.url)
    print ('\n')
    content = json.loads(r.content)
    if "query" in content:
        pages = content["query"]["pages"]
        for page in pages:
            i = 1
            for pageid in ids:
                if int(pageid) == int(page):
                    items = pages[page]
                    if "langlinks" in items:
                        urlIT = items["langlinks"][0]["url"]
                        table[i][3] = urlIT
                i += 1
    else:
        print("Nessun risultato.")


def fuzzySearch():
    names = []
    for row in table:
        names.append(row[1])  # Add all names in array of names
    bestMatch = process.extractOne(name, names, scorer=fuzz.token_set_ratio)
    if bestMatch and bestMatch[1] >= 50:
        for row in table:
            if bestMatch[0] == row[1]:
                row[0] = "%d%%  ->" % bestMatch[1]

    else:
        print("No matches.\n")


geosearch("it")

print("Searching: \"%s\"\n" % name)
fuzzySearch()
# searchItaPage(pageids)
print(tabulate(table, headers="firstrow"))
print('\n')
