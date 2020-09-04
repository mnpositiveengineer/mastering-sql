/* 
7.5.2: for products schema, write following requirements using triggers. Each time reject modification or revert it, when constraints are violated.
*/
use products;

-- a) when updating pc price, check if there is no pc with higher speed but lower price and no pc with lower speed but higher price

DELIMITER //
CREATE TRIGGER checkPCprice
BEFORE UPDATE ON pc
FOR EACH ROW
BEGIN
IF NEW.price > ANY (SELECT price FROM pc WHERE speed > NEW.speed)
OR NEW.price < ANY (SELECT price FROM pc WHERE speed < NEW.speed)
THEN 
SIGNAL SQLSTATE '45000' 
SET MESSAGE_TEXT = 'PC with the same or higher speed cannot have lower price. Update cancelled.';
END IF;
END//
DELIMITER ;

DROP TRIGGER checkPCprice;

-- preparing data

delete from pc;
delete from products where type = 'pc';
INSERT INTO products (model, producer, type)
VALUES (1000, 'A', 'pc'), (1001, 'B', 'pc'), (1002, 'C', 'pc');
INSERT INTO pc (model, speed, price)
VALUES (1000, 1, 100), (1001, 2, 200), (1002, 3, 300);
INSERT INTO products (model, producer, type)
VALUES (1003, 'D', 'pc'), (1004, 'D', 'pc');
INSERT INTO pc (model, speed, price)
VALUES (1003, 4, 400), (1004, 4, 400);

-- test1: should not update pc after updating
UPDATE pc
SET price = 301 WHERE model = 1001;
UPDATE pc
SET price = 99 WHERE model = 1001;

-- test2: should be able to update pc
UPDATE pc
SET price = 300 WHERE model = 1001;
UPDATE pc
SET price = 100 WHERE model = 1001;
UPDATE pc
SET price = 200 WHERE model = 1001;
UPDATE pc
SET price = 500 WHERE model = 1004;

-- test1: should not update pc after updating
UPDATE pc
set price = 299 WHERE model = 1004;


/* 
PROBLEM 1 [SOLVED]:
without DELIMETER command we had a syntax problem:
Error Code: 1064. You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'END' at line 1
In SQL you close each statement with a delimiter, which is by default a semicolon (;). 
In a trigger you need to write multiple statements, each ending in a semicolon. 
To tell MySQL that those semicolons are not the end of your trigger statement, you temporarily change the delimiter from ; to //, 
so MySQL will know that the trigger statement only ends when it econunters a //.

PROBLEM 2 [SOLVED]:
It seems like CREATE TRIGGER action is run every time we click to run every query further in the code
IT WAS SOLVED USING DELIMETER //

PROBLEM 3[SOLVED]:
Error Code: 1442. Can't update table 'pc' in stored function/trigger because it is already used by statement which invoked this stored function/trigger.
Updating the table from a trigger would then cause the same trigger to fire again in an infinite recursive loop.
we have to change action in trigger so it is not update after update ufter update...
instead of trying to update or delete and insert as an action we changes AFTER to BEFORE and we set NEW.price = OLD.price and NEW.speed = OLD.speed

PROBLEM 4 [SOLVED]:
UPDATE pc SET price = 1000 WHERE model IN (1100, 1006) --> WE CANNOT EXECUTE SUCH QUERY AS WHEN TRYING TO UPDATE 1100 IT IS 
We changed the action to:

IF NEW.price > ANY (SELECT price FROM pc WHERE speed > NEW.speed)
OR NEW.price < ANY (SELECT price FROM pc WHERE speed < NEW.speed)

so that no checkings on records with the same speed are take into consideration

*/ 

-- b) while inserting new printer check if in table products such model exists. If not - insert the model into table products.

DELIMITER $$
CREATE TRIGGER checkPrinterInProducts
BEFORE INSERT ON printer
FOR EACH ROW
BEGIN
IF NEW.model NOT IN (SELECT model FROM products WHERE type = 'printer')
THEN
INSERT INTO products (model, type)
VALUES (NEW.model, 'printer');
SIGNAL SQLSTATE '01000'
SET MESSAGE_TEXT = 'Printer was not included in products table. Updated products table of new printer. Make sure to set producer.';
END IF;
END$$
DELIMITER ;

DROP TRIGGER checkPrinterInProducts;

-- test1: should insert printer into table printer and products

delete from printer;
delete from products where type = 'printer';

INSERT INTO printer (model)
VALUES (3000);

/*
About SIGNALS:
sqlstate's starting with 45 (SIGNAL SQLSTATE '45000')  are errors and terminate the procedure. 
sqlstate's starting with 01 (SIGNAL SQLSTATE '01000') are warnings and allow the procedure to continue.
The warning does not terminate the procedure, and can be seen with SHOW WARNINGS after the procedure returns.

PROBLEM 1 [UNSOLVED]

SIGNAL SQLSTATE '01000' is not displayed on the screen.

*/

-- c) while updating table notebooks, check if average price of notebooks of each producer is less than 1500

DELIMITER %%
CREATE TRIGGER checkAveragePriceOfNotebooks
AFTER UPDATE ON notebook
FOR EACH ROW
BEGIN
IF (1500 < ANY (SELECT AVG(price) FROM notebook NATURAL JOIN products GROUP BY producer))
THEN
DELETE FROM notebook WHERE model = NEW.model;
INSERT INTO notebook (model, price) VALUES (OLD.model, OLD.price);
SIGNAL SQLSTATE '02000' 
SET MESSAGE_TEXT = 'Average price of notebooks for each producer cannot exceed 1500';
END IF;
END %%
DELIMITER ;

DROP TRIGGER checkAveragePriceOfNotebooks;

-- preparing test data
delete from notebook;
delete from products where type = 'notebook';

INSERT INTO products (model, producer, type)
VALUES 
(2001, 'A', 'notebook'), 
(2002, 'A', 'notebook'), 
(2003, 'B', 'notebook'), 
(2004, 'B', 'notebook'), 
(2005, 'C', 'notebook'), 
(2006, 'C', 'notebook');

INSERT INTO notebook (model, price)
VALUES
(2001, 1000),
(2002, 2000),
(2003, 1000),
(2004, 2000),
(2005, 1000),
(2006, 2000);

-- test1: should not update price of notebooks

UPDATE notebook
SET price = 3000 WHERE model = 2002;

/*
PROBLEM 1 [UNSOLVED]

Error Code: 1442. 
Can't update table 'notebook' in stored function/trigger because it is already used by statement which invoked this stored function/trigger.

The truth is that the current trigger is using table "notebook", there is no chance to use it in this invoking procedure.
*/

-- d) while updating ram or hardDrive check, if updated PC has hardDrive at least 100 times bigger than ram

DELIMITER **
CREATE TRIGGER checkRamAndHardDrive
BEFORE UPDATE ON pc
FOR EACH ROW
BEGIN
IF (NEW.ram/10 > NEW.hardDrive)
THEN
SIGNAL SQLSTATE '02000' 
SET MESSAGE_TEXT = 'hardDrive must be at least 100 times bigger.';
END IF;
END**
DELIMITER ;
 
DROP TRIGGER checkRamAndHardDrive;

-- test1: should not update pc

UPDATE pc SET ram = 1024, hardDrive = 100 WHERE model = 1000;

-- test2: should update pc

UPDATE pc SET ram = 1024, hardDrive = 200 WHERE model = 1000;

-- e) while inserting entry of new pc, notebook or printer verify if this model does not exist in other relations (pc, printer, notebook).

DELIMITER !!
CREATE TRIGGER checkIfSuchModelDoesNotExistInOtherRelation
BEFORE INSERT ON products
FOR EACH ROW
BEGIN
IF ((NEW.type = 'pc' AND NEW.model IN ((SELECT model FROM printer) UNION (SELECT model FROM notebook)))
OR (NEW.type = 'printer' AND NEW.model IN ((SELECT model FROM notebook) UNION (SELECT model FROM pc)))
OR (NEW.type = 'notebook' AND NEW.model IN ((SELECT model FROM pc) UNION (SELECT model FROM printer))))
THEN
SIGNAL SQLSTATE '45000' 
SET MESSAGE_TEXT = 'This mnumber of model is already assigned to other type';
END IF;
END!!
DELIMITER ;

DROP TRIGGER checkIfSuchModelDoesNotExistInOtherRelation;
DELETE FROM products;

-- test 1: should not insert to product table

INSERT INTO products (model, type)
VALUES (3000, 'pc');

INSERT INTO products (model, type)
VALUES (3000, 'notebook');

INSERT INTO products (model, type)
VALUES (1000, 'printer');

INSERT INTO products (model, type)
VALUES (1000, 'notebook');

INSERT INTO products (model, type)
VALUES (2001, 'printer');

INSERT INTO products (model, type)
VALUES (2001, 'pc');

