from utils.constants import QUERIES_DIR
import sqlalchemy as sqla
from typing import Union, Any
import pandas as pd
import os


class DatabaseHandler:
    def __init__(self, username: str, password: str, database: str, host: str, port: int = 5432) -> None:
        self.engine = sqla.create_engine(
            f"postgres://{username}:{password}@{host}:{port}/{database}")

    def read_table(self, query: str) -> pd.DataFrame:
        with self.engine.connect() as conn:
            return pd.read_sql(query, conn)

    def read_table_from_query_file(self, query_name: str, **kwargs: Union[None, Any]):
        query = self.__load_query_from_file(query_name)
        if kwargs is not None:
            query = query.format(**kwargs)
        return self.read_table(query)

    def execute_query_from_file(self, query_name: str):
        self.execute_query(self.__load_query_from_file(query_name))

    def execute_query(self, query: str):
        with self.engine.connect() as conn:
            conn.execute(query)

    @staticmethod
    def __load_query_from_file(query_name: str):
        query_file = os.path.join(QUERIES_DIR, query_name + ".sql")
        with open(query_file, 'r') as f:
            return f.read()
