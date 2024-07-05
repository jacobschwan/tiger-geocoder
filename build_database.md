# Build TIGER database for Geocoding

Build and updated TIGER database for the DEGAUSS geocoder, using the degauss-org/geocoder container.

## 1. Clone degauss-org/geocoder 

Clone the github repo for building the DEGAUSS geocoder container.

```
git clone https://github.com/degauss-org/geocoder.git
```

## 2. Download required TIGER files

All the ADDR, FEATNAMES, and EDGES shape files will need to be downloaded to a single dir.  The year 2023 will be used for this example, but substitute the year as appropriate.

```
cd geocoder
mkdir TIGER2023
cd TIGER2023
```

If ftp does not work, use the following commands for HTTPs downloads

```
wget -e robots=off --output-document - https://www2.census.gov/geo/tiger/TIGER2023/ADDR/ | grep -P '(?<=href=.)tl_2023_.*.zip(?=")' -o | awk '{print "https://www2.census.gov/geo/tiger/TIGER2023/ADDR/"$1}' | xargs wget
```

```
wget -e robots=off --output-document - https://www2.census.gov/geo/tiger/TIGER2023/FEATNAMES/ | grep -P '(?<=href=.)tl_2023_.*.zip(?=")' -o | awk '{print "https://www2.census.gov/geo/tiger/TIGER2023/FEATNAMES/"$1}' | xargs wget
```

```
wget -e robots=off --output-document - https://www2.census.gov/geo/tiger/TIGER2023/EDGES/ | grep -P '(?<=href=.)tl_2023_.*.zip(?=")' -o | awk '{print "https://www2.census.gov/geo/tiger/TIGER2023/EDGES/"$1}' | xargs wget
```

## 3. Edit tiger_import script

The following paths in build/tiger_import need to be modified to work inside the container.

```
HELPER_LIB="/app/lib/geocoder/us/sqlite3.so"
SHP2SQLITE=/app/src/shp2sqlite/shp2sqlite 
```

## 4. Open bash shell inside the container

Move out of the TIGER2023 folder and back into the top level of the geocoder repository. Then run the appropriate container version with and alternate entrypoint

```
cd ../
docker run --rm --entrypoint /bin/bash -it -v $PWD:/tmp ghcr.io/degauss-org/geocoder:3.3.0
```

## 5. Unzip & load all the shape files

```
build/tiger_import /tmp/geocoder_2023.db TIGER2023
```

## 6. Update the database

Create ruby metaphones

```
build/rebuild_metaphones /tmp/geocoder_2023.db
```

Construct database indexes
```
build/build_indexes /tmp/geocoder_2023.db
```

Cluster the database according to indexes, making lookups faster
```
build/rebuild_cluster /tmp/geocoder_2023.db
```

## 7. Exit the container and clean up

Close the bash shell inside the conatiner with:

```
exit
```

Remove shape files 

```
rm -rf TIGER2023
```

Change database ownership
```
sudo chown $USER:$USER geocoder_2023.db
```


