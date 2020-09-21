-- Prefab database creation

create database prefab_sales;
use prefab_sales;

-- creating tables

CREATE TABLE Prospect (
	id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
    CHECK (name REGEXP '^[A-Za-z0-9 ąĄćĆęĘłŁńŃóÓśŚźŹżŻåÅØøæÆäÄöÖüÜß/,\.\'\-]*$'),
    address VARCHAR(255)
    CHECK (address REGEXP '^[A-Za-z0-9 ąĄćĆęĘłŁńŃóÓśŚźŹżŻåÅØøæÆäÄöÖüÜß/,\.\'\-]*$'),
    country VARCHAR(100)
    CHECK (country REGEXP '^[A-Z a-z]*$'),
    principalActivity VARCHAR(100)
    CHECK (principalActivity REGEXP '^[A-Z a-z]*$'),
    tax VARCHAR(30)
    CHECK (tax REGEXP '^[A-Z0-9]{1,26}$')
);

DROP TABLE Prospect;

CREATE TABLE PersonOfContact (
	id SERIAL PRIMARY KEY,
    firstName VARCHAR(100) NOT NULL
    CHECK (firstName REGEXP '^[A-Za-z ąĄćĆęĘłŁńŃóÓśŚźŹżŻåÅØøæÆäÄöÖüÜß\.\'\-]*$'),
    email VARCHAR(100) NOT NULL
    CHECK (email LIKE '%_@__%.__%' OR email LIKE '%#@__%.__%'),
    phoneNumber VARCHAR(20) NOT NULL
    CHECK (phoneNumber REGEXP '^[0-9]*$'),
    position VARCHAR(50)
    CHECK (position REGEXP '^[A-Z a-z]*$'),
    decisionMaker BOOLEAN,
    prospect BIGINT UNSIGNED,
    FOREIGN KEY (prospect) REFERENCES Prospect (id)
    ON DELETE SET NULL
    ON UPDATE CASCADE
);

DROP TABLE PersonOfContact;

CREATE TABLE Project (
	id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
    CHECK (name REGEXP '^[A-Za-z0-9 ąĄćĆęĘłŁńŃóÓśŚźŹżŻåÅØøæÆäÄöÖüÜß/,\.\'\-]*$'),
    location VARCHAR(100) NOT NULL
    CHECK (location REGEXP '^[A-Za-z0-9 ąĄćĆęĘłŁńŃóÓśŚźŹżŻåÅØøæÆäÄöÖüÜß/,\.\'\-]*$'),
    typeOfConstruction VARCHAR(100)
    CHECK (typeOfConstruction REGEXP '^[A-Z a-z]*$'),
    investorType ENUM ('investor', 'general', 'subcontractor'),
    projectType ENUM ('delivery', 'assembly'),
    containsDesign BOOLEAN,
    projectStatus  ENUM ('in progress', 'offer sent', 'rejected', 'approved'),
    prospect BIGINT UNSIGNED,
    FOREIGN KEY (prospect) REFERENCES Prospect (id)
    ON UPDATE CASCADE
    ON DELETE SET NULL
);

DROP TABLE Project;

CREATE TABLE SalesPerson (
	id SERIAL PRIMARY KEY,
    email VARCHAR(100) NOT NULL
    CHECK (email LIKE '%_@__%.__%' OR email LIKE '%#@__%.__%'),
	name VARCHAR(100) NOT NULL
    CHECK (name REGEXP '^[A-Za-z ąĄćĆęĘłŁńŃóÓśŚźŹżŻåÅØøæÆäÄöÖüÜß\.\'\-]*$')
);

DROP TABLE SalesPerson;

CREATE TABLE ProjectSalesPerson (
	sales_person_id BIGINT UNSIGNED NOT NULL,
    project_id BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (sales_person_id, project_id),
    FOREIGN KEY (sales_person_id) REFERENCES SalesPerson(id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
    FOREIGN KEY (project_id) REFERENCES Project(id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

DROP TABLE ProjectSalesPerson;

-- handling requirements that each project must be assigned to at least one SalesPerson
-- automatically assign new project to SalesPerson and if SalesPerson does not exist, create a SalesPerson (director)
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

DROP TRIGGER AssignNewProjectToSalesPerson;

-- when deleting last salesperson of project assign the project to director

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

DROP TRIGGER DoNotLetDeleteFromSalesPersonLeavingProjectWithNoSalesPerson;

DELIMITER //
CREATE TRIGGER DoNotLetDeleteFromProjSalesPersonLeavingProjectWithNoSalesPerson
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

DROP TRIGGER DoNotLetDeleteFromProjectSalesPersonLeavingProjectWithNoSalesPerson;