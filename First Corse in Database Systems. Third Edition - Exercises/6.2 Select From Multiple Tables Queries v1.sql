use products;
-- 6.2.2
-- a) display producers and speeds of notebooks with hardDrives of value at least 100 GB
SELECT p.producer, n.speed
FROM products p, notebook n
WHERE p.model = n.model
AND n.hardDrive >= 100;
-- b) find models and prices of every product produced by producent B 
SELECT p.model, pc.price
FROM products p, pc pc
WHERE p.producer = 'B'
AND p.model = pc.model
UNION
SELECT p.model, n.price
FROM products p, notebook n
WHERE p.producer = 'B'
AND p.model = n.model
UNION
SELECT p.model, pr.price
FROM products p, printer pr
WHERE p.producer = 'B'
AND p.model = pr.model;
-- c) find producers that sells notebooks but do not sell pc (mySQL do not support except clause)
SELECT DISTINCT producer
FROM products
WHERE type = 'notebook'
AND producer NOT IN (SELECT DISTINCT producer
						FROM products
                        WHERE type = 'pc');
-- d) find hardDrives that exist in two or more pc models
SELECT hd.hardDrive
FROM (SELECT hardDrive, count(*) as amount
		FROM pc
        GROUP BY hardDrive) hd
WHERE hd.amount>=2;
-- e) find couples of pc models, which have the same speed and the same ram. One couple can be displayed only once i.e. when (i,j) exist, then (j,i) should not be displayed
SELECT pc1.model, pc2.model
FROM pc pc1, pc pc2
WHERE pc1.speed = pc2.speed
AND pc1.ram = pc2.ram
AND pc1.model < pc2.model;
-- f) find producents of at least two different pc or notebooks with speed at least 3.0
SELECT a.producer
FROM (SELECT x.producer, count(*) as amount
		FROM (
				(SELECT p.producer
				FROM products p, notebook n
				WHERE p.model = n.model
				AND n.speed >= 3.0)
				UNION ALL
				(SELECT p1.producer
				FROM products p1, pc pc
				WHERE p1.model = pc.model
				AND pc.speed >= 3.0)
			) x
        GROUP BY x.producer
        ) a
WHERE a.amount >=2;

