"""
Author: Jacopo Gasparetto
Date: 11/07/2020
Maintainers: Jacopo Gasparetto
Filename: build_dataset.py
"""
from utils.overpass import Overpass
from utils.commons import setup_logger, get_page_id, find_most_significant_category
import pandas as pd
from tqdm import tqdm
import plistlib

DB_FILE = "db.pickle"
OVERPASS_QUERY = "overpass"
MONUMENTS_CATEGORIES = "../Monuments/Support Files/MonumentCategories.plist"
INTERMEDIATE_FILE = "db_intermediate.csv"
OUTPUT_FILE = "../Monuments/Support Files/Monuments.plist"
OUTPUT_FILE_CSV = "db_final.csv"
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


def load_default_categories(filepath: str) -> pd.DataFrame:
    # Load Monument Tags
    with open(filepath, "rb") as f:
        return pd.DataFrame.from_dict(plistlib.load(f)["categories"], orient="index")


def get_category(df: pd.DataFrame, default_tags) -> pd.DataFrame:
    logger.info("Getting categories...")
    significant_tags = df["tags"].apply(lambda x: find_most_significant_category(x, default_tags))
    insignificant_tags = significant_tags.isna()
    logger.info(f"Found {insignificant_tags.sum()} entries without significant categories.")

    significant_tags = significant_tags.dropna()
    logger.info(f"Number of significant tags before selection: {len(significant_tags)}")

    not_unique_categories = significant_tags.loc[significant_tags[significant_tags.apply(lambda x: len(x) > 1)].index]
    logger.info(f"{len(not_unique_categories)} entries have more than one desired category.")

    # If multiple categories occur, choose the one with the highest priority
    def choose_category(categories):
        return default_tags.loc[categories].priority.idxmax()

    significant_tags = significant_tags.apply(lambda x: x[0])
    filtered_categories = not_unique_categories.apply(choose_category)
    significant_tags.loc[filtered_categories.index] = filtered_categories

    df = df.assign(category=significant_tags).loc[significant_tags.index]
    df = df.reset_index(drop=True)
    return df


def dataframe_to_plist(df: pd.DataFrame, output_file):
    logger.info("Saving file...")

    with open(output_file, "wb") as fp:
        df.index = df.index.astype(str)
        dictionary = [{k: v for k, v in m.items() if pd.notnull(v)} for m in df.to_dict(orient='rows')]
        plistlib.dump({"monuments": dictionary}, fp)

    df.to_csv(OUTPUT_FILE_CSV, index=False)


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

    default_categories = load_default_categories(MONUMENTS_CATEGORIES)
    df = get_category(df, default_categories)

    logger.info(f"Final dataset size: {len(df)}")

    dataframe_to_plist(df, OUTPUT_FILE)
    logger.info("All procedures completed.")


if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        logger.info("Interrupted by the user")
    finally:
        logger.info("Bye!")
