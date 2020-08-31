-- 7.4.1

-- write following constraints using assertions for products scheme
-- mySQL DOES NOT SUPPORT ASSERTIONS

use products;

-- a) no pc producer can produce notebooks at the same time

CREATE ASSERTION PCproducerNotNotebookProducer
CHECK (NOT EXIST (SELECT producer FROM products
WHERE type = 'pc'
AND producer IN (SELECT DISTINCT producer FROM products WHERE type = 'notebook')));

-- b) pc producer must produce notebooks with at least the same speed






