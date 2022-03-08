SELECT
    movies.title
FROM
    movies,
    people,
    stars
WHERE
    people.id = stars.person_id
    AND stars.movie_id = movies.id
    AND people.name = "Johnny Depp"
    AND movies.title IN (
        SELECT
            movies.title
        FROM
            movies,
            people,
            stars
        WHERE
            people.id = stars.person_id
            AND stars.movie_id = movies.id
            AND people.name = "Helena Bonham Carter"
    );