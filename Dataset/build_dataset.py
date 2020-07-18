"""
Author: Jacopo Gasparetto
Date: 11/07/2020
Maintainers: Jacopo Gasparetto
Filename: build_dataset.py
"""
from utils.overpass import Overpass
from utils.commons import setup_logger, get_page_id
import pandas as pd
from tqdm import tqdm
import plistlib

DB_FILE = "db.pickle"
OVERPASS_QUERY = "overpass"
MONUMENTS_CATEGORIES = "../Monuments/Support Files/MonumentCategories.plist"
INTERMEDIATE_FILE = "db_intermediate.csv"

logger = setup_logger("MonumentsDataset")


def clean_dataset(df: pd.DataFrame) -> pd.DataFrame:
    """ Get only records with tags and name"""

    logger.info("Cleaning null tags and names...")
    logger.info(f"Number of items before cleaning: {len(df)}")
    df = df[df.tags.notnull()]
    df = df[df.apply(lambda x: "name" in x.tags, axis=1)]
    logger.info(f"Number of items after cleaning: {len(df)}")
    return df


def compute_lat_lon(df: pd.DataFrame) -> pd.DataFrame:
    """Create latitude and longitude from center for Ways"""
    logger.info("Extracting latitude and longitude for Nodes and Ways...")
    df_nodes = df.query("type == 'node'").copy()
    df_ways = df.query("type == 'way'").copy()

    latitude = df_ways["center"].apply(lambda x: x["lat"])
    longitude = df_ways["center"].apply(lambda x: x["lon"])

    df_ways = df_ways.assign(latitude=latitude, longitude=longitude)
    df_nodes = df_nodes.rename(columns={"lat": "latitude", "lon": "longitude"})
    df_nodes = df_nodes[["id", "latitude", "longitude", "tags"]]
    df_ways = df_ways[["id", "latitude", "longitude", "tags"]]

    df = pd.concat([df_nodes, df_ways])
    return df


def get_item_name(df: pd.DataFrame) -> pd.DataFrame:
    logger.info("Extracting names...")
    df["name"] = df["tags"].apply(lambda x: x["name"])
    return df


def remove_not_numeric_names(df: pd.DataFrame) -> pd.DataFrame:
    numeric_names = df["name"].apply(lambda x: x.isdigit())
    df = df[~numeric_names]
    return df


def get_wikipedia(df: pd.DataFrame) -> pd.DataFrame:
    logger.info("Extracting wikipedia links...")
    tqdm.pandas()
    df["wiki"] = df["tags"].progress_apply(lambda x: get_page_id(x, logger))
    return df


def main():
    overpass = Overpass()
    overpass.cache_file = DB_FILE

    try:
        df = pd.read_csv(INTERMEDIATE_FILE)
        logger.info("Found intermediate file.")
    except (FileNotFoundError, OSError):
        df = overpass.load_dataset()
        df = clean_dataset(df)
        df = compute_lat_lon(df)
        df = get_item_name(df)
        df = remove_not_numeric_names(df)
        df = get_wikipedia(df)
        logger.info("Saving intermediate file...")
        df.to_csv(INTERMEDIATE_FILE, index=False)

    logger.info("All procedures completed.")


if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        logger.info("Interrupted by the user")
    finally:
        logger.info("Bye!")
