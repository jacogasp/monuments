"""
Author: Jacopo Gasparetto
Date: 11/07/2020
Maintainers: Jacopo Gasparetto
Filename: build_dataset.py
"""
from utils.commons import setup_logger, get_page_id
from utils.constants import DB_CONFIG_PATH
from utils.db_handler import DatabaseHandler
from utils.commons import load_config
from tqdm import tqdm
import pandas as pd
import dask.dataframe as dd
from dask.diagnostics import ProgressBar
from dask.multiprocessing import get

db = DatabaseHandler(**load_config(DB_CONFIG_PATH))

logger = setup_logger("MonumentsDataset")


def create_dataset() -> None:
    logger.info("Creating dataset...")
    db.execute_query_from_file("create_monuments_raw")
    db.execute_query_from_file("create_monuments")
    db.execute_query('ALTER TABLE monuments ADD PRIMARY KEY ("osm_id")')
    db.execute_query('ALTER TABLE monuments ADD FOREIGN KEY ("category") references categories(category)')


def create_categories() -> [str]:
    logger.info("Creating categories...")
    db.execute_query('DROP TABLE IF EXISTS monuments')
    db.execute_query('DROP TABLE IF EXISTS monuments_raw')
    df_cat = pd.read_csv("configs/categories.csv")
    df_cat.to_sql("categories", db.engine, if_exists="replace")
    db.execute_query('ALTER TABLE categories ADD PRIMARY KEY ("category")')
    return df_cat["category"].values


def load_dataset() -> pd.DataFrame:
    df = db.read_table("SELECT * FROM monuments")
    return df


def get_wikipedia(df: pd.DataFrame) -> pd.DataFrame:
    logger.info("Extracting wikipedia links...")
    tqdm.pandas()
    ddf = dd.from_pandas(df, npartitions=30)
    r = ddf.map_partitions(lambda _df: _df["wikipedia"].apply(lambda x: get_page_id(x, logger)))
    with ProgressBar():
        df["wiki"] = r.compute(scheduler='threads')
    return df


def main():

    # Create Monument table if not already done
    # create_categories()
    # create_dataset()

    df = load_dataset()
    logger.info(f"Found {len(df)} objects")

    df = get_wikipedia(df)
    df.to_sql("monuments", db.engine, if_exists='replace')
    import pdb; pdb.set_trace()
    # logger.info("Saving intermediate file...")
    #
    # default_categories = load_default_categories(MONUMENTS_CATEGORIES)
    # df = get_category(df, default_categories)
    #
    # logger.info(f"Final dataset size: {len(df)}")
    #
    # dataframe_to_plist(df, OUTPUT_FILE)
    # logger.info("All procedures completed.")


if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        logger.info("Interrupted by the user")
    finally:
        logger.info("Bye!")
