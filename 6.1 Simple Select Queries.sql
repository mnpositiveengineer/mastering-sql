use products;
-- 6.1.3
-- a) Find model, speed and hardDrive for every PC with price under 1000
SELECT model, speed, hardDrive
FROM PC
WHERE price <1000;
-- b) select the same info as in a), but change the name of column 'speed' to 'gigahertz' and column 'hardDrive' to 'gigabyte'
SELECT model, speed AS gigahertz, hardDrive AS gigabyte
FROM PC
WHERE price <1000;
-- c) find all printer producers
SELECT DISTINCT producer
FROM products
WHERE type = 'printer';
-- d) find models, ram, screen of every notebooks of price under 1500
SELECT model, ram, screen
FROM notebook
WHERE price <1500;
-- e) find every records of table printer refering to color printers
SELECT model
FROM printer
WHERE color = true;
-- f) find model, speed and hardDrive of every PC of speed 3.2 GHz and price under 2000
SELECT model, speed, hardDrive
FROM PC
WHERE speed = 3.2 AND price < 2000;