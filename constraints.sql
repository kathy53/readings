CREATE DATABASE readings;
-- Tables were created using python code in a jupyter notebook
-- #################################### Adding constraints 
USE readings;
USE authors;

USE connect_book_publisher;

ALTER TABLE connect_book_publisher
ADD FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id);
-- ------------------
CREATE UNIQUE INDEX book_id_index
ON books (book_id);
ALTER TABLE connect_book_publisher
ADD FOREIGN KEY (book_id) REFERENCES books(book_id);
-- 
SELECT *
FROM connect_book_publisher
WHERE book_id NOT IN (SELECT book_id FROM books);
-- --------------------------------
ALTER TABLE connect_book_author
ADD FOREIGN KEY (author_id) REFERENCES authors(author_id);
-- 
ALTER TABLE connect_book_author
ADD FOREIGN KEY (book_id) REFERENCES books(book_id);
-- -----------------------------------

ALTER TABLE books
ADD FOREIGN KEY (isbn) REFERENCES ratings(isbn);
