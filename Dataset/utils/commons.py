"""
Author: Jacopo Gasparetto
Date: 11/07/2020
Maintainers: Jacopo Gasparetto
Filename: commons.py
"""
import requests
import json


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
    try:
        if "wikipedia" in tags:

            s = tags["wikipedia"]
            if "http" in s:
                lang = s.split(".")[0][-2:]  # e.g. "it" or "en"
                title = s.split("/")[-1]
            else:
                lang, title = s.split(':')

            lang = "it" if lang is None else lang

            if title is None:
                raise ValueError("Title is none")

            links = {lang: title}

            try:
                langlinks = wikipedia_langlinks(title, lang)
                if langlinks:
                    links.update(langlinks)
            except KeyError:
                # logger.warning(f"Cannot found other languages for '{title}'")
                pass
            return links

    except ValueError:
        logger.error("Cannot parse Wikipedia ref.: %s" % tags)
    except Exception as e:
        logger.error("Generic error: {} {}".format(e, tags))


def find_most_significant_category(tags, unique_tags):
    if isinstance(tags, str):
        tags = json.loads(tags.replace("\'", "\""))

    tag_values = list(tags.values())
    for i, value in enumerate(tag_values):
        if value == "tomb" or value == "tombstone":
            tag_values[i] = "cemetery"

    categories = list(set(tag_values) & set(unique_tags.index))
    return categories if len(categories) > 0 else None
