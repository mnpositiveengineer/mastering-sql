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

CREATE ASSERTION PcproducerMustProduceNotebooksWithAtLeastTheSameSpeed
CHECK (NOT EXIST 
		(SELECT pr1.model, pr1.producer FROM pc pc NATURAL JOIN products pr1
        WHERE pc.speed > ALL (SELECT n.speed FROM notebook n NATURAL JOIN products pr2
								WHERE pr2.producer = pr1.producer)));
                                
-- c) f notebook has more ram than PC, it must have higher price at the same time

CREATE ASSERTION WhenNotebookHasMoreRamThanPcItMustHaveHigherPrice
CHECK (NOT EXIST
		(SELECT n.model FROM notebook n
			WHERE n.ram > ANY (SELECT pc.ram FROM pc pc WHERE pc.price >= n.price)));
            
-- d) if in relation products model and type exists, than it must exist also in relation of given type

CREATE ASSERTION ModelInProductsMustExistInOtherTable
CHECK (NOT EXIST (SELECT model FROM products
					WHERE (type = 'pc'
                    AND model NOT IN (SELECT model FROM pc))
                    OR (type = 'notebook'
                    AND model NOT IN (SELECT model FROM notebook))
                    OR (type = 'printer'
                    AND model NOT IN (SELECT model FROM printer)));




