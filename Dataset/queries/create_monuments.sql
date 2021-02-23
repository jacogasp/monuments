create table if not exists monuments as (
    with osm_points as (
        select osm_id,
               name,
               amenity,
               historic,
               tourism,
               "addr:housename",
               "addr:housenumber",
               -- ele,
               st_x(st_transform(way, 4326)) as longitude,
               st_y(st_transform(way, 4326)) as latitude,
               tags -> 'wikipedia'           as wikipedia,
               way as geom
        from monuments_point
        where name is not null
          and (historic in ('memorial', 'wayside_shrine', 'monument', 'archaeological_site', 'ruins',
                            'tomb', 'castle', 'city_gate', 'church', 'battlefield', 'fort', 'aircraft',
                            'monastery', 'aqueduct', 'bunker', 'citywalls', 'bridge', 'chapel')
            or amenity in
               ('theatre', 'place_of_worship', 'fountain', 'monastery', 'arts_centre', 'university')
            or "tower:type" is not null
            or tourism in ('artwork', 'museum'))
    ),
         osm_polygons as (
             select osm_id,
                    name,
                    amenity,
                    historic,
                    tourism,
                    "addr:housename",
                    "addr:housenumber",
                    st_x(st_centroid(st_transform(way, 4326))) as longitude,
                    st_y(st_centroid(st_transform(way, 4326))) as latitude,
                    tags -> 'wikipedia'                        as wikipedia,
                    st_centroid(way) as geom
             from monuments_polygon
             where name is not null
               and (historic in ('memorial', 'wayside_shrine', 'monument', 'archaeological_site', 'ruins',
                                 'tomb', 'castle', 'city_gate', 'church', 'battlefield', 'fort', 'aircraft',
                                 'monastery', 'aqueduct', 'bunker', 'citywalls', 'bridge', 'chapel')
                 or amenity in
                    ('theatre', 'place_of_worship', 'fountain', 'monastery', 'arts_centre', 'university')
                 or "tower:type" is not null
                 or tourism in ('artwork', 'museum'))
         )


    select *
    from osm_points
    union
    select *
    from osm_polygons
)