"""
Author: Jacopo Gasparetto
Date: 11/07/2020
Maintainers: Jacopo Gasparetto
Filename: overpass.py
"""
import json
import os
import pandas as pd
import requests
from utils.commons import setup_logger


class Overpass:

    def __init__(
            self,
            url="http://127.0.0.1/api/interpreter",
            save_cache=True,
            query="overpass.txt",
            logger=None
    ):
        self.url = url
        self.logger = logger if logger else setup_logger(__class__.__name__)
        self.cache_file = "Dataset/db.pickle"
        self.queries_directory = "queries"
        self.query_name = query
        self.save_cache = save_cache
        self.df = None

    def load_dataset(self):
        self.logger.info("Loading dataset")
        try:
            self.load_cache()
        except (FileNotFoundError, OSError):
            self.run_query(self.query_name)
        finally:
            return self.df

    def load_cache(self):
        self.df = pd.read_pickle(self.cache_file)
        self.logger.info("Dataset loaded from cache file.")

    def load_query(self, query_name):
        query_path = os.path.join(self.queries_directory, query_name + ".txt")

        with open(query_path, 'r') as f:
            return f.read()

    def run_query(self, query_name):
        self.logger.info(f"Running Overpass query on server: {self.url}")
        query = self.load_query(query_name)
        r = requests.get(url=self.url, data=query)
        json_result = json.loads(r.content)
        self.df = pd.DataFrame(json_result["elements"])

        if self.save_cache:
            self.df.to_pickle(self.cache_file)
            self.logger.info(f"Dataset saved to cache file '{self.cache_file}'.")
