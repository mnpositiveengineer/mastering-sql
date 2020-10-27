-- 7.3.1 

-- modify database hollywood so that following constraints are met

-- a) attribute title and year is PRIMARY KEY of the relation film

ALTER TABLE film
ADD CONSTRAINT PK_title_year
PRIMARY KEY(title, year);

-- b) producent of each film must be in relation FilmProducer

ALTER TABLE filmproducer
ADD CONSTRAINT PK_certificate
PRIMARY KEY (certificate);

ALTER TABLE film
ADD CONSTRAINT FK_producer
FOREIGN KEY (producer) REFERENCES filmproducer (certificate);

-- c) film cannot last less than 60 minutes and more than 250 minutes

ALTER TABLE film
ADD CONSTRAINT length_of_the_movie
CHECK (lenght >= 60 AND lenght <=250);

-- test1: should not allow to insert film with length less than 60 minutes and more than 250 minutes)

INSERT INTO film (title, year, lenght)
VALUES ('test', 1920, 59);

INSERT INTO film (title, year, lenght)
VALUES ('test', 1920, 251);

-- d) no name can exist in relation star and relation filmproducer at the same time. 

ALTER TABLE star
ADD CONSTRAINT nofilmproducerhere
CHECK (name NOT IN (SELECT DISTINCT name FROM filmproducer));

ALTER TABLE filmproducer
ADD CONSTRAINT nostarhere
CHECK (name NOT IN (SELECT name FROM star));

-- e) adress of every studio must be unique

ALTER TABLE studio
MODIFY adress CHAR(255) UNIQUE;