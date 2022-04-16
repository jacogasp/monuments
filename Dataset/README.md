# Create Monuments' Database

Monuments' database is derived from OpenStreetMap dumps, filtered and uploaded to a Postgis database.
In the first stage, the country openstreetmap is filtered by some keywords (POIs) to reduce its size using **osmium**.
In the second stage, the reduced openstreetmap file is uploaded to a postgis database by **osm2psql** utility.
---

## 1. Preparation

First, install **osmium**, **osm2psql** and **Docker**.

Ubuntu:

```shell
sudo apt update -y && sudo apt install osmium-tool osm2pgsql docker.io -y
```

Mac:

```shell
brew install wget osmium-tool osm2pgsql gdal
```

Create a new docker container pulling from `postgis/postgis` and using a custom directory as external volume for data persistence

```shell
mkdir /home/chioma/postgres/data
docker run --name postgis -v ~/Workspaces/Monuments/db_data:/var/lib/postgresql/data -e POSTGRES_PASSWORD=postgres -e POSTGRES_AUTH_METHOD=trust -d postgis/postgis
```

Install HSTORE extension to the wanted database (default postgres)

```shell
docker exec -it postgis psql -U postgres
```

```shell
postgres=\l                         # To list all database
porstres=create database monuments;
postgres=\c monuments               # To connect the database
postgres=create extension hstore;   # Install hstore extension to the database
```

---

## 2. Create the database

First, download the updated database

```shell
wget http://download.geofabrik.de/europe/italy-latest.osm.bz2
```

Then, use **osmium** to filter the database. This can take a while

```shell
osmium tags-filter italy-latest.osm.bz2  \
  wn/tourism=museum,artwork \
  wn/amenity=theatre \
  wn/historic \
  -o italy_small.osm -v
```

```shell
osm2pgsql -d monuments -H localhost -U postgres --password -x --latlong -v -p monuments -k italy_small.osm
```

---

## 3. Query the database

Create the Monuments' table running

```shell
python build_dataset.py
```

---

## 4. Convert to SPATIALite

```bash
export HOST=192.168.1.34
ogr2ogr -f SQLite -dsco SPATIALITE=yes ./monuments.sqlite PG:"host=${HOST} port=5432 dbname=monuments user=postgres password=postgres" "categories"
```

```bash
ogr2ogr -f SQLite -update ./monuments.sqlite PG:"host=${HOST} port=5432 dbname=monuments user=postgres password=postgres" "monuments"
```
