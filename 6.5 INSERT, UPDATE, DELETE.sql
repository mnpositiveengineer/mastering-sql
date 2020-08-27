use products;

-- 6.5.1

-- a) using to queries INSERT put into database fact, 
-- that model PC 1100 was produced by producer C, has speed 3.2 GHz, ram 1024, hardDrive 180 and price 2499

INSERT INTO pc (model, speed, ram, hardDrive, price)
VALUES (1100, 3.2, 1024, 180, 2499);

INSERT INTO products (model, producer, type)
VALUES (1100, 'C', 'pc');

-- b) insert into database fact, that for each pc, there is a notebook of the same producer, 
-- the same speed, hardDrive and ram, has screen of 17 cal, model is 1100 more and price is 500 more.

INSERT INTO notebook
(SELECT model+1100, speed, hardDrive, ram, 17.0, price + 500
		FROM pc);
        
INSERT INTO products
(SELECT producer, model+1100, 'notebook'
FROM pc NATURAL JOIN products);

-- c) delete from database all information about pc which has hardDrive less than 100

DELETE FROM products
WHERE model IN (SELECT model FROM pc WHERE hardDrive < 100);

DELETE FROM pc
WHERE hardDrive < 100;

-- d) delete from database all informations about notebooks produced by producers which do not produce printers

DELETE FROM notebook
WHERE model IN (SELECT model FROM products WHERE type = "notebook" AND producer NOT IN (SELECT DISTINCT producer FROM products WHERE type = 'printer'));

DELETE FROM products
WHERE model NOT IN (SELECT model FROM notebook) AND type = 'notebook';

-- e) producer A took over producer B. Update all products produced by B so that all products belong to producer A in database.

UPDATE products
SET producer = 'A' WHERE producer = 'B';

-- f) for each pc double ram and add 60 to hardDrive

UPDATE pc
SET ram = 2*ram, hardDrive = hardDrive + 60;

-- g) for each notebook produced by producer D add 1 cal to screen and reduce price of 100

UPDATE notebook
SET screen = screen + 1, price = price - 100
WHERE model IN (SELECT model FROM products WHERE producer = 'D');
