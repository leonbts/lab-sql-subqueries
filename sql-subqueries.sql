-- 1.
SELECT COUNT(*) AS copies_count
FROM inventory i
JOIN film f ON i.film_id = f.film_id
WHERE f.title = 'Hunchback Impossible';

-- 2.
SELECT title, length
FROM film
WHERE length > (SELECT AVG(length) FROM film);

-- 3.
SELECT a.actor_id, a.first_name, a.last_name
FROM actor a
WHERE a.actor_id IN (
    SELECT fa.actor_id
    FROM film_actor fa
    JOIN film f ON fa.film_id = f.film_id
    WHERE f.title = 'Alone Trip'
);

-- 4.
SELECT f.title
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
WHERE c.name = 'Family';

-- 5.
SELECT first_name, last_name, email
FROM customer
WHERE address_id IN (
    SELECT address_id
    FROM address
    WHERE city_id IN (
        SELECT city_id
        FROM city
        WHERE country_id = (
            SELECT country_id
            FROM country
            WHERE country = 'Canada'
        )
    )
);

-- 6.
-- Step 1: Find most prolific actor_id
WITH prolific_actor AS (
  SELECT actor_id
  FROM film_actor
  GROUP BY actor_id
  ORDER BY COUNT(film_id) DESC
  LIMIT 1
)
-- Step 2: Find films starred by that actor
SELECT f.title
FROM film f
JOIN film_actor fa ON f.film_id = fa.film_id
WHERE fa.actor_id = (SELECT actor_id FROM prolific_actor);

-- 7.
-- Step 1: Find most profitable customer_id
WITH top_customer AS (
  SELECT customer_id
  FROM payment
  GROUP BY customer_id
  ORDER BY SUM(amount) DESC
  LIMIT 1
)
-- Step 2: Find films rented by that customer
SELECT DISTINCT f.title
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
WHERE r.customer_id = (SELECT customer_id FROM top_customer);

-- 8.
WITH client_totals AS (
  SELECT customer_id AS client_id, SUM(amount) AS total_amount_spent
  FROM payment
  GROUP BY customer_id
),

average_spent AS (
  SELECT AVG(total_amount_spent) AS avg_spent FROM client_totals
)

SELECT client_id, total_amount_spent
FROM client_totals
WHERE total_amount_spent > (SELECT avg_spent FROM average_spent);