# __*Readings*__ project
In this project a relational database (DB) was built by using Goodreads data, to find out interest data for readers, writers, and publishers.
## DB development 
Data was fetched from https://www.kaggle.com/datasets/jealousleopard/goodreadsbooks?select=books.csv. Next, a brief EDA was performed by using python in a Jupyter notebook to clean and handle missing data using Pandas in a Jupyter notebook. Once data was optimized, I created several CSV, one for each table that will be part of the DB. The resulting data was loaded to a MySQL DB using Python and sqlalchemy.

### ER Diagram
The final DB setup is shown in figure 1. It includes two views (yellow squares) and authors_top_five table generated through some queries.
![](../er_diagram.png)
**Figure 1** - ER DB diagram  

Notes:
1. File for cleaning data and CSV generation is called generation_cvs.ipynb
2. Code to create MySQL tables could be watch on create_tables.ipynb
3. Creation of the DB and some constraints could be consulted on constraints.sql
4. ER Diagram file is readings.mwb
## Querying the DB
Production tables were created to answer hypothetical questions of interest to publishers, authors, and readers. Examples for each group are the next ones:
### Query example #1: Finding top rated books
As a reader looking for reading suggestions, we want to find books with a 5-rate, also, we would need the books' titles and authors.

    CREATE VIEW best_readings AS
    SELECT average_rating AS avg_r, title, name
    FROM ratings r
    INNER JOIN books b
    ON r.isbn = b.isbn
    INNER JOIN connect_book_author cba
    ON b.book_id = cba.book_id
    INNER JOIN authors a
    ON cba.author_id =a.author_id
    WHERE average_rating = 5
    WHIT CHECK OPTION;

### Query example #2: Reviews counts per book 
Suppose we are a writer anxious to know how many text reviews each of our books have. Also, we want to classify our results into three categories: less than 500, between 500 and 1000, and more than 1000. Because those results give us a general idea of how many people are taking time to react to our publications.
Moreover, if we have a saga, then tomes share keywords within titles, then we could filter those.

First we create a function

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
Now we apply the function to search for book titles containing "Harry Potter" 

    SELECT title, text_reviews_interval(text_reviews_count) AS r_interval
    FROM  ratings r
    INNER JOIN books b
    ON r.isbn = b.isbn
    WHERE title LIKE "%Harry Potter%";
### Query example #3: Top authors
Now, assuming we are a publisher wondering about some statistics to evaluate the performance of top writers. We could create a view with average-rating average greater than four, total rating counts, and a total of published books.
Notice that each book has an average rating, and we are fetching the average of those rating averages.

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
    ORDER BY avg_r DESC;
### Query example 4: Books reviews per year
Also, as a publisher, we want to know some statistics for a given book collection. We wonder how many books have been published per year from 1990 to 2020. And, how many ratings those batchs of book have until 2020.

    SELECT YEAR(publication_date) AS year, COUNT(*) AS total_books, SUM(ratings_count) AS total_ratings
    FROM books b
    INNER JOIN ratings r
    ON b.isbn = r.isbn
    GROUP BY YEAR(publication_date)
    HAVING year >= 1990
    ORDER BY year;
![](../trend.jpg)

**Figure 2** - Total published books per year (purple) and total ratings for each batch of books until 2020 (red), this axis is reported as thousands.

Notes:
1. To see details and more queries you can open the reading.pdf project's presentation
2. Queries code on queries.sql


## Conclusions
From a csv file was design and constructed a relational database. To developed this project different tools and frameworks were required, for example,
 a conection between jupyter notebook and workbench. Queries to the database were performed by using one or more of aggregation fuctions, joins, functions, subqueries, stored procedures, views, and triggers. Such queries retrieve valued information for readers, writers, publishers or even marketing staff. For instance, readers could find recommendation for new readings or publishers could assest athors performance. 