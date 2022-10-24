USE readings;
-- ################## JOINS --> VIEW
-- DROP VIEW best_readings;

CREATE VIEW best_readings
AS
SELECT average_rating AS avg_r, title, name
FROM ratings r
INNER JOIN books b
ON r.isbn = b.isbn
INNER JOIN connect_book_author cba
ON b.book_id = cba.book_id
INNER JOIN authors a
ON cba.author_id =a.author_id
WHERE average_rating = 5
WITH CHECK OPTION;
--
SELECT *
FROM best_readings
LIMIT 3;

-- ######################### FUNCTION
-- Find the range for text_reviews_count, they range from 0 to 1500
SELECT DISTINCT(text_reviews_count)
FROM ratings
ORDER BY text_reviews_count;
DROP FUNCTION text_reviews_interval;
-- creating the function to determine the interval of how many text reviews has a book
DELIMITER //
CREATE FUNCTION text_reviews_interval(text_reviews_count INTEGER)
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
	DECLARE r_interval VARCHAR(50);
    IF text_reviews_count < 500 THEN
		SET r_interval = 'less than 500 text reviews';
	ELSEIF (text_reviews_count >= 500 AND text_reviews_count < 1000) THEN
		SET r_interval = 'between 500 and 1000 text reviews';
	ELSEIF text_reviews_count >= 1000 THEN
		SET r_interval = 'more than 1000 text reviews';
	END IF;
RETURN (r_interval);
END//
DELIMITER ;
-- Using the function for books related to Harry Potter
SELECT title, text_reviews_interval(text_reviews_count) AS r_interval 
FROM  ratings r
INNER JOIN books b
ON r.isbn = b.isbn
WHERE title LIKE "%Harry Potter%";

-- ######################## SUBQUERY
-- thinking as a publisher looking for authors whose name starts with S, have more than 10000 reviews 
-- and ratings above of 4.5 
SELECT a.name, average_rating AS avg_rating, ratings_count, publication_date, title
FROM authors a
INNER JOIN connect_book_author cba
ON a.author_id =cba.author_id
INNER JOIN books b
ON cba.book_id = b.book_id
INNER JOIN ratings r
ON b.isbn = r.isbn
WHERE name IN (SELECT name 
                FROM authors
                WHERE name LIKE "S%")
AND average_rating > 4.5
AND ratings_count >10000
ORDER BY avg_rating DESC;
-- ######################### STORE PROCEDURE
DROP PROCEDURE books_pages;
-- store procedure
DELIMITER //
CREATE PROCEDURE books_pages(pages_min INTEGER, pages_max INTEGER, key_word VARCHAR(50))
BEGIN
       SELECT num_pages, title
       FROM books
       WHERE num_pages BETWEEN pages_min AND (pages_max)
       AND title IN (SELECT title
                      FROM books
                      WHERE title LIKE key_word)
       ORDER BY num_pages
       LIMIT 10;
END //
DELIMITER ;
 
-- Call Stored Procedure
CALL books_pages(100, 150, '%stery%');

-- ####################### TRIGGER
-- DROP TABLE authors_top_five;
-- Create table authors_top_five
CREATE TABLE authors_top_five(
	author_id INTEGER,
    name VARCHAR(100), 
    total_ratings_count INTEGER, 
    avg_r INTEGER, 
    amount_of_published_books INTEGER,
    FOREIGN KEY (author_id)
    REFERENCES authors(author_id)
);
-- TRIGGER
-- DROP TRIGGER new_before_insert;
DELIMITER //
CREATE	TRIGGER new_before_insert
BEFORE INSERT ON authors_top_five
FOR EACH ROW
BEGIN
	IF NEW.avg_r < 4.5 THEN 
		SET NEW.avg_r = 4;
	ELSEIF NEW.avg_r >=4.5 THEN
		SET NEW.avg_r = 5;
	END IF;
END //
DELIMITER ;
-- Inserting Data in authors_top_five

INSERT INTO authors_top_five (author_id, name, total_ratings_count, avg_r, amount_of_published_books)
VALUES 
(177, 'Art Spiegelman', 111475, 4.55,	1),
(0, 'J.K. Rowling', 8882405, 4.51, 4),
(1, 'Mary GrandPré', 8882405, 4.51, 4),
(1931, 'Peter S. Beagle', 593467, 4.44, 1),
(2644, 'George R.R. Martin', 638766, 4.41, 1);

SELECT *
FROM authors_top_five;


-- ############################ Event



-- ############################ VIEW
-- DROP VIEW authors_top;

CREATE VIEW authors_top
AS
SELECT a.author_id, a.name, SUM(ratings_count) AS total_ratings_count, AVG(average_rating) AS avg_r, COUNT(a.name) AS amount_of_published_books
FROM authors a
INNER JOIN connect_book_author cba
ON a.author_id = cba.author_id
INNER JOIN books b
ON cba.book_id = b.book_id
INNER JOIN ratings r
ON b.isbn = r.isbn
WHERE average_rating > 4
AND ratings_count > 23000
AND text_reviews_count > 5000
GROUP BY author_id
ORDER BY avg_r DESC
WITH CHECK OPTION;

SELECT *
FROM authors_top;
-- ########################## Query to do vizualization
SELECT YEAR(publication_date) AS year, COUNT(*) AS total_books, SUM(ratings_count) AS total_ratings
FROM books b
INNER JOIN ratings r
ON b.isbn = r.isbn
GROUP BY YEAR(publication_date)
HAVING year BETWEEN 1990 AND 2000
ORDER BY year;
