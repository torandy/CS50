SELECT
    DISTINCT people.name
FROM
    directors,
    ratings,
    people,
    movies
WHERE
    people.id = directors.person_id
    AND directors.movie_id = movies.id
    AND movies.id = ratings.movie_id
    AND ratings.rating >= 9.0;