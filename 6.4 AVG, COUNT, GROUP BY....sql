-- 6.4.6

-- a) find average speed of pc
SELECT AVG(speed)
FROM pc;

-- b) find average speed of notebooks of price over 1000

SELECT AVG(speed)
FROM notebook
wHERE price > 1000;

-- c) find average price of PC produced by producer A

SELECT AVG(price)
FROM pc NATURAL JOIN products
WHERE producer = 'A';

SELECT AVG(price)
FROM pc NATURAL JOIN products
GROUP BY producer
HAVING(producer='A');

-- d) find average price of pc and notebooks produced by producer B 

(SELECT AVG(price), type
FROM pc NATURAL JOIN products
WHERE producer = 'B')
UNION
(SELECT AVG(price), type
FROM notebook NATURAL JOIN products
WHERE producer = 'B');

-- e) for each speed of pc find average price

SELECT AVG(price), speed
FROM pc
GROUP by speed;

-- f) for each producer find average screen of it's notebooks

SELECT producer, avg(screen)
FROM products NATURAL JOIN notebook
GROUP BY producer;

-- g) find producers that produce at least three different models of pc

SELECT a.producer
FROM
(SELECT producer, COUNT(*) as numberOfPC
FROM products
WHERE type = "pc"
GROUP BY producer) a
WHERE a.numberOfPC >= 3;

-- h) for each producer that sells pc, find the highest price of pc

SELECT producer, max(price)
FROM
(SELECT producer, type, price
FROM products NATURAL JOIN pc) a
GROUP BY producer;

-- i) for each speed of pc over 3.0 find average price

SELECT avg(price), speed
FROM pc
GROUP BY speed
HAVING (speed > 3.0);

-- j) find average hardDrive of pc produced by these producers that produce also printers

SELECT avg(hardDrive), producer
FROM pc NATURAL JOIN products
WHERE
producer IN (SELECT DISTINCT producer
FROM products
WHERE type = 'printer')
GROUP BY producer;
