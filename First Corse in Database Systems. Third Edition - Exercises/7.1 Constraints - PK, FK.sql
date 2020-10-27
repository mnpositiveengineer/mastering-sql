-- 7.7.1
CREATE database hollywood;
use hollywood;
-- Film(title PK, year PK, length, genre, studio FK, producer FK)
-- StarIn(filmTitle FK, FilmYear FK, starsName FK)
-- FilmStar(name PK, adress, sex, birthDay)
-- FilmProducer(name, adress, certificate PK, salary)
-- Studio(name PK, adress, director FK)

-- declare below integrity constraints for above database:

-- a) film producer must be named in Film table. Modifications that violates this constraint must be rejected

CREATE TABLE FilmProducer (
	name CHAR(30),
    adress CHAR(255),
    certificate INT PRIMARY KEY,
    salary INT
);

CREATE TABLE Film (
	title CHAR(30) PRIMARY KEY,
	year INT,
    length INT,
    genre CHAR(30),
    studio CHAR(30),
    producer INT,
    FOREIGN KEY (producer) REFERENCES FilmProducer(certificate)
);

-- test 1: should reject it, when film with producer, that not exist in FilmProducer table, is being insert into the table Film

INSERT INTO FIlm (title, year, length, genre, studio, producer)
VALUES ('test', 1992, 100, 'drama', null, 1);

-- test 2: null should be available

INSERT INTO FIlm (title, year, length, genre, studio, producer)
VALUES ('test', 1992, 100, 'drama', null, null);


-- b) add to the table Film fact, that inserting null as producer will violate constraints.

ALTER TABLE Film
MODIFY producer INT NOT NULL;

-- test 1: should reject it, when film with producer, that not exist in FilmProducer table, is being insert into the table Film

INSERT INTO FIlm (title, year, length, genre, studio, producer)
VALUES ('test', 1992, 100, 'drama', null, 1);

-- test 2: should reject it when user wants to insert null as producer in table 'Film'

INSERT INTO FIlm (title, year, length, genre, studio, producer)
VALUES ('test', 1992, 100, 'drama', null, null);

-- c) add to the table Film fact, that if there is a violation of constraints, the 'invalid' records will be removed

-- first we need to drop constraint and recreate it with clause "ON UPDATE CASCADE, ON DELETE CASCADE"
-- name o the foreign key: film_ibfk_1

ALTER TABLE Film DROP FOREIGN KEY film_ibfk_1;

ALTER TABLE Film
ADD CONSTRAINT film_producer_fk
FOREIGN KEY (producer) REFERENCES FilmProducer(certificate)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- test 1: should reject it, when film with producer, that not exist in FilmProducer table, is being insert into the table Film

INSERT INTO FIlm (title, year, length, genre, studio, producer)
VALUES ('test', 1992, 100, 'drama', null, 1);

-- test 2: should reject it when user wants to insert null as producer in table 'Film'

INSERT INTO FIlm (title, year, length, genre, studio, producer)
VALUES ('test', 1992, 100, 'drama', null, null);

-- test 3: should update the value of producer in Film table accordingly when number of certificate is changed in table FilmProducer
INSERT INTO FilmProducer (name, certificate)
VALUES ('test', 1);
INSERT INTO Film (title, producer)
VALUES ('test', 1);
UPDATE FilmProducer
SET certificate = 2 
WHERE name = 'test';

-- test 5: should delete from Film when deleting producer from FilmProducer

DELETE FROM FilmProducer
WHERE name = 'test';

-- d) Film which exist in table StarsIn must be also present in table Films. 
-- e) Start which exist in table StarsIn must be also present in table Stars

CREATE TABLE FilmStar (
		name CHAR(30) PRIMARY KEY,
        adress CHAR(255),
        sex CHAR(1),
        birthDate DATE
);

ALTER TABLE Film DROP PRIMARY KEY;
ALTER TABLE Film
ADD CONSTRAINT pk_title_year_film PRIMARY KEY (title, year);

CREATE TABLE StarsIn (
		filmTitle CHAR(30),
        filmYear INT,
        starName CHAR(30),
        FOREIGN KEY (filmTitle, filmYear) REFERENCES Film (title, year)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
        FOREIGN KEY (starName) REFERENCES FilmStar(name)
		ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- 7.1.3

-- define constraints (primary keys, foreign keys) in products database.

use products;

ALTER TABLE products
ADD CONSTRAINT PRIMARY KEY(model);

ALTER TABLE products
MODIFY model INT NOT NULL;

ALTER TABLE notebook
ADD CONSTRAINT FOREIGN KEY(model) REFERENCES products(model)
ON UPDATE CASCADE
ON DELETE CASCADE;

ALTER TABLE pc
ADD CONSTRAINT FOREIGN KEY(model) REFERENCES products(model)
ON UPDATE CASCADE
ON DELETE CASCADE;

ALTER TABLE printer
ADD CONSTRAINT FOREIGN KEY(model) REFERENCES products(model)
ON UPDATE CASCADE
ON DELETE CASCADE;

-- in case of deleting
ALTER TABLE notebook DROP FOREIGN KEY notebook_ibfk_1;
ALTER TABLE pc DROP FOREIGN KEY pc_ibfk_1;
ALTER TABLE printer DROP FOREIGN KEY printer_ibfk_1;

ALTER TABLE notebook
MODIFY model INT NOT NULL;
ALTER TABLE pc
MODIFY model INT NOT NULL;
ALTER TABLE printer
MODIFY model INT NOT NULL;

-- test 1: should not add to table pc, notebook and printer if product does not exist in table products

INSERT INTO notebook (model)
VALUES (1);
INSERT INTO pc (model)
VALUES (1);
INSERT INTO printer (model)
VALUES (1);

-- test 2: should not add to table pc, notebook and printer model of value null

INSERT INTO notebook (model)
VALUES (null);
INSERT INTO pc (model)
VALUES (null);
INSERT INTO printer (model)
VALUES (null);

-- test 3: should not add to table products when model is null

INSERT INTO products (model)
VALUES (null);

-- test 4: should update the values of model in tables: pc, notebook and printer when values in table products is changed

UPDATE products SET model = 1111 WHERE model = 1001;
UPDATE products SET model = 2222 WHERE model = 2001;
UPDATE products SET model = 3333 WHERE model = 3001;

-- test 5: should delete models from pc, notebook and printer when models in table products is deleted

DELETE FROM products WHERE model IN (1111, 2222, 3333);

