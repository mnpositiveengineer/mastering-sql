/* 
7.5.2: for products schema, write following requirements using triggers. Each time reject modification or revert it, when constraints are violated.
*/
use products;

-- a) when updating pc price, check if there is no pc with the same or higher speed but lower price

DELIMITER //
CREATE TRIGGER checkPCprice
BEFORE UPDATE ON pc
FOR EACH ROW
BEGIN
IF NEW.price > ANY (SELECT price FROM pc WHERE speed >= NEW.speed)
THEN 
set NEW.price = OLD.price;
set NEW.speed = OLD.speed;
SIGNAL SQLSTATE '45000' 
SET MESSAGE_TEXT = 'PC with the same or higher speed cannot have lower price. Update cancelled.';
END IF;
END//
DELIMITER ;

-- test1: should not update pc after updating

UPDATE pc SET price = 1000 WHERE model = 1234;
UPDATE pc SET price = 630 WHERE model = 1012;
UPDATE pc SET price = 1000 WHERE model IN (1100, 1006);
UPDATE pc SET price = 1000 WHERE model = 1100;
UPDATE pc SET price = 1000 WHERE model = 1006;

/* 
PROBLEM 1 [SOLVED]:
without DELIMETER command we had a syntax problem:
Error Code: 1064. You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'END' at line 1
The DELIMITER command at the beginning of these statements prevents MySQL from processing the trigger definition too soon. 
The DELIMITER command at the end of these statements returns processing to normal.
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

PROBLEM 4 [UNSOLVED]:
UPDATE pc SET price = 1000 WHERE model IN (1100, 1006) --> WE CANNOT EXECUTE SUCH QUERY AS WHEN TRYING TO UPDATE 1100 IT IS 

*/ 




