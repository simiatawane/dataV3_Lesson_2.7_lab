-- LAB | SQL Subqueries

Use sakila;

-- 1. Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.
SELECT COUNT(i.film_id) AS number_copies FROM sakila.inventory i
WHERE i.film_id = (
	SELECT f.film_id FROM sakila.film f
    WHERE f.title = "Hunchback Impossible");

-- 2. List all films whose length is longer than the average length of all the films in the Sakila database.
SELECT f.title, f.length FROM sakila.film f
WHERE f.length > (
	SELECT AVG(f.length) FROM sakila.film f);

-- 3. Use a subquery to display all actors who appear in the film "Alone Trip".
SELECT a.first_name, a.last_name FROM sakila.actor a
WHERE a.actor_id IN (
	SELECT fa.actor_id FROM sakila.film_actor fa
    WHERE fa.film_id = (
		SELECT f.film_id FROM sakila.film f
		WHERE f.title = "Alone Trip")
);

-- 4. Sales have been lagging among young families, and you want to target family movies for a promotion.
-- Identify all movies categorized as family films.
SELECT f.title FROM sakila.film f
WHERE f.film_id IN (
	SELECT fc.film_id FROM film_category fc
    WHERE fc.category_id = (
		SELECT c.category_id FROM sakila.category c
        WHERE c.name = "Family")
);

-- 5. Retrieve the name and email of customers from Canada using both subqueries and joins.
-- To use joins, you will need to identify the relevant tables and their primary and foreign keys.
SELECT c.first_name, c.last_name, c.email FROM sakila.customer c
WHERE c.address_id IN (
	SELECT a.address_id FROM sakila.address a
    WHERE a.city_id IN (
		SELECT ci.city_id FROM sakila.city ci
        WHERE ci.country_id = (
			SELECT co.country_id FROM sakila.country co
            WHERE co.country = "Canada"
		)
	)
);

SELECT c.first_name, c.last_name, c.email FROM sakila.customer c
JOIN sakila.address a USING (address_id)
JOIN sakila.city ci USING (city_id)
JOIN sakila.country co USING (country_id)
WHERE co.country = "Canada";

-- 6. Determine which films were starred by the most prolific actor in the Sakila database.
-- A prolific actor is defined as the actor who has acted in the most number of films.
-- First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.
SELECT f.title FROM sakila.film f
WHERE f.film_id IN (
	SELECT fa.film_id FROM sakila.film_actor fa
    WHERE fa.actor_id = (
		SELECT fa.actor_id FROM sakila.film_actor fa
        GROUP BY fa.actor_id
        ORDER BY COUNT(fa.film_id) DESC
        LIMIT 1
	)
);

-- 7. Find the films rented by the most profitable customer in the Sakila database.
-- You can use the customer and payment tables to find the most profitable customer, i.e., the customer who has made the largest sum of payments.
SELECT f.title FROM sakila.film f
WHERE f.film_id IN (
	SELECT i.film_id FROM sakila.inventory i
	WHERE i.inventory_id IN (
		SELECT r.inventory_id FROM sakila.rental r
        WHERE r.customer_id = (
			SELECT p.customer_id FROM sakila.payment p
            GROUP BY p.customer_id
            ORDER BY SUM(p.amount) DESC
            LIMIT 1
		)
	)
);

-- 8. Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client.
-- You can use subqueries to accomplish this.
SELECT customer, total_amount_spent FROM (
	SELECT p.customer_id AS customer, SUM(p.amount) AS total_amount_spent FROM sakila.payment p
	GROUP BY p.customer_id) spending
WHERE total_amount_spent > (
	SELECT AVG(total_amount_spent) FROM (
		SELECT p.customer_id, SUM(p.amount) AS total_amount_spent FROM sakila.payment p
		GROUP BY p.customer_id) average
);