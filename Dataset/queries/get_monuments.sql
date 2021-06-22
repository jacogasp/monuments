select *
       wikipedia
from monuments
where (amenity in ({amenities}) or amenity is null)
  and (
        wikipedia is not null
        or (historic in ({categories}) or historic is null)
        or (historic is not null and amenity is not null and tourism is not null)
    );

