-- 7.2.1 

-- a), b), c) create table Film with constraints that user cannot enter year less than 1915,
-- length cannot be less than 60 minutes and more than 250 minutes
-- stodio can only be one of following values: DIsney, Fox, MGM or Paramount

use hollywood;

drop table Film;

CREATE TABLE Film (
	title CHAR(30),
	year INT,
    CHECK (year >= 1915),
    length INT,
    CHECK (length >= 60 AND length <=250),
    genre CHAR(30),
    studio CHAR(30),
    CHECK (studio IN ('Disney', 'Fox', 'MGM', 'Paramount')),
    producer INT,
    PRIMARY KEY (title, year),
    FOREIGN KEY (producer) REFERENCES FilmProducer(certificate)
);

-- test 1: should not allow inserting into table

INSERT INTO Film (title, year, length, studio)
VALUES ('test1', 1914, 100, 'Disney');

INSERT INTO Film (title, year, length, studio)
VALUES ('test2', 1915, 59, 'Disney');

INSERT INTO Film (title, year, length, studio)
VALUES ('test3', 1915, 251, 'Disney');

INSERT INTO Film (title, year, length, studio)
VALUES ('test4', 1915, 100, 'Studio');

-- test 2: should allow enter inserting into table

INSERT INTO Film (title, year, length, studio)
VALUES ('test1', 1915, 250, 'Disney');

INSERT INTO Film (title, year, length, studio)
VALUES ('test2', 1915, 60, 'Fox');

INSERT INTO Film (title, year, length, studio)
VALUES ('test3', 2000, 100, 'MGM');

INSERT INTO Film (title, year, length, studio)
VALUES ('test4', 2020, 100, 'Paramount');

-- 7.2.2
-- Add following constraints to products database
use products;

-- a) speed of notebook cannot be less than 2

ALTER TABLE notebook
ADD CONSTRAINT speedCannotBeLessThan2
CHECK (speed >= 2.0);

-- test1: should not add notebook with speed less than 2.0

INSERT INTO products(model)
VALUES(1200);
INSERT INTO notebook(model, speed)
VALUES (1200, 1.9);

-- test2: should add notebook with speed equals 2.0

INSERT INTO notebook(model, speed)
VALUES (1200, 2.0);

-- d) only available types of printers are laser, inkjet and termic

ALTER TABLE printer
ADD CONSTRAINT onlyAvailableTypesOfPrinters
CHECK (type IN ('laser', 'inkjet', 'termic'));

-- test1: should not add printer to the table

INSERT INTO products(model)
VALUES(3100);

INSERT INTO printer(model, type)
VALUES (3100, 'black');

-- test2: should add printer to the table

INSERT INTO products(model)
VALUES (3101), (3102);

INSERT INTO printer(model, type)
VALUES (3100, 'laser');

INSERT INTO printer(model, type)
VALUES (3101, 'inkjet');

INSERT INTO printer(model, type)
VALUES (3102, 'termic');

-- c) only available types of products are pc, printer and notebook

ALTER TABLE products
ADD CONSTRAINT ONlyAvailableTypesOfProducts
CHECK (type IN ('pc', 'printer', 'notebook'));

-- test1: should not add product to the table

INSERT INTO products(model, type)
VALUES (4000, 'camera');

-- d) model in table products must belong to one of the following tables: notebook, laptop, printer

DELETE FROM products
WHERE model NOT IN ((SELECT model FROM notebook)
					UNION
                    (SELECT model FROM pc)
                    UNION
                    (SELECT model FROM printer));

-- SUBQUERIES NOT ALLOWED IN CHECK CONSTRAINT
ALTER TABLE products
ADD CONSTRAINT modelMustBelongToTableOfAnyType
CHECK (model IN (SELECT model FROM notebook)
		OR model IN (SELECT model FROM pc)
        OR model IN (SELECT model FROM printer)
	);
    
-- THIS GAP CAN BE BRIDGED BY FUNCTION

-- 7.2.4

-- implement following constraints 

-- a) price of pc of speed lower than 2.0 cannot be higher than 600

ALTER TABLE pc
ADD CONSTRAINT priceOfPCWithSpeedOVer2
CHECK (price <= 600 OR speed >= 2.0);

-- test1: should not insert into pc, model with speed less than 2 and price higher than 600

INSERT INTO products (model)
VALUES (1234);
INSERT INTO pc (model, speed, price)
VALUES (1234, 1.9, 601);

-- test2: should insert into pc, model with speed = 2 and price = 600

INSERT INTO pc (model, speed, price)
VALUES (1234, 2.0, 600);

-- b) notebook with screen at least 15 cals must have hardDrive of minimum 40Gb and its price must be at least 1000

ALTER TABLE notebook
ADD CONSTRAINT screenHardDrivePrice
CHECK (screen < 15 OR (hardDrive >= 40 AND price >= 1000));

-- test 1: should not insert into notebook model with screen 15 and hardDrive less then 40

INSERT INTO products (model)
VALUES (2345);

INSERT INTO notebook (model, screen, hardDrive, price)
VALUES (2345, 15, 39, 1000);

-- test 2: should not insert into notebook model with screen 15 and price less then 1000

INSERT INTO notebook (model, screen, hardDrive, price)
VALUES (2345, 15, 40, 999);

-- test 3: should insert into notebook model with screen 15, price 1000, harDrive 40

INSERT INTO notebook (model, screen, hardDrive, price)
VALUES (2345, 15, 40, 1000);

-- 7.2.3.

-- Film(title PK, year PK, length, genre, studio FK, producer FK)
-- StarIn(filmTitle FK, FilmYear FK, starName FK)
-- FilmStar(name PK, adress, sex, birthDay)
-- FilmProducer(name, adress, certificate PK, salary)
-- Studio(name PK, adress, director FK)

-- create above tables with constraints such as primary keys, foreign keys, no null and following checks constraints

-- 1) Star cannot act in a movie produced earlier than her birthDay
-- 2) It cannot be two studios with the same addess, name of Studio must exist as at least one studio in movie table
-- 3) Star cannot exist as FilmProducer at the same time
 
-- we assume that in database we cannot delete records
-- WE WILL BE NOT RUNNING IT IN MYSQL --> MY SQL DOES NOT SUPPORT SUBQUERIES IN CHECK CONSTRAINTS!!

use hollywood;

CREATE TABLE star (
	name CHAR(100) PRIMARY KEY,
	adress CHAR(255),
	sex CHAR(1),
	birthDay DATE
);

CREATE TABLE FilmProducer (
	name CHAR(30),
    adress CHAR(255),
    certificate INT PRIMARY KEY,
    salary INT,
    CHECK (name NOT IN (SELECT name FROM star))
);

ALTER TABLE star
ADD CONSTRAINT starNotFilmProducer
CHECK (name NOT IN (SELECT DISTINCT name FROM FilmProducer));

CREATE TABLE film (
	title CHAR(255),
	year INT,
	lenght INT,
	genre CHAR(30),
	studio CHAR(100),
	producer INT,
	PRIMARY KEY (title, year),
	FOREIGN KEY (studio) REFERENCES studio (name)
	ON UPDATE CASCADE
	ON DELETE SET NULL
	DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY (producer) REFERENCES FilmProducer (certificate)
	ON UPDATE CASCADE
	ON DELETE SET NULL
);

CREATE TABLE studio (
	name CHAR(100) PRIMARY KEY,
	adress CHAR(255) NOT NULL UNIQUE,
	director INT,
	FOREIGN KEY (director) REFERENCES FilmProducer (certificate)
	ON UPDATE CASCADE
	ON DELETE SET NULL,
	CHECK (name IN (SELECT DISTINCT studio FROM film))
);

CREATE TABLE starin (
	filmTitle CHAR(255) NOT NULL,
	filmYear INT NOT NULL,
	starName CHAR(100) NOT NULL,
	FOREIGN KEY (filmTitle, filmYear) REFERENCES film (title, year)
	ON UPDATE CASCADE
	ON DELETE CASCADE,
	FOREIGN KEY (starName) REFERENCES star (name)
	ON UPDATE CASCADE
	ON DELETE CASCADE,
	CHECK (filmYear > (SELECT birthDate FROM star WHERE name = starName)) 
);