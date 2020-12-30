/*----------------------------------------------------------------------
 * Name: Carter Mooring
 * File: hw7.sql
 * Date: Nov. 11th, 2020
 * Class: CPSC 321 Databases
 * Description: This file use pre created and populated tables. This file has various Queries that perform the
   		    tasks commented above them and return a table populated full of the specified values.
		    The PDF with this file describes it more. 
 ----------------------------------------------------------------------*/
 
-- Start using emacs: emacs -nw hw4.sql  
-- TO Save: hold 'control' and type 'xs'
-- TO SEARCH: 'control s' to 'control g' to quit
-- end of line: 'control e'
-- recenter: 'conrtol l'

-- Queries ----------------------------------------------------------------

-- 1. Find the number of films acted in by each actor/actress ordered from highest number of films to lowest. For each actor/actress, give their first and last name and the number of films they acted in. Your query must not use comma joins, but can use “join syntax” (e.g., JOIN USING or JOIN ON).
SELECT a.first_name, a.last_name
FROM actor a JOIN film_actor f USING(actor_id)
GROUP BY(actor_id)
ORDER BY COUNT(*)
DESC LIMIT 10;


-- 2. Find the total number of films by category ordered from most to least. Give the name of each category along with the number of corresponding films. Your query must not use comma joins, but can use “join syntax” (e.g., JOIN USING or JOIN ON).
SELECT c.name
FROM film f JOIN film_category fc USING(film_id)
            JOIN category c USING(category_id)
GROUP BY category_id
ORDER BY COUNT(*) DESC LIMIT 10; 


-- 3. Find all first and last names of customers that have rented at least four ‘PG’ rated films that they payed 2.99 to rent (i.e., the payment amount was 2.99). For each customer give the number of such films they’ve rented. The result should be sorted from most rented to least rented. Your query must not use comma joins, but can use “join syntax” (e.g., JOIN USING or JOIN ON).
SELECT c.first_name, c.last_name
FROM customer c JOIN payment p USING(customer_id)
     	        JOIN rental r USING(rental_id)
 		JOIN inventory i USING(inventory_id)
 		JOIN film f USING(film_id)
WHERE f.rating = 'PG'
      AND p.amount = 2.99
GROUP BY c.customer_id 
HAVING COUNT(*) > 3
ORDER BY COUNT(*) DESC LIMIT 10; 


-- 4. Find the ‘G’ rated films that have been rented for the largest rental payment amount across all movie rentals. Return each matching film title and the corresponding rental payment amount. As part of your query, you must find the largest rental payment amount (i.e., you cannot assume this is a static or fixed value known when the query is written).
SELECT f.title, MAX(p.amount)
FROM film f JOIN inventory i USING(film_id)
     	    JOIN rental r USING(inventory_id)
	    JOIN payment p USING(rental_id)
WHERE f.rating = 'G'
GROUP BY f.film_id
HAVING MAX(p.amount) = (SELECT MAX(amount) FROM payment)
ORDER BY MAX(p.amount);


-- 5. Find the film category (or categories if there is a tie) with the most number of ‘PG’ rated films. Your query cannot use limit and must only return the categories with the most number of films (i.e., not the second most, third most, and so on). Return the category name and the corresponding number of ‘PG’ rated films.
SELECT c.name
FROM film f JOIN film_category fc USING(film_id) 
     	    JOIN category c USING(category_id)
WHERE f.rating = 'PG'
GROUP BY c.category_id
HAVING COUNT(*) >= ALL
       (SELECT COUNT(*) 
        FROM film f1 JOIN film_category fc1 USING(film_id) 
	     	     JOIN category c1 USING(category_id) 
	WHERE f1.rating = 'PG'
GROUP BY c1.category_id);


-- 6. Find the ’G’ rated film (or films if there is a tie) that have been rented more than the average number of times (for ’G’ rated movies). Return the film titles and the number of times each film has been rented ordered from most number of rentals to least.
SELECT f.title
FROM film f JOIN inventory i USING(film_id)
     	    JOIN rental r USING(inventory_id)
WHERE f.rating = 'G'
GROUP BY f.film_id
HAVING COUNT(*) > 
       (SELECT AVG(rental_count) AS rental_average
        FROM (SELECT COUNT(*) AS rental_count
	      FROM film f1 JOIN inventory i1 USING(film_id) 
	      	   	   JOIN rental r1 USING(inventory_id)
	      WHERE f1.rating = 'G'  
GROUP BY f1.film_id) t1)
ORDER BY COUNT(*) DESC LIMIT 10; 


-- 7. Write an SQL query using subqueries to find the actors/actresses that have not acted in a ‘G’ rated film.
SELECT a.first_name, a.last_name, COUNT(*)
FROM actor a
WHERE a.actor_id != ALL
      (SELECT a.actor_id
       FROM actor a JOIN film_actor fa USING (actor_id)
       	            JOIN film f USING (film_id)
       WHERE f.rating = 'G');


-- 8. Write an SQL query to find the film titles that all stores carry (i.e., in all store’s inventories). Assume there can be any number of stores (i.e., you cannot assume a certain number of stores). Your query also cannot use COUNT(). (Hint: it isn’t difficult using subqueries to find stores that don’t have a particular film.)
SELECT DISTINCT f.title
FROM film f
WHERE f.film_id NOT IN
      (SELECT f1.film_id
       FROM film f1 CROSS JOIN store s
       WHERE s.store_id NOT IN
       	     (SELECT i1.store_id
	      FROM inventory i1 JOIN film f2 USING (film_id)
	      WHERE f2.film_id = f1.film_id))
LIMIT 10;

-- 9. Write an SQL query to find the percentage of ‘G’-rated movies each actor/actress has acted in. Your query should return the id, first name, and last name of each ac- tor/actress and the corresponding percentage. Your results should order actors/actresses from highest to lowest corresponding percentage. For this query, you only need to con- sider actors/actresses that have acted in at least one ‘G’-rated movie
SELECT a.first_name, a.last_name, (COUNT(*)/total_g*100) AS percent_total_g
FROM actor a JOIN film_actor fa USING(actor_id)
     	     JOIN film f USING(film_id),
	     (SELECT COUNT(*) total_g FROM film WHERE rating='G') t1
WHERE f.rating = 'G'
GROUP BY a.actor_id 
ORDER BY COUNT(*)/total_g DESC LIMIT 10;


-- 10. Write an SQL query using an outer join to find all of the film titles that do not have any actors
SELECT f.title
FROM film f LEFT OUTER JOIN film_actor fa USING(film_id) 
EXCEPT (SELECT f.title
        FROM film f JOIN film_actor fa USING(film_id));     


-- 11. Write an SQL query using an outer join to find all of the film titles that are in a store’s inventory but that have not been rented.
SELECT f.title
FROM film f JOIN inventory i USING (film_id)
	    LEFT JOIN rental r USING (inventory_id)
GROUP BY inventory_id
HAVING COUNT(r.rental_id) = 0;


-- 12. Write an SQL query to find the number of actors that acted in each film. Return the film id and the number of associated actors. Based on your query result, how many films are there without an actor? Note that there should be more than one such film! Hint: COUNT(columname) only counts the number of non-NULL values in the values of columname.
SELECT f.film_id, COUNT(fa.actor_id)
FROM film f LEFT JOIN film_actor fa USING (film_id)
GROUP BY f.film_id
ORDER BY f.film_id LIMIT 10;


-- 13. Write a single query to find all of the movies that have the fewest number of actors and all of the movies that have the largest number of actors. Your query should return the film id, the number of actors for each such film, and the length of each film. The films should be sorted from most to fewest actors. Sort those films with the same number of actors in order of their film length (from shortest to longest). Hint: The result should have three different films, each with an actor count of 0.
SELECT f.film_id, COUNT(a.actor_id) as actor_count, f.length
FROM film f LEFT OUTER JOIN film_actor fa USING(film_id)
     	    LEFT OUTER JOIN actor a USING (actor_id)
GROUP BY film_id
HAVING COUNT(a.actor_id) >= ALL
       (SELECT COUNT(a1.actor_id)
        FROM film f1 JOIN film_actor fa1 USING(film_id)
	     	     JOIN actor a1 USING (actor_id)
	GROUP BY film_id) 
OR COUNT(a.actor_id) <= ALL
   (SELECT COUNT(a1.actor_id)
    FROM film f1 LEFT OUTER JOIN film_actor fa1 USING(film_id)
    	      	 LEFT OUTER JOIN actor a1 USING (actor_id)
    GROUP BY film_id)
ORDER BY actor_count DESC;


-- 14. Develop your own interesting “analytics” style query over the database that involves joins, aggregates, and subqueries. Explain the purpose of your query and give the result of executing it (if it is over 10 rows, provide only the first ten rows and the total number of rows of the query).
-- Find any films released after 2005 that have the  largest rental rate of any other movies. Returns the film title, actors name, rental_rate, and is sorted by rating.
SELECT f.title, a.first_name, f.rating, f.rental_rate
FROM film f JOIN film_actor fa USING(film_id)
     	    JOIN actor a USING(actor_id)
WHERE f.release_year > '2005'
GROUP BY f.rating
HAVING MAX(f.rental_rate) = (SELECT MAX(rental_rate) FROM film);
