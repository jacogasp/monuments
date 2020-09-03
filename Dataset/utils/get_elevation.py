"""
File Name: get_elevation.py
Project Name:Monuments
Author: Jacopo Gasparetto
Date: 02/09/2020
"""
from tqdm import tqdm
import pandas as pd
import googlemaps
from googlemaps.exceptions import TransportError
import argparse
import os

API = os.environ["GMAPS_API"]
args = None


def main():
    gmaps = googlemaps.Client(API)
    df = pd.read_csv(args.file)

    coords = df.apply(lambda x: (x["latitude"], x["longitude"]), axis=1).to_list()
    elevation = []
    try:
        for i in tqdm(range(0, len(coords), 10)):
            if i - 10 > len(coords):
                chunk = coords[i:]
            else:
                chunk = coords[i: i + 10]
            elevation += gmaps.elevation(chunk)
    except TransportError as e:
        print(f"Failed to get elevation data: {e}")
    finally:
        elevation = [x["elevation"] for x in elevation]
        df["elevation"] = elevation

        output_file = args.file.split(".")[0] + "_elev.csv"
        df.to_csv(output_file)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--file", "-f", required=True)
    args = parser.parse_args()

    main()
    print("Bye!")
