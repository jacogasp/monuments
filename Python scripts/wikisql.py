from GeoSearch import Geosearch
import sqlite3
from tqdm import tqdm
import os
import argparse


path = "/Users/Chioma/Documents/Programmazione/MonumentFinder/MonumentFinder/"

os.chdir(path)
p = Geosearch()

cities = ["Bologna"]  # default cities array if no arguments are paresed

db = sqlite3.connect("db.sqlite")
db.text_factory = str
c = db.cursor()


def wikiToSQL(city):
    print("Start...")

    query = "SELECT Count(*) FROM %s" % city
    c.execute(query)
    (numberOfRows,) = c.fetchone()
    print(numberOfRows)
    i = 0
    query = "SELECT * FROM %s" % city
    for row in tqdm(c.execute(query), total=numberOfRows):
        name = row[0]
        lat = row[1]
        lon = row[2]

        result = p.extractOne(lat, lon, name)
        if result:
            d = db.cursor()
            # print (query)
            d.execute(''' UPDATE ''' + city + ''' SET wiki=? WHERE nome=? ''', (result[1], name))
            # db.commit()
            i += 1
    db.commit()
    print ("Updated %d row." % i)


def set_initial_args():
    parser = argparse.ArgumentParser(description="Read geolocation from sqlite database and get wikipedia pageids.")
    parser.add_argument("--language", "-l", type=str, nargs=1, help="Set the language of wikimedia api.")
    parser.add_argument("--radius", "-r", type=int, nargs=1, help="Set the radius of search around each coordinate.")
    parser.add_argument("-cities", "-c", type=str, nargs='*', help="Set the name of the city prensent in the sqlite database.")
    parser.add_argument("--accuracy", "-a", type=int, nargs=1, help="Set the accuracy for fuzzysearch between sqlite entry name and wikipedia result.")
    args = parser.parse_args()

    if args.language:
        p.lang = args.language[0]
    if args.radius:
        p.radius = args.radius[0]
    if args.cities:
        global cities
        cities = args.cities
    if args.accuracy:
        p.fuzzyAccuracy = args.accuracy[0]


def start_geosearch():
    listofcities = ", ".join(str(x) for x in cities)
    print ("Start geosearch for [%s], radius = %d, language = \"%s\", fuzzyAccuracy = %d" % (listofcities, p.radius, p.lang, p.fuzzyAccuracy))

    for city in cities:
        wikiToSQL(city)


set_initial_args()
start_geosearch()
