USE products;
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
-- method with order by + limit
SELECT a.model
FROM
((SELECT model, price FROM products NATURAL JOIN pc)
UNION
(SELECT model, price FROM products NATURAL JOIN notebook)
UNION
(SELECT model, price FROM products NATURAL JOIN printer)) a
ORDER BY a.price DESC
LIMIT 1;
-- method with ALL
SELECT a.model
FROM
((SELECT model, price FROM pc)
UNION
(SELECT model, price FROM notebook)
UNION
(SELECT model, price FROM printer)) a
WHERE a.price >= ALL(SELECT price FROM pc
					UNION
					SELECT price FROM notebook
					UNION
					SELECT price FROM printer);
-- find producer of color printer of the lowest price
-- method with ALL
SELECT p.producer
FROM products p, printer pr
WHERE p.model = pr.model
AND color = true
AND price <= ALL (SELECT price FROM printer WHERE color = true);
-- method with min
SELECT producer
FROM products p JOIN printer USING(model)
WHERE color = true
AND price IN (SELECT min(price) FROM printer WHERE color = true);
-- f) find producer of PC of the highest speed among these pc who has the lowest rams
-- method with ALL
SELECT producer
FROM products NATURAL JOIN pc
WHERE ram IN (SELECT min(ram) FROM pc)
AND speed >= ALL (SELECT speed FROM pc WHERE ram IN (SELECT min(ram) FROM pc));
-- method with ORDER BY
SELECT producer
FROM products
where model = (SELECT model FROM pc where ram IN (SELECT min(ram) FROM pc) ORDER BY speed DESC LIMIT 1);
 