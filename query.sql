--create database
CREATE DATABASE football_ticket_booking_system
--create user table
CREATE TABLE users (
  user_id SERIAL PRIMARY KEY,
  full_name varchar(100),
  email varchar(100) NOT NULL,
  role varchar(20) NOT NULL CHECK (role IN ('Ticket Manager', 'Football Fan')),
  phone_number varchar(30)
)
-- insert user table data
INSERT INTO
  users (user_id, full_name, email, role, phone_number)
VALUES
  (
    1,
    'Tanvir Rahman',
    'tanvir@mail.com',
    'Football Fan',
    '+8801711111111'
  ),
  (
    2,
    'Asif Haque',
    'asif@mail.com',
    'Football Fan',
    '+8801722222222'
  ),
  (
    3,
    'Sajjad Rahman',
    'sajjad@mail.com',
    'Ticket Manager',
    '+8801733333333'
  ),
  (
    4,
    'Jannat Ara',
    'jannat@mail.com',
    'Football Fan',
    NULL
  );


--create matches table
CREATE TABLE matches (
  match_id int PRIMARY KEY,
  fixture varchar(100),
  tournament_category varchar(100),
  base_ticket_price decimal(10, 2),
  match_status varchar(20) NOT NULL CHECK (
    match_status IN (
      'Available',
      'Selling Fast',
      'Sold Out',
      'Postponed'
    )
  )
);


--insert data in matches table
INSERT INTO
  matches (
    match_id,
    fixture,
    tournament_category,
    base_ticket_price,
    match_status
  )
VALUES
  (
    101,
    'Real Madrid vs Barcelona',
    'Champions League',
    150.00,
    'Available'
  ),
  (
    102,
    'Man City vs Liverpool',
    'Premier League',
    120.00,
    'Selling Fast'
  ),
  (
    103,
    'Bayern Munich vs PSG',
    'Champions League',
    130.00,
    'Available'
  ),
  (
    104,
    'AC Milan vs Inter Milan',
    'Serie A',
    90.00,
    'Sold Out'
  ),
  (
    105,
    'Juventus vs Roma',
    'Serie A',
    80.00,
    'Available'
  );


--create bookings table
CREATE TABLE bookings (
  booking_id int PRIMARY KEY,
  user_id int REFERENCES users (user_id),
  match_id int REFERENCES matches (match_id),
  seat_number varchar(50),
  payment_status varchar(20) CHECK (
    payment_status IN ('Pending', 'Confirmed', 'Cancelled', 'Refunded')
  ),
  total_cost decimal(10, 2)
);


--insert data bookings table
INSERT INTO
  bookings (
    booking_id,
    user_id,
    match_id,
    seat_number,
    payment_status,
    total_cost
  )
VALUES
  (501, 1, 101, 'A-12', 'Confirmed', 150.00),
  (502, 1, 102, 'B-04', 'Confirmed', 120.00),
  (503, 2, 101, 'A-13', 'Confirmed', 150.00),
  (504, 2, 101, NULL, NULL, 150.00),
  (505, 3, 102, 'C-20', 'Pending', 120.00);

--Query 1: Retrieve all upcoming football matches belonging to the 'Champions League' 
--where the match status is 'Available'.
SELECT
  match_id,
  fixture,
  base_ticket_price
FROM
  matches
WHERE
  tournament_category = 'Champions League'
  AND match_status = 'Available';

  --Query 2: Search for all users whose full names start with 'Tanvir' or contain the phrase 'Haque' (case-insensitive).
SELECT
  user_id, full_name, email
FROM
  users
WHERE
  full_name ILIKE 'tanvir%'
  OR full_name ILIKE '%haque%';

  --Query 3: Retrieve all booking records where the payment status is missing (NULL), replacing the empty result with 'Action Required'.
SELECT
  booking_id,
  user_id,
  match_id,
  coalesce(payment_status, 'Action Required') AS payment_status
FROM
  bookings
WHERE
  payment_status IS NULL

  --Query 4: Retrieve match booking details along with the User's full name and the scheduled Match fixture teams.
SELECT
  booking_id,
  full_name,
  fixture,
  total_cost
FROM
  bookings
  INNER JOIN users USING (user_id)
  INNER JOIN matches USING (match_id);

  ---Query 5: Display a comprehensive list of all users and their booking IDs, ensuring that fans who have never bought a ticket are still listed.
SELECT
  user_id,
  full_name,
  booking_id
FROM
  users
  LEFT JOIN bookings USING (user_id);

  --Query 6: Find all ticket bookings where the total cost is strictly higher than the average cost of all ticket bookings.
SELECT
  booking_id,
  match_id,
  total_cost
FROM
  bookings
WHERE
  total_cost > (
    SELECT
      avg(total_cost)
    FROM
      bookings
  );

--Query 7: Retrieve the top 2 most expensive matches sorted by base ticket price,skipping the absolute highest premium match.
SELECT
  match_id, fixture, base_ticket_price
FROM
  matches
ORDER BY
  base_ticket_price DESC
LIMIT
  2
OFFSET
  1 ;