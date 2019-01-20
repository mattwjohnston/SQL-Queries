USE sakila;


# 1a. Display the first and last names of all actors from the table `actor`.
SELECT 
    first_name, last_name
FROM
    actor;


# 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT 
    UPPER(CONCAT(first_name, ' ', last_name)) as 'Actor Name'
FROM
    actor;


# 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT 
    actor_id, first_name, last_name
FROM
    actor
WHERE
    first_name = 'joe';


# 2b. Find all actors whose last name contain the letters `GEN`:
SELECT 
    first_name, last_name
FROM
    actor
WHERE
    last_name LIKE '%GEN%';


# 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
#I was a bit unsure with the wording of 2c if it wanted me to sort, but I just ordered the rows last name then first name.
SELECT 
    last_name, first_name
FROM
    actor
WHERE
    last_name LIKE '%LI%'; 


# 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT 
    country_id, country
FROM
    country
WHERE
    country IN ('Afghanistan' , 'Bangladesh', 'China');


# 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
ALTER TABLE
	actor 
ADD COLUMN (
	description BLOB
);


# 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE
	actor 
DROP COLUMN
	description;


# 4a. List the last names of actors, as well as how many actors have that last name.
SELECT 
    last_name, COUNT(*)
FROM
    actor
GROUP BY last_name;


# 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT 
    last_name, COUNT(*)
FROM
    actor
GROUP BY last_name
HAVING COUNT(*) > 1;


# 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
UPDATE actor 
SET 
    first_name = 'HARPO'
WHERE
    first_name = 'GROUCHO'
        AND last_name = 'WILLIAMS';


# 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE actor 
SET 
    first_name = 'GROUCHO'
WHERE
    first_name = 'HARPO'
        AND last_name = 'WILLIAMS';


# 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
  # Hint: [https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html](https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html)
SHOW CREATE TABLE address;


# 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
#looks like theres only 2 staff members in the original data
SELECT 
    staff.first_name, staff.last_name, address.address
FROM
    staff
        LEFT JOIN
    address ON staff.address_id = address.address_id;


# 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
#my staff data doesnt match what is in the pictures in the class files.  I re-downloaded from the SQL website and it really only includes 2, I didnt mess anything up.
SELECT 
    staff.first_name, staff.last_name, payments.total_amount
FROM
    staff
        LEFT JOIN
    (SELECT 
        SUM(amount) AS total_amount, staff_id
    FROM
        payment
    WHERE
        payment_date BETWEEN '2005-08-1 00:00:00' AND '2005-09-1 00:00:00'
    GROUP BY staff_id) AS payments ON staff.staff_id = payments.staff_id;


# 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT 
    film.title, COUNT(film_actor.actor_id)
FROM
    film
        INNER JOIN
    film_actor USING (film_id)
GROUP BY film.title;


# 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT 
    COUNT(*)
FROM
    inventory
        LEFT JOIN
    film USING (film_id)
WHERE
    film.title = 'Hunchback Impossible';


# 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT 
    customer.last_name, customer.first_name, SUM(amount)
FROM
    customer
        JOIN
    payment USING (customer_id)
GROUP BY customer_id
ORDER BY last_name;


# 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
SELECT 
    film.title
FROM
    film
WHERE
    title LIKE 'K%'
        OR title LIKE 'Q%'
        AND language_id IN (SELECT 
            language_id
        FROM
            language
        WHERE
            name = 'English');


# 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT 
    first_name, last_name
FROM
    actor
WHERE
    actor_id IN (SELECT 
            actor_id
        FROM
            film
                LEFT JOIN
            film_actor USING (film_id)
        WHERE
            film.title = 'Alone Trip');


# 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT 
    first_name, last_name, email
FROM
    customer
        LEFT JOIN
    address USING (address_id)
        LEFT JOIN
    city USING (city_id)
        LEFT JOIN
    country USING (country_id)
WHERE
    country = 'Canada';


# 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.
SELECT 
    title, name
FROM
    film
        LEFT JOIN
    film_category USING (film_id)
        LEFT JOIN
    category USING (category_id)
WHERE
    name = 'Family';


# 7e. Display the most frequently rented movies in descending order.
#using left joins: select title, count(*) from rental left join inventory using (inventory_id) left join film using (film_id) group by title order by count(*) desc;
SELECT 
    title, COUNT(*)
FROM
    film
        RIGHT JOIN
    inventory USING (film_id)
        RIGHT JOIN
    rental USING (inventory_id)
GROUP BY title
ORDER BY COUNT(*) DESC;


# 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT 
    store_id, address, SUM(amount)
FROM
    payment
        LEFT JOIN
    customer USING (customer_id)
        LEFT JOIN
    store USING (store_id)
        LEFT JOIN
    address ON store.address_id = address.address_id
GROUP BY store_id;


# 7g. Write a query to display for each store its store ID, city, and country.
SELECT 
    store_id, city, country
FROM
    store
        LEFT JOIN
    address USING (address_id)
        LEFT JOIN
    city USING (city_id)
        LEFT JOIN
    country USING (country_id);


# 7h. List the top five genres in gross revenue in descending order. (##Hint##: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT 
    SUM(amount), name
FROM
    payment
        LEFT JOIN
    rental USING (rental_id)
        LEFT JOIN
    inventory USING (inventory_id)
        LEFT JOIN
    film_category USING (film_id)
        LEFT JOIN
    category USING (category_id)
GROUP BY name
ORDER BY SUM(amount) DESC
LIMIT 5;


# 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW Top_Five AS
    SELECT 
        SUM(amount), name
    FROM
        payment
            LEFT JOIN
        rental USING (rental_id)
            LEFT JOIN
        inventory USING (inventory_id)
            LEFT JOIN
        film_category USING (film_id)
            LEFT JOIN
        category USING (category_id)
    GROUP BY name
    ORDER BY SUM(amount) DESC
    LIMIT 5;

# 8b. How would you display the view that you created in 8a?
select * from Top_Five;


# 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW Top_Five;