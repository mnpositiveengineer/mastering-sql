-- creating database

DROP DATABASE IF EXISTS prefab_sales;
CREATE DATABASE prefab_sales;
USE prefab_sales;

SET NAMES utf8 ;
SET character_set_client = utf8mb4 ;

-- creating tables

DROP TABLE IF EXISTS Prospect;

CREATE TABLE Prospect (
	id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
    CHECK (name REGEXP '^[A-Za-z0-9 ąĄćĆęĘłŁńŃóÓśŚźŹżŻåÅØøæÆäÄöÖüÜß/,\.\'\-]*$'),
    address VARCHAR(255)
    CHECK (address REGEXP '^[A-Za-z0-9 ąĄćĆęĘłŁńŃóÓśŚźŹżŻåÅØøæÆäÄöÖüÜß/,\.\'\-]*$'),
    country VARCHAR(100)
    CHECK (country REGEXP '^[A-Z a-z]*$'),
    principalActivity VARCHAR(100),
    tax VARCHAR(30)
    CHECK (tax REGEXP '^[A-Z0-9]{1,26}$')
);

DROP TABLE IF EXISTS PersonOfContact;

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

DROP TABLE IF EXISTS Project;

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

DROP TABLE IF EXISTS SalesPerson;

CREATE TABLE SalesPerson (
	id SERIAL PRIMARY KEY,
    email VARCHAR(100) NOT NULL
    CHECK (email LIKE '%_@__%.__%' OR email LIKE '%#@__%.__%'),
	name VARCHAR(100) NOT NULL
    CHECK (name REGEXP '^[A-Za-z ąĄćĆęĘłŁńŃóÓśŚźŹżŻåÅØøæÆäÄöÖüÜß\.\'\-]*$')
);

DROP TABLE IF EXISTS ProjectSalesPerson;

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

DROP TABLE IF EXISTS TypeOfElement;

CREATE TABLE TypeOfElement (
	id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

DROP TABLE IF EXISTS BidElements;

CREATE TABLE BidElements (
	id SERIAL PRIMARY KEY,
    project_id BIGINT UNSIGNED,
    typeOfElement_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(10) NOT NULL,
    amount INT UNSIGNED NOT NULL,
    height DECIMAL(9,2) UNSIGNED,
    width DECIMAL (9,2) UNSIGNED,
    length DECIMAL (9,2) UNSIGNED,
    volume DECIMAL (9,2) UNSIGNED,
    total_volume DECIMAL (9,2) UNSIGNED,
    area DECIMAL (9,2) UNSIGNED,
    total_area DECIMAL (9,2) UNSIGNED,
    weight DECIMAL (9,2) UNSIGNED,
    total_weight DECIMAL (9,2) UNSIGNED,
    steel_saturation INT UNSIGNED,
    tension_steel_saturation INT UNSIGNED,
    assembly_start DATE,
    assembly_end DATE,
    other_properties JSON,
    FOREIGN KEY (project_id) REFERENCES Project(id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
    FOREIGN KEY (typeOfElement_id) REFERENCES TypeOfElement(id),
	CHECK (assembly_start <= assembly_end)
);

DROP TABLE IF EXISTS Accessories;

CREATE TABLE Accessories(
	id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    unit VARCHAR(10),
    unit_price DECIMAL(9,2) UNSIGNED
);

DROP TABLE IF EXISTS AccessoriesBidElements;

CREATE TABLE AccessoriesBidElements(
	accessory_id BIGINT UNSIGNED NOT NULL,
    bid_element_id BIGINT UNSIGNED NOT NULL,
    amount DECIMAL(9,2) NOT NULL,
    PRIMARY KEY (accessory_id, bid_element_id),
	FOREIGN KEY (accessory_id) REFERENCES Accessories(id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
    FOREIGN KEY (bid_element_id) REFERENCES BidElements(id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

DROP TABLE IF EXISTS FinancialDetails;

CREATE TABLE FinancialDetails(
    project_id BIGINT UNSIGNED NOT NULL UNIQUE,
    concrete_cost DECIMAL(9,2) UNSIGNED,
    steel_cost DECIMAL(9,2) UNSIGNED,
    tension_steel_cost DECIMAL(9,2) UNSIGNED,
    framework_cost DECIMAL(9,2) UNSIGNED,
    man_hour_cost DECIMAL(9,2) UNSIGNED,
    energy_water_cost DECIMAL(9,2) UNSIGNED,
    faculty_cost DECIMAL(9,2) UNSIGNED,
    transport_cost DECIMAL(9,2) UNSIGNED,
    assembly_cost DECIMAL(9,2) UNSIGNED,
    markup DECIMAL(2,2) UNSIGNED,
    FOREIGN KEY (project_id) REFERENCES Project(id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

DROP TABLE IF EXISTS PricesOfBidElements;

CREATE TABLE PricesOfBidElements (
	bid_element_id BIGINT UNSIGNED NOT NULL,
    amount INT UNSIGNED NOT NULL,
    concrete_cost DECIMAL(9,2) UNSIGNED,
    steel_cost DECIMAL(9,2) UNSIGNED,
    tension_steel_cost DECIMAL(9,2) UNSIGNED,
    framework_cost DECIMAL(9,2) UNSIGNED,
    man_hour_cost DECIMAL(9,2) UNSIGNED,
    energy_water_cost DECIMAL(9,2) UNSIGNED,
    faculty_cost DECIMAL(9,2) UNSIGNED,
    accessory_cost DECIMAL(9,2) UNSIGNED,
    production_cost DECIMAL(9,2) UNSIGNED,
    total_production_cost DECIMAL(9,2) UNSIGNED,
	transport_cost DECIMAL(9,2) UNSIGNED,
    total_transport_cost DECIMAL(9,2) UNSIGNED,
    assembly_cost DECIMAL(9,2) UNSIGNED,
    total_assembly_cost DECIMAL(9,2) UNSIGNED,
    element_cost DECIMAL(9,2) UNSIGNED,
    total_element_cost DECIMAL(9,2) UNSIGNED,
    element_price DECIMAL(9,2) UNSIGNED,
    total_element_price DECIMAL(9,2) UNSIGNED,
    FOREIGN KEY (bid_element_id) REFERENCES BidElements(id)
	ON UPDATE CASCADE
    ON DELETE CASCADE
);

DROP TABLE IF EXISTS Offers;

CREATE TABLE Offers (
	id SERIAL PRIMARY KEY,
    project_id BIGINT UNSIGNED NOT NULL,
    total_production_cost DECIMAL(9,2) UNSIGNED,
    total_transport_cost DECIMAL(9,2) UNSIGNED,
    total_assembly_cost DECIMAL(9,2) UNSIGNED,
    total_cost DECIMAL(9,2) UNSIGNED,
    markup DECIMAL(2,2) UNSIGNED,
    total_price DECIMAL(9,2) UNSIGNED,
	FOREIGN KEY (project_id) REFERENCES Project(id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);