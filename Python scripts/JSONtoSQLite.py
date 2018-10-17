""" Esegue una overpass_query per ogni città e salva i risultati su una nuova tabella
    del database sqlite.
    TODO: scrivere tutti i risultati su un csv
"""

import json
import sqlite3
import csv
import requests
import os
from operator import itemgetter
from tqdm import tqdm

# Database
# cities = ["Bologna", "Roma", "Milano", "Firenze", "Parma", "Palermo", "Venezia", "Padova", "Ravenna", "Perugia", "Napoli", "Catania", "Messina", "Perugia", "Ferrara"]

cities = ["Freiburg"]

table_name = ""
# table_name = "Roma"

path = '/Users/Chioma/Documents/Programmazione/JSONtoSQLite/'
os.chdir(path)

db = sqlite3.connect('db.sqlite')
db.text_factory = str
c = db.cursor()


def readQuery():  # File query
    data = open('overpass_query.txt')
    query = data.read().replace(' ', '').replace('\n', '')
    query = query.replace('outcenter', 'out%20center').replace('outqt', 'out%20qt').replace('table_name', table_name)
    # print(query)
    return query


def sendQuery():  # Esegue la query
    query = readQuery()
    content = requests.get(query)
    # print content.text.encode('utf-8')
    return json.loads(content.text)


def saveJson():
    query = readQuery()
    content = requests.get(query)
    with open('json.txt', 'w') as outfile:
        json.dumps(content, outfile)


def createDB():  # Path db, se non esiste lo crea
    c.execute('''CREATE TABLE IF NOT EXISTS ''' + table_name + ''' (nome text, lat real, lon real, tag text, wiki text)''')
    c.execute('''DELETE FROM ''' + table_name)
    db.commit()


def leggiCSV():
    with open('/Users/Chioma/Documents/Programmazione/MonumentFinder/MonumentFinder/MonumentTags.csv') as csvfile:
        reader = csv.DictReader(csvfile, delimiter=';')
        data = {}
        for row in reader:
            for header, value in row.items():

                try:
                    data[header].append(value)
                except KeyError:
                    data[header] = [value]
    categories = map(lambda x, y: (x, y), data['OSMtags'], data['Peso'])

    return categories


def findTag(tags):
    categories = leggiCSV()
    matches = [(tag.encode('utf-8'), category[1]) for tag in tags for category in categories if tag == category[0]]
    if len(matches) > 0:
        # print ('\n tags: ' + str(tags) + ' matches: ' + str(matches))
        tag = max(matches, key=itemgetter(1))[0]
    else:
        tag = "Generico"
    return tag


def scriviSQL():
    elements = sendQuery()
    # jsonTxt = open('JSONtoSQLite/json.txt')
    # elements = json.load(jsonTxt)
    counts = 0
    for element in elements['elements']:
        if element['type'] == 'node':
            if 'tags' in element:
                if 'name' in element['tags']:
                    name = element['tags']['name'].encode('utf-8')
                    latitude = element['lat']
                    longitude = element['lon']

                    tags = [tag for tag in element['tags'].values()]
                    tag = findTag(tags)
                    wikiurl = ""
                    if 'wikipedia' in element['tags']:
                        wikiurl = element['tags']['wikipedia'].encode('utf-8')

                    # print ("%s lat: %d, lon: %d, tag: %s, wikiurl: %s" % (name, latitude, longitude, tag, wikiurl))
                    c.execute("INSERT INTO " + table_name + " VALUES (?, ?, ?, ?, ?)", (name, latitude, longitude, tag, wikiurl))
                    db.commit()
                    counts += 1

        if element['type'] == 'way':
            if 'tags' in element:
                if 'name' in element['tags']:
                    name = element['tags']['name'].encode('utf-8')
                    latitude = element['center']['lat']
                    longitude = element['center']['lon']

                    tags = [tag for tag in element['tags'].values()]
                    tag = findTag(tags)
                    wikiurl = ""
                    if 'wikipedia' in element['tags']:
                        wikiurl = element['tags']['wikipedia'].encode('utf-8')

                    # print ("%s lat: %d, lon: %d, tag: %s, wikiurl: %s" % (name, latitude, longitude, tag, wikiurl))
                    c.execute("INSERT INTO " + table_name + " VALUES (?, ?, ?, ?, ?)", (name, latitude, longitude, tag, wikiurl))
                    db.commit()
                    counts += 1
    print ("%d elementi scritti sul database" % counts)


for city in tqdm(cities):
    print ("Query per %s" % city)
    table_name = city
    createDB()
    scriviSQL()
    print city + " completata."
