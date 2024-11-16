USE sakila;
					   
-- 1. Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.
SELECT 
    COUNT(*) AS number_of_copies
FROM inventory i
JOIN film f ON i.film_id = f.film_id
WHERE f.title = 'Hunchback Impossible';

-- 2. List all films whose length is longer than the average length of all the films in the Sakila database.-- 1. Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.
SELECT 
    title, 
    length
FROM film
WHERE length > (SELECT AVG(length) FROM film)
ORDER BY length;

-- 3. Use a subquery to display all actors who appear in the film "Alone Trip".
SELECT 
    a.actor_id, 
    a.first_name, 
    a.last_name
FROM actor AS a
JOIN film_actor fa ON a.actor_id = fa.actor_id
WHERE fa.film_id = (
	SELECT film_id 
	FROM film 
    WHERE title = 'Alone Trip');

-- 4. Sales have been lagging among young families, and you want to target family movies for a promotion. Identify all movies categorized as family films.
SELECT 
    f.title
FROM film AS f
JOIN film_category AS fc ON f.film_id = fc.film_id
JOIN category AS cat ON fc.category_id = cat.category_id
WHERE cat.name = 'Family';

-- 5. Retrieve the name and email of customers from Canada using both subqueries and joins. To use joins, you will need to identify the relevant tables and their primary and foreign keys.
SELECT 
    first_name, 
    last_name, 
    email
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

-- 6. Determine which films were starred by the most prolific actor in the Sakila database. A prolific actor is defined as the actor who has acted in the most number of films. First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.
SELECT 
    fa.actor_id, 
    COUNT(fa.film_id) AS film_count
FROM film_actor AS fa
GROUP BY fa.actor_id
ORDER BY film_count DESC
LIMIT 1;

SELECT 
    f.title
FROM film AS f
JOIN film_actor AS fa ON f.film_id = fa.film_id
WHERE fa.actor_id = (
	SELECT actor_id 
	FROM film_actor 
	GROUP BY actor_id 
	ORDER BY COUNT(film_id)
	LIMIT 1);

-- 7. Find the films rented by the most profitable customer in the Sakila database. You can use the customer and payment tables to find the most profitable customer, i.e., the customer who has made the largest sum of payments.
-- Step 1: Find the most profitable customer
SELECT 
    c.customer_id, 
    SUM(p.amount) AS total_payments
FROM customer AS c
JOIN payment AS p ON c.customer_id = p.customer_id
GROUP BY c.customer_id
ORDER BY total_payments DESC
LIMIT 1;

SELECT 
    DISTINCT f.title
FROM rental AS r
JOIN inventory AS i ON r.inventory_id = i.inventory_id
JOIN film AS f ON i.film_id = f.film_id
WHERE r.customer_id = (
	SELECT customer_id 
	FROM payment 
	GROUP BY customer_id 
	ORDER BY SUM(amount) DESC 
	LIMIT 1);

-- 8. Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client. You can use subqueries to accomplish this.
SELECT 
    customer_id, 
    total_amount_spent
FROM (
    SELECT 
        c.customer_id, 
        SUM(pay.amount) AS total_amount_spent
    FROM customer AS c
    JOIN payment AS pay ON c.customer_id = pay.customer_id
    GROUP BY c.customer_id
) AS customer_totals
WHERE total_amount_spent > (
	SELECT AVG(total_amount) 
		FROM (
			SELECT 
				SUM(amount) AS total_amount
			FROM payment
			GROUP BY customer_id
		) AS customer_avg);
