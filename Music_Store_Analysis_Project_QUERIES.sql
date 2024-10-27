
/* EASY */
-- 1. Who is the senior most employee based on job title?
SELECT * FROM employee
ORDER BY levels DESC
LIMIT 1;

-- 2. Which countries have the most Invoices?
SELECT billing_country, COUNT(*) AS invoices_count
FROM invoice
GROUP BY billing_country
ORDER BY invoices_count DESC;

-- 3. What are top 3 values of total invoice?
SELECT total FROM invoice
ORDER BY total DESC
LIMIT 3;

-- 4. Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals
SELECT billing_city AS best_city, SUM(total) AS money_made FROM invoice
GROUP BY billing_city
ORDER BY money_made DESC
LIMIT 1;

-- 5. Who is the best customer? The customer who has spent the most money will be declared the best customer. Write a query that returns the person who has spent the most money
SELECT c.customer_id, c.first_name, c.last_name, SUM(i.total) AS money_spent FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY money_spent DESC
LIMIT 1;

/* MODERATE */
-- 1. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A
SELECT DISTINCT c.email, c.first_name, c.last_name
FROM customer c, invoice i, invoice_line il, track t, genre g
WHERE c.customer_id = i.customer_id AND i.invoice_id = il.invoice_id AND il.track_id = t.track_id AND t.genre_id = g.genre_id AND g.name = 'Rock'
ORDER BY c.email;

-- 2. Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands
SELECT a.name, COUNT(t.track_id) AS no_of_tracks
FROM artist a, album al, track t, genre g
WHERE a.artist_id = al.artist_id AND al.album_id = t.album_id AND t.genre_id = g.genre_id AND g.name = 'Rock'
GROUP BY a.artist_id
ORDER BY no_of_tracks DESC
LIMIT 10;

-- 3. Return all the track names that have a song length longer than the average song length. Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first
SELECT name, milliseconds FROM track
WHERE milliseconds > (SELECT AVG(milliseconds) FROM track)
ORDER BY milliseconds DESC;

/* ADVANCE */
-- 1. Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent
-- For all artists
SELECT CONCAT(c.first_name, c.last_name) AS customer_name, ar.name AS artist_name, 
    SUM(il.quantity * il.unit_price) AS total_spent
FROM customer c, invoice i, invoice_line il, track t, album a, artist ar
WHERE c.customer_id = i.customer_id AND i.invoice_id = il.invoice_id AND 
    il.track_id = t.track_id AND t.album_id = a.album_id AND a.artist_id = ar.artist_id
GROUP BY customer_name, artist_name
ORDER BY artist_name;

-- For best selling artist
WITH bsa AS (SELECT ar.artist_id, ar.name AS artist_name, 
    SUM(il.quantity * il.unit_price) AS total_spent
FROM invoice i, invoice_line il, track t, album a, artist ar
WHERE i.invoice_id = il.invoice_id AND il.track_id = t.track_id AND t.album_id = a.album_id AND a.artist_id = ar.artist_id
GROUP BY artist_name, ar.artist_id
ORDER BY total_spent DESC
LIMIT 1)

SELECT CONCAT(c.first_name, c.last_name) AS customer_name, bsa.artist_name, 
    SUM(il.quantity * il.unit_price) AS total_spent
FROM customer c, invoice i, invoice_line il, track t, album a, bsa
WHERE c.customer_id = i.customer_id AND i.invoice_id = il.invoice_id AND 
    il.track_id = t.track_id AND t.album_id = a.album_id AND a.artist_id = bsa.artist_id
GROUP BY customer_name, bsa.artist_name
ORDER BY 3 DESC;

-- 2. We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres
SELECT name, billing_country, count FROM (
    SELECT g.name, i.billing_country, COUNT(il.quantity),
      RANK() OVER(PARTITION BY billing_country ORDER BY COUNT(il.quantity) DESC) AS rk
    FROM invoice i, invoice_line il, track t, genre g
    WHERE i.invoice_id = il.invoice_id AND il.track_id = t.track_id AND t.genre_id = g.genre_id
    GROUP BY g.name, i.billing_country) WHERE rk = 1;

-- 3. Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount
SELECT customer_name, country, spent FROM (
    SELECT CONCAT(c.first_name, c.last_name) AS customer_name, i.billing_country AS country,
        SUM(i.total) AS spent, RANK() OVER(PARTITION BY i.billing_country ORDER BY SUM(i.total) DESC) AS rk
    FROM customer c, invoice i
    WHERE c.customer_id = i.customer_id
    GROUP BY customer_name, i.billing_country)
WHERE rk = 1;
