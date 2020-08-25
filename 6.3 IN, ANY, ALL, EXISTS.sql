-- 6.3.1 (
-- a) find PC producers of speed at least 3.0 (use two different methods)
-- method with IN 
SELECT producer
FROM products
WHERE model IN (SELECT model
				FROM pc
                WHERE speed>3.0);
-- method with NATURAL JOIN
SELECT p.producer
FROM products p NATURAL JOIN pc pc
WHERE pc.speed > 3.0;
-- b) find printer of maximum price
-- method with ALL
SELECT model
FROM printer
WHERE price >= ALL (SELECT price
					FROM printer);
-- method with ORDER BY
SELECT model
FROM printer
ORDER BY price DESC
LIMIT 1;
-- c) find notebooks of lower speed than any of the pc
-- method with ANY
SELECT model
FROM notebook
WHERE speed < ANY (SELECT speed
					FROM pc);
-- method with EXISTS
SELECT model
FROM notebook n
WHERE EXISTS (SELECT *
				FROM pc pc
                WHERE pc.speed > n.speed);
-- d) find model of the highest price