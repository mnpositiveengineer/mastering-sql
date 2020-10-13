-- creating triggers

USE prefab_sales;

-- 1. Each Projects must be assigned to at least one SalesPersons
-- automatically assign new Projects to SalesPersons and if SalesPersons does not exist, create a SalesPersons (director)

DROP TRIGGER IF EXISTS AssignNewProjectsToSalesPersons;

DELIMITER //
CREATE TRIGGER AssignNewProjectsToSalesPersons
AFTER INSERT ON Projects
FOR EACH ROW
BEGIN
IF NOT EXISTS (SELECT * FROM SalesPersons WHERE id = 1)
THEN
INSERT INTO SalesPersons (id, email, name)
VALUES (1, 'director@prefab.com', 'director');
END IF;
INSERT INTO ProjectsSalesPersons (sales_person_id, Projects_id)
VALUES (1, NEW.id);
END//
DELIMITER ;

-- do not let delete SalesPersons if it will leave any Projects with no SalesPersons

DROP TRIGGER IF EXISTS DoNotLetDeleteFromSalesPersonsLeavingProjectsWithNoSalesPersons;

DELIMITER //
CREATE TRIGGER DoNotLetDeleteFromSalesPersonsLeavingProjectsWithNoSalesPersons
BEFORE DELETE ON SalesPersons
FOR EACH ROW
BEGIN
IF EXISTS 
(
	SELECT * FROM 
		(SELECT Projects_id, count(sales_person_id) AS number 
		FROM ProjectsSalesPersons 
		WHERE Projects_id IN 
			(SELECT Projects_id 
			FROM ProjectsSalesPersons 
			WHERE sales_person_id = OLD.id) 
	GROUP BY Projects_id) a
	WHERE a.number = 1
)
THEN
SIGNAL SQLSTATE '45000' 
SET MESSAGE_TEXT = 'Cannot Delete SalesPersons. Projects must be assigned to at least one SalesPersons.';
END IF;
END//
DELIMITER ;

DROP TRIGGER IF EXISTS DoNotDeleteFromProjSalesPersonsLeavingProjectsWithNoSalesPersons;

DELIMITER //
CREATE TRIGGER DoNotDeleteFromProjSalesPersonsLeavingProjectsWithNoSalesPersons
BEFORE DELETE ON ProjectsSalesPersons
FOR EACH ROW
BEGIN
IF EXISTS 
(
	SELECT * FROM 
		(SELECT Projects_id, count(sales_person_id) AS number 
		FROM ProjectsSalesPersons 
		WHERE Projects_id IN 
			(SELECT Projects_id 
			FROM ProjectsSalesPersons 
			WHERE sales_person_id = OLD.sales_person_id) 
	GROUP BY Projects_id) a
	WHERE a.number = 1
)
THEN
SIGNAL SQLSTATE '45000' 
SET MESSAGE_TEXT = 'Cannot Delete SalesPersons. Projects must be assigned to at least one SalesPersons.';
END IF;
END//
DELIMITER ;

/*

DELIMITER //
CREATE TRIGGER AssignProjectsToDirectorWhenLastSalesPersonsIsDeletedFromProjects
AFTER DELETE ON SalesPersons
FOR EACH ROW
BEGIN
CREATE VIEW ProjectssWithoutSalesPersons AS
SELECT p.id FROM Projects p
LEFT JOIN ProjectsSalesPersons ps
ON p.id = ps.Projects_id
WHERE ps.sales_person_id IS NULL;
IF EXISTS (SELECT * FROM ProjectssWithoutSalesPersons)
THEN
INSERT INTO ProjectsSalesPersons
SELECT id, 1 FROM ProjectssWithoutSalesPersons;
END IF;
END//
DELIMITER ;

CREATE TRIGGER AssignProjectsToDirectorWhenLastSalesPersonsIsDeletedFromProjects
BEFORE DELETE ON SalesPersons
FOR EACH ROW
BEGIN
CREATE VIEW ProjectssWithNoSalesPersons AS
SELECT * FROM 
	(SELECT Projects_id, count(sales_person_id) AS number 
	FROM ProjectsSalesPersons 
	WHERE Projects_id IN 
		(SELECT Projects_id 
		FROM ProjectsSalesPersons 
		WHERE sales_person_id = OLD.id) 
GROUP BY Projects_id) a
WHERE a.number = 1;
IF EXISTS (SELECT * FROM ProjectssWithNoSalesPersons)
THEN
UPDATE ProjectsSalesPersons SET sales_person_id = 1
WHERE Projects_id IN (SELECT Projects_id FROM ProjectssWithNoSalesPersons);
END IF;
END//
DELIMITER ;

-- Error Code: 1422. Explicit or implicit commit is not allowed in stored function or trigger.
*/


-- 2. On update of bidelement recalculate parameters and prices of bid element
 
-- 3. On update of financialdetails recalculate all prices of all bid elements in the Projects

-- 4. Create audit table which register all offer creation (on delete, on insert)
