-- creating triggers

USE prefab_sales;

-- 1. Each project must be assigned to at least one SalesPerson
-- automatically assign new project to SalesPerson and if SalesPerson does not exist, create a SalesPerson (director)

DROP TRIGGER IF EXISTS AssignNewProjectToSalesPerson;

DELIMITER //
CREATE TRIGGER AssignNewProjectToSalesPerson
AFTER INSERT ON Project
FOR EACH ROW
BEGIN
IF NOT EXISTS (SELECT * FROM SalesPerson WHERE id = 1)
THEN
INSERT INTO SalesPerson (id, email, name)
VALUES (1, 'director@prefab.com', 'director');
END IF;
INSERT INTO ProjectSalesPerson (sales_person_id, project_id)
VALUES (1, NEW.id);
END//
DELIMITER ;

-- do not let delete SalesPerson if it will leave any project with no Salesperson

DROP TRIGGER IF EXISTS DoNotLetDeleteFromSalesPersonLeavingProjectWithNoSalesPerson;

DELIMITER //
CREATE TRIGGER DoNotLetDeleteFromSalesPersonLeavingProjectWithNoSalesPerson
BEFORE DELETE ON SalesPerson
FOR EACH ROW
BEGIN
IF EXISTS 
(
	SELECT * FROM 
		(SELECT project_id, count(sales_person_id) AS number 
		FROM ProjectSalesPerson 
		WHERE project_id IN 
			(SELECT project_id 
			FROM ProjectSalesPerson 
			WHERE sales_person_id = OLD.id) 
	GROUP BY project_id) a
	WHERE a.number = 1
)
THEN
SIGNAL SQLSTATE '45000' 
SET MESSAGE_TEXT = 'Cannot Delete SalesPerson. Project must be assigned to at least one SalesPerson.';
END IF;
END//
DELIMITER ;

DROP TRIGGER IF EXISTS DoNotDeleteFromProjSalesPersonLeavingProjectWithNoSalesPerson;

DELIMITER //
CREATE TRIGGER DoNotDeleteFromProjSalesPersonLeavingProjectWithNoSalesPerson
BEFORE DELETE ON ProjectSalesPerson
FOR EACH ROW
BEGIN
IF EXISTS 
(
	SELECT * FROM 
		(SELECT project_id, count(sales_person_id) AS number 
		FROM ProjectSalesPerson 
		WHERE project_id IN 
			(SELECT project_id 
			FROM ProjectSalesPerson 
			WHERE sales_person_id = OLD.sales_person_id) 
	GROUP BY project_id) a
	WHERE a.number = 1
)
THEN
SIGNAL SQLSTATE '45000' 
SET MESSAGE_TEXT = 'Cannot Delete SalesPerson. Project must be assigned to at least one SalesPerson.';
END IF;
END//
DELIMITER ;

/*

DELIMITER //
CREATE TRIGGER AssignProjectToDirectorWhenLastSalesPersonIsDeletedFromProject
AFTER DELETE ON SalesPerson
FOR EACH ROW
BEGIN
CREATE VIEW ProjectsWithoutSalesPerson AS
SELECT p.id FROM Project p
LEFT JOIN ProjectSalesPerson ps
ON p.id = ps.project_id
WHERE ps.sales_person_id IS NULL;
IF EXISTS (SELECT * FROM ProjectsWithoutSalesPerson)
THEN
INSERT INTO ProjectSalesPerson
SELECT id, 1 FROM ProjectsWithoutSalesPerson;
END IF;
END//
DELIMITER ;

CREATE TRIGGER AssignProjectToDirectorWhenLastSalesPersonIsDeletedFromProject
BEFORE DELETE ON SalesPerson
FOR EACH ROW
BEGIN
CREATE VIEW ProjectsWithNoSalesPerson AS
SELECT * FROM 
	(SELECT project_id, count(sales_person_id) AS number 
	FROM ProjectSalesPerson 
	WHERE project_id IN 
		(SELECT project_id 
		FROM ProjectSalesPerson 
		WHERE sales_person_id = OLD.id) 
GROUP BY project_id) a
WHERE a.number = 1;
IF EXISTS (SELECT * FROM ProjectsWithNoSalesPerson)
THEN
UPDATE ProjectSalesPerson SET sales_person_id = 1
WHERE project_id IN (SELECT project_id FROM ProjectsWithNoSalesPerson);
END IF;
END//
DELIMITER ;

-- Error Code: 1422. Explicit or implicit commit is not allowed in stored function or trigger.
*/


-- 2. On update of bidelement recalculate parameters and prices of bid element
 
-- 3. On update of financialdetails recalculate all prices of all bid elements in the project

-- 4. Create audit table which register all offer creation (on delete, on insert)
