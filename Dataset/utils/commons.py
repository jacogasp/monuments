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
