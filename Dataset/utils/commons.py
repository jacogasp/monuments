"""
Author: Jacopo Gasparetto
Date: 11/07/2020
Maintainers: Jacopo Gasparetto
Filename: commons.py
"""
import requests


def setup_logger(name):
    import logging
    logger = logging.getLogger(name)
    logging.basicConfig(format="%(asctime)s - %(name)-7s - %(levelname)s - %(message)s", datefmt="%Y-%m-%d %H:%M:%S")
    logger.setLevel(logging.DEBUG)
    return logger


def wikipedia_langlinks(title, lang="it") -> dict:
    url = f"https://{lang}.wikipedia.org/w/api.php"

    params = {
        "action": "query",
        "titles": title,
        "prop": "langlinks",
        "format": "json"
    }

    r = requests.get(url=url, params=params)
    r = r.json()
    page = list(r["query"]["pages"].values())[0]
    return {d["lang"]: d["*"] for d in page["langlinks"]}


def get_page_id(tags, logger):
    if "wikipedia" in tags:
        try:
            s = tags["wikipedia"]
            if "http" in s:
                lang = s.split(".")[0][-2:]  # e.g. "it" or "en"
                title = s.split("/")[-1]
            else:
                lang, title = s.split(':')
            langlinks = {}

            try:
                langlinks = wikipedia_langlinks(title, lang)
            except KeyError:
                # logger.warning(f"Cannot found other languages for '{title}'")
                pass

            langlinks[lang] = title
            return langlinks
        except ValueError:
            logger.error("Cannot parse Wikipedia ref.: %s" % tags)
