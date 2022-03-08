SELECT
    people.name
FROM
    people,
    stars,
    movies
WHERE
    people.id = stars.person_id
    AND stars.movie_id = movies.id
    AND NOT people.name = "Kevin Bacon"
    AND movies.id IN(
        SELECT
            movies.id
        FROM
            people,
            stars,
            movies
        WHERE
            people.id = stars.person_id
            AND stars.movie_id = movies.id
            AND people.name = "Kevin Bacon"
            AND people.birth = "1958"
    );