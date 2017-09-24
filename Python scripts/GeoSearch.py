import requests
import json


class Geosearch:
    lang = "en"
    radius = 1000
    __name = "Augustinermuseum"
    __coordinate = (44.1, 11.3)
    fuzzyAccuracy = 80

    __table = []
    __ids = []

    def set_url(self):
        if self.lang == "en":
            return "https://en.wikipedia.org/"
        if self.lang == "it":
            return "https://it.wikipedia.org/"
        if self.lang == "de":
            return "https://de.wikipedia.org/"

    def set_geosearch_params(self):
        params = dict(
            action="query",
            list="geosearch",
            gsradius=self.radius,
            gscoord=str(self.__coordinate[0]) + "|" + str(self.__coordinate[1]),
            format="json",
            utf8="1"
        )
        return params

    def set_titlesearch_params(self, name):
        params = dict(
            action="opensearch",
            search=name,
            namespace=0
        )
        return params

    def fuzzySearch(self):
        from fuzzywuzzy import process, fuzz
        names = []
        for row in self.__table:
            names.append(row[1])  # Add all names in array of names
        bestMatch = process.extractOne(self.__name, names, scorer=fuzz.token_set_ratio)
        if bestMatch and bestMatch[1] >= self.fuzzyAccuracy:
            for row in self.__table:
                if bestMatch[0] == row[1]:
                    row[0] = "%d%%  ->" % bestMatch[1]
                    return (bestMatch[0], row[3])
        """
        else:
            print("No matches.\n")
        """
    def geosearch(self):
            self.__table = []
            url = self.set_url()
            apiUrl = url + "w/api.php"
            params = self.set_geosearch_params()

            r = requests.get(apiUrl, params=params)
            # print (r.url)
            content = json.loads(r.content)
            # print (json.dumps(content, indent=2, sort_keys=True, ensure_ascii=False))

            for page in content["query"]["geosearch"]:
                titolo = page["title"]
                dist = "%s m" % page["dist"]
                pageid = page["pageid"]
                localizedPageId = "%s:%s" % (self.lang, pageid)
                result = "%s?curid=%d" % (url, pageid)
                row = ["", titolo, dist, localizedPageId, result]
                self.__table.append(row)

    def titlesearch(self, name):
        url = self.set_url()
        apiUrl = url + "w/api.php"
        params = self.set_titlesearch_params(name)
        r = requests.get(apiUrl, params=params)
        content = json.loads(r.content)
        print (json.dumps(content, indent=2, sort_keys=True))

    def printResults(self, lat, lon, name):
        newcoordinate = (lat, lon)
        self.__coordinate = newcoordinate
        self.__name = name
        self.fuzzySearch()
        from tabulate import tabulate
        self.geosearch()
        print(tabulate(self.__table, headers=["Match", "Titolo", "Distanza", "PageId", "Url"]))

    def extractOne(self, lat, lon, name):
        newcoordinate = (lat, lon)
        self.__name = name
        self.__coordinate = newcoordinate
        self.geosearch()
        return self.fuzzySearch()


g = Geosearch()
g.lang = "it"
g.titlesearch("Museo Archeologico")
