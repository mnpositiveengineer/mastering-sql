-- 8.1.1 using hollywood database , create following views
use hollywood;
-- a) view RichProducers, containing names, adresses, certificates and salaries all producers of salray at leas 10 000 000

CREATE VIEW RichProducers AS
SELECT * FROM filmproducer
WHERE salary >= 10000000;

SELECT * FROM RichProducers;

INSERT INTO filmproducer (name, certificate, salary) VALUES ('test', 1, 10000000), ('test2', 2, 9000000);

-- b) view studioDirectors containing names, addresses, certificates of all producers who are studio directors

CREATE VIEW StudioDirectors AS
SELECT fp.name, fp.adress, certificate
FROM filmproducer fp, studio s
WHERE s.director = fp.certificate;

INSERT INTO studio (name, director) VALUES ('testing studio', 2);

SELECT * FROM filmproducer;
SELECT * FROM StudioDirectors;

-- c) view StarsProducers containig name, adress, sex, birthDates, certificates, salaries of all film producers who are also stars

CREATE VIEW StarsProducers AS
SELECT s.name, s.adress, s.sex, s.birthDay, fp.certificate, fp.salary
FROM star s, filmproducer fp
WHERE s.name = fp.name AND s.adress = fp.adress;

INSERT INTO filmproducer (name, adress, certificate, salary) VALUES ('Tom Hanks', 'California', 30, 10000000);
INSERT INTO star (name, adress, birthDay, sex) VALUES ('Tom Hanks', 'California', 03/03/1960, 'M');

SELECT * FROM StarsProducers;

-- 8.1.2 Using created views write following queries:

-- a) find womans names, who are stars and producers at the same time

INSERT INTO filmproducer (name, adress, certificate, salary) VALUES ('Meril Streep', 'New York', 31, 20000000);
INSERT INTO star (name, adress, birthDay, sex) VALUES ('Meril Streep', 'New York', 03/03/1960, 'M');

UPDATE star SET sex = 'F' WHERE name = 'Meril Streep';

SELECT name FROM StarsProducers WHERE sex = "F";

-- b) find names of producers which are studio director and have salaries at leas 10 000 000

SELECT rp.name FROM RichProducers rp,  StudioDirectors sd
WHERE rp.certificate = sd.certificate;

-- c) find studio directors which are stars at the same time and have salaries at leas 50 000 000

UPDATE studio SET director = 30 WHERE name = 'testing studio';
UPDATE filmproducer SET salary = 1000000000 WHERE name = 'Tom Hanks';

SELECT sd.name FROM StudioDirectors sd, StarsProducers sp
WHERE sd.certificate = sp.certificate AND salary > 50000000;


-- 8.2.1 which of aforementioned views are meditable (can modify)

-- only RichProducers:

INSERT INTO RichProducers (name, certificate) VALUES ('Tony Bank', 44);

-- 8.2.2

-- we have following view:

CREATE VIEW DisneyComedy AS
SELECT title, year, lenght
FROM film
WHERE studio = 'Disney' AND genre = 'Comedy';

INSERT INTO studio (name) VALUES ('Disney');
INSERT INTO film (title, year, lenght, studio, genre) VALUES ('Bugs', 1995, 120, 'Disney', 'Comedy');

SELECT * FROM DisneyComedy;

-- a) is this perspective editable? -- yes

INSERT INTO DisneyComedy (title, year, lenght) VALUES ('Donald', 2001, 60);
UPDATE DisneyComedy SET lenght = 69 WHERE title = 'Bugs';
DELETE FROM DisneyComedy WHERE title = 'Bugs';

-- b) create trigger 'instead of' serving as a way to insert entries into perspective 

/*
DELIMITER //
CREATE TRIGGER InsertIntoDisneyComedy
INSTEAD OF INSERT ON DisneyComedy
FOR EACH ROW
BEGIN
INSERT INTO Film (title, year, lenght, studio, genre) VALUES (NEW.title, NEW.year, NEW.lenght, 'Disney', 'Comedy');
END//
DELIMITER ;
*/

-- MySQL does not have instead of triggers INSTEAD WE WILL HAVE

DELIMITER //
CREATE TRIGGER InsertIntoDisneyComedy
AFTER INSERT ON DisneyComedy
FOR EACH ROW
BEGIN
UPDATE film SET genre = 'Comedy', studio = 'Disney' WHERE title = NEW.title AND year = NEW.year;
END//
DELIMITER ;

-- MySQL does not support triggers on views.


