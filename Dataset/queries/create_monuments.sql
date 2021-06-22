create table if not exists monuments as (
    with temp as (
        select osm_id,
               name,
               case
                   when d1 > d2 and d1 > d3 then amenity
                   when d2 > d1 and d2 > d3 then historic
                   when d3 > d1 and d3 > d2 then tourism
                   end          as category,
               "addr:housename" as address,
               longitude,
               latitude,
               wikipedia,
               geom
        from (
                 select m.*,
                        coalesce(c1.priority, 0) as d1,
                        coalesce(c2.priority, 0) as d2,
                        coalesce(c3.priority, 0) as d3
                 from monuments_raw m
                          left join categories c1 on m.amenity = c1.category
                          left join categories c2 on m.historic = c2.category
                          left join categories c3 on m.tourism = c3.category
             ) as t
    )
    select *
    from temp
    where category is not null
);