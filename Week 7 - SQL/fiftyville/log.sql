-- Read the crime scene logs for when the theft took place
SELECT
    *
FROM
    crime_scene_reports
WHERE
    year = 2021
    AND month = 7
    AND day = 28
    AND street = "Humphrey Street";

-- Get witness transcripts
SELECT
    *
FROM
    interviews
WHERE
    year = 2021
    AND month = 7
    AND day = 28;

-- Witness 1: within 10 mins of theft, look at the security logs
SELECT
    *
FROM
    bakery_security_logs
WHERE
    year = 2021
    AND month = 7
    AND day = 28
    AND hour = 10
    AND minute BETWEEN 15
    AND 25;

-- Witness 2: Prior to 10:15am, ATM withdrawal on Leggett Street
SELECT
    *
FROM
    atm_transactions
WHERE
    year = 2021
    AND month = 7
    AND day = 28
    AND atm_location = 'Leggett Street'
    and transaction_type = 'withdraw';

-- Witness 3: Called someone around 10:15am < 1 min for earliest flight out of FIftyville
SELECT
    *
FROM
    phone_calls
WHERE
    year = 2021
    AND month = 7
    AND day = 28
    AND duration < 60;

-- Find the person who made the phone call and licence plate scene and get list of suspect names
SELECT
    *
FROM
    people
WHERE
    license_plate IN (
        SELECT
            license_plate
        FROM
            bakery_security_logs
        WHERE
            year = 2021
            AND month = 7
            AND day = 28
            AND hour = 10
            AND minute BETWEEN 15
            AND 25
    )
    AND phone_number IN (
        SELECT
            caller
        FROM
            phone_calls
        WHERE
            year = 2021
            AND month = 7
            AND day = 28
            AND duration < 60
    );

-- We have a list of suspect names, using people id, find account number and link to transactions from Witness 2
SELECT
    *
FROM
    bank_accounts
    JOIN people ON bank_accounts.person_id = people.id
WHERE
    people.id IN(
        SELECT
            id
        FROM
            people
        WHERE
            license_plate IN (
                SELECT
                    license_plate
                FROM
                    bakery_security_logs
                WHERE
                    year = 2021
                    AND month = 7
                    AND day = 28
                    AND hour = 10
                    AND minute BETWEEN 15
                    AND 25
            )
            AND phone_number IN (
                SELECT
                    caller
                FROM
                    phone_calls
                WHERE
                    year = 2021
                    AND month = 7
                    AND day = 28
                    AND duration < 60
            )
    );

-- Match passport # of the suspected people to their flight passenger list, flight date 'tomorrow = July 29, 2021', print flights and orgin/destination airports, sort by day and time, earliest flight out (Limit 1)
SELECT
    *
FROM
    flights
    JOIN passengers ON flights.id = passengers.flight_id
    JOIN airports originAirport ON flights.origin_airport_id = originAirport.id
    JOIN airports destinationAirport ON flights.destination_airport_id = destinationAirport.id
WHERE
    passengers.passport_number IN (
        SELECT
            passport_number
        FROM
            bank_accounts
            JOIN people ON bank_accounts.person_id = people.id
        WHERE
            people.id IN(
                SELECT
                    id
                FROM
                    people
                WHERE
                    license_plate IN (
                        SELECT
                            license_plate
                        FROM
                            bakery_security_logs
                        WHERE
                            year = 2021
                            AND month = 7
                            AND day = 28
                            AND hour = 10
                            AND minute BETWEEN 15
                            AND 25
                    )
                    AND phone_number IN (
                        SELECT
                            caller
                        FROM
                            phone_calls
                        WHERE
                            year = 2021
                            AND month = 7
                            AND day = 28
                            AND duration < 60
                    )
            )
    )
    AND flights.month = 7
    AND flights.day = 29
ORDER BY
    flights.month,
    flights.day,
    flights.hour,
    flights.minute
LIMIT
    1;

-- Who the thief is: Bruce
SELECT
    people.name Thief
FROM
    people
WHERE
    passport_number IN(
        SELECT
            passport_number
        FROM
            flights
            JOIN passengers ON flights.id = passengers.flight_id
        WHERE
            passengers.passport_number IN (
                SELECT
                    passport_number
                FROM
                    bank_accounts
                    JOIN people ON bank_accounts.person_id = people.id
                WHERE
                    people.id IN(
                        SELECT
                            id
                        FROM
                            people
                        WHERE
                            license_plate IN (
                                SELECT
                                    license_plate
                                FROM
                                    bakery_security_logs
                                WHERE
                                    year = 2021
                                    AND month = 7
                                    AND day = 28
                                    AND hour = 10
                                    AND minute BETWEEN 15
                                    AND 25
                            )
                            AND phone_number IN (
                                SELECT
                                    caller
                                FROM
                                    phone_calls
                                WHERE
                                    year = 2021
                                    AND month = 7
                                    AND day = 28
                                    AND duration < 60
                            )
                    )
            )
            AND flights.month = 7
            AND flights.day = 29
        ORDER BY
            flights.month,
            flights.day,
            flights.hour,
            flights.minute
        LIMIT
            1
    );

-- What city the thief escaped to: New York City
SELECT
    destinationAirport.city Escaped_City
FROM
    flights
    JOIN passengers ON flights.id = passengers.flight_id
    JOIN airports destinationAirport ON flights.destination_airport_id = destinationAirport.id
WHERE
    passengers.passport_number IN (
        SELECT
            passport_number
        FROM
            bank_accounts
            JOIN people ON bank_accounts.person_id = people.id
        WHERE
            people.id IN(
                SELECT
                    id
                FROM
                    people
                WHERE
                    license_plate IN (
                        SELECT
                            license_plate
                        FROM
                            bakery_security_logs
                        WHERE
                            year = 2021
                            AND month = 7
                            AND day = 28
                            AND hour = 10
                            AND minute BETWEEN 15
                            AND 25
                    )
                    AND phone_number IN (
                        SELECT
                            caller
                        FROM
                            phone_calls
                        WHERE
                            year = 2021
                            AND month = 7
                            AND day = 28
                            AND duration < 60
                    )
            )
    )
    AND flights.month = 7
    AND flights.day = 29
ORDER BY
    flights.month,
    flights.day,
    flights.hour,
    flights.minute
LIMIT
    1;

-- Who is the accomplice: Robin
SELECT
    name
FROM
    people
WHERE
    phone_number IN (
        SELECT
            phone_calls.receiver
        FROM
            phone_calls
        WHERE
            caller IN (
                SELECT
                    phone_number
                FROM
                    people
                WHERE
                    passport_number IN(
                        SELECT
                            passport_number
                        FROM
                            flights
                            JOIN passengers ON flights.id = passengers.flight_id
                        WHERE
                            passengers.passport_number IN (
                                SELECT
                                    passport_number
                                FROM
                                    bank_accounts
                                    JOIN people ON bank_accounts.person_id = people.id
                                WHERE
                                    people.id IN(
                                        SELECT
                                            id
                                        FROM
                                            people
                                        WHERE
                                            license_plate IN (
                                                SELECT
                                                    license_plate
                                                FROM
                                                    bakery_security_logs
                                                WHERE
                                                    year = 2021
                                                    AND month = 7
                                                    AND day = 28
                                                    AND hour = 10
                                                    AND minute BETWEEN 15
                                                    AND 25
                                            )
                                            AND phone_number IN (
                                                SELECT
                                                    caller
                                                FROM
                                                    phone_calls
                                                WHERE
                                                    year = 2021
                                                    AND month = 7
                                                    AND day = 28
                                                    AND duration < 60
                                            )
                                    )
                            )
                            AND flights.month = 7
                            AND flights.day = 29
                        ORDER BY
                            flights.month,
                            flights.day,
                            flights.hour,
                            flights.minute
                        LIMIT
                            1
                    )
            )
            AND year = 2021
            AND month = 7
            AND day = 28
            AND duration < 60
    );