# Create Monuments' Database


Monuments' database is derived from OpenStreetMap dumps, filtered and uploaded to a Postgis database.
In the first stage, the country openstreetmap is filtered by some keywords (POIs) to reduce its size using **osmium**.
In the second stage, the reduced openstreetmap file is uploaded to a postgis database by **osm2psql** utility.
---

# 1. Preparation
First, install **osmium**, **osm2psql** and **Docker**.

```shell
sudo apt update -y && sudo apt install osmium-tool osm2pgsql docker.io -y
```

Create a new docker container pulling from `postgis/postgis` and using a custom directory as external volume for data persistence

```shell
mkdir /home/chioma/postgres/data
docker run --name postgis -v /home/chioma/postgres/data:/var/lib/postgresql/data -e POSTGRES_PASSWORD=postgres -e POSTGRES_AUTH_METHOD=trust -d postgis/postgis
```


Install HSTORE extension to the wanted database (default postgres)

```shell
docker exec -it postgis psql -U postgre
```

```shell
postgres=\l                         # To list all database
postgres=\c db_name                 # To connect the database
postgres=create extension hstore;   # Install hstore extension to the database
```
---
# 2. Create the database

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
  -o italy_filtered.osm -v
```


```shell
osm2pgsql \
  -d postgres \       # Database name
  -H 172.17.0.2 \     # Docker container host
  -U postgres \       # User
  --password \        # Prompt password
  -x \                # Save tags as hstore
  --latlong \         # Geometries are XY points
  -v \                # Verbose
  -p monuments \      # Tables prefix
  -k italy_small.osm  # File to upload
```
---

# 3. Query the database
Create the Monuments' table using the query `Dataset/queries/create_monuments.sql` 