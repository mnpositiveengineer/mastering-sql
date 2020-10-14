-- creating database

DROP DATABASE IF EXISTS prefab_sales;
CREATE DATABASE prefab_sales;
USE prefab_sales;

SET NAMES utf8 ;
SET character_set_client = utf8mb4 ;

-- creating tables

DROP TABLE IF EXISTS Addresses;

CREATE TABLE Addresses (
        id INT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
        address VARCHAR(255) NOT NULL,
        city VARCHAR(50) NOT NULL,
        country VARCHAR(50) NOT NULL,
        postal_code VARCHAR(50)
    );

DROP TABLE IF EXISTS Prospects;

CREATE TABLE Prospects (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
    name VARCHAR(100) NOT NULL
    CHECK (name REGEXP '^[A-Za-z0-9 ąĄćĆęĘłŁńŃóÓśŚźŹżŻåÅØøæÆäÄöÖüÜß/,\.\'\-]*$'),
    address INT UNSIGNED,
    principal_activity VARCHAR(100),
    tax VARCHAR(30)
    CHECK (tax REGEXP '^[A-Z0-9]{1,26}$'),
    FOREIGN KEY (address) REFERENCES Addresses (id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);

DROP TABLE IF EXISTS PersonOfContacts;

CREATE TABLE PersonOfContacts (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL
    CHECK (first_name REGEXP '^[A-Za-z ąĄćĆęĘłŁńŃóÓśŚźŹżŻåÅØøæÆäÄöÖüÜß\.\'\-]*$'),
	last_name VARCHAR(50) NOT NULL
    CHECK (last_name REGEXP '^[A-Za-z ąĄćĆęĘłŁńŃóÓśŚźŹżŻåÅØøæÆäÄöÖüÜß\.\'\-]*$'),
    email VARCHAR(255) NOT NULL
    CHECK (email LIKE '%_@__%.__%' OR email LIKE '%#@__%.__%'),
    phone_number VARCHAR(50) NOT NULL
    CHECK (phone_number REGEXP '^[0-9]*$'),
    position VARCHAR(50)
    CHECK (position REGEXP '^[A-Z a-z]*$'),
    decision_maker BOOLEAN,
    prospect_id INT UNSIGNED,
    FOREIGN KEY (prospect_id) REFERENCES Prospects (id)
    ON DELETE SET NULL
    ON UPDATE CASCADE
);

DROP TABLE IF EXISTS client_types;

CREATE TABLE client_types (
	id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
    type VARCHAR(50)
);

DROP TABLE IF EXISTS project_types;

CREATE TABLE project_types (
	id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
    type VARCHAR(50)
);

DROP TABLE IF EXISTS construction_types;

CREATE TABLE construction_types (
	id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
    type VARCHAR(50)
);

DROP TABLE IF EXISTS project_statuses;

CREATE TABLE project_statuses (
	id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
    status VARCHAR(50)
);

DROP TABLE IF EXISTS Projects;

CREATE TABLE Projects (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
    name VARCHAR(100) NOT NULL
    CHECK (name REGEXP '^[A-Za-z0-9 ąĄćĆęĘłŁńŃóÓśŚźŹżŻåÅØøæÆäÄöÖüÜß/,\.\'\-]*$'),
    address INT UNSIGNED NOT NULL,
    construction_type TINYINT UNSIGNED,
    client_type TINYINT UNSIGNED,
    project_type TINYINT UNSIGNED,
    design BOOLEAN,
    status TINYINT UNSIGNED,
    prospect_id INT UNSIGNED,
    FOREIGN KEY (prospect_id) REFERENCES Prospects (id)
    ON UPDATE CASCADE
    ON DELETE SET NULL,
    FOREIGN KEY (address) REFERENCES Addresses (id)
	ON DELETE RESTRICT
    ON UPDATE CASCADE,
	FOREIGN KEY (construction_type) REFERENCES construction_types (id)
	ON DELETE RESTRICT
    ON UPDATE CASCADE,
	FOREIGN KEY (client_type) REFERENCES client_types (id)
	ON DELETE RESTRICT
    ON UPDATE CASCADE,
	FOREIGN KEY (project_type) REFERENCES project_types (id)
	ON DELETE RESTRICT
    ON UPDATE CASCADE,
	FOREIGN KEY (status) REFERENCES project_statuses (id)
	ON DELETE RESTRICT
    ON UPDATE CASCADE
);

DROP TABLE IF EXISTS SalesPersons;

CREATE TABLE SalesPersons (
	id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
    email VARCHAR(255) NOT NULL
    CHECK (email LIKE '%_@__%.__%' OR email LIKE '%#@__%.__%'),
	first_name VARCHAR(50) NOT NULL
    CHECK (first_name REGEXP '^[A-Za-z ąĄćĆęĘłŁńŃóÓśŚźŹżŻåÅØøæÆäÄöÖüÜß\.\'\-]*$'),
	last_name VARCHAR(50) NOT NULL,
    CHECK (last_name REGEXP '^[A-Za-z ąĄćĆęĘłŁńŃóÓśŚźŹżŻåÅØøæÆäÄöÖüÜß\.\'\-]*$')
);

DROP TABLE IF EXISTS ProjectsSalesPersons;

CREATE TABLE ProjectsSalesPersons (
	sales_person_id TINYINT UNSIGNED NOT NULL,
    Projects_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (sales_person_id, Projects_id),
    FOREIGN KEY (sales_person_id) REFERENCES SalesPersons(id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
    FOREIGN KEY (Projects_id) REFERENCES Projects(id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

DROP TABLE IF EXISTS TypeOfElements;

CREATE TABLE TypeOfElements (
	id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

DROP TABLE IF EXISTS BidElements;

CREATE TABLE BidElements (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
    project_id INT UNSIGNED,
    type_of_element_id TINYINT UNSIGNED NOT NULL,
    name VARCHAR(10) NOT NULL,
    amount SMALLINT UNSIGNED NOT NULL,
    height DECIMAL(4,2) UNSIGNED,
    width DECIMAL (4,2) UNSIGNED,
    length DECIMAL (4,2) UNSIGNED,
    volume DECIMAL (9,2) UNSIGNED,
    total_volume DECIMAL (9,2) UNSIGNED,
    area DECIMAL (7,2) UNSIGNED,
    total_area DECIMAL (9,2) UNSIGNED,
    weight DECIMAL (9,2) UNSIGNED,
    total_weight DECIMAL (9,2) UNSIGNED,
    steel_saturation SMALLINT UNSIGNED,
    tension_steel_saturation SMALLINT UNSIGNED,
    assembly_start DATE,
    assembly_end DATE,
    other_properties JSON,
    FOREIGN KEY (project_id) REFERENCES Projects(id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
    FOREIGN KEY (type_of_element_id) REFERENCES TypeOfElements(id),
	CHECK (assembly_start <= assembly_end)
);

DROP TABLE IF EXISTS Accessories;

CREATE TABLE Accessories(
	id INT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    unit VARCHAR(10),
    unit_price DECIMAL(7,2) UNSIGNED
);

DROP TABLE IF EXISTS AccessoriesBidElements;

CREATE TABLE AccessoriesBidElements(
	accessory_id INT UNSIGNED NOT NULL,
    bid_element_id INT UNSIGNED NOT NULL,
    amount DECIMAL(7,2) NOT NULL,
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
    project_id INT UNSIGNED NOT NULL UNIQUE,
    concrete_cost DECIMAL(6,2) UNSIGNED,
    steel_cost DECIMAL(6,2) UNSIGNED,
    tension_steel_cost DECIMAL(6,2) UNSIGNED,
    framework_cost DECIMAL(6,2) UNSIGNED,
    man_hour_cost DECIMAL(6,2) UNSIGNED,
    energy_water_cost DECIMAL(6,2) UNSIGNED,
    faculty_cost DECIMAL(6,2) UNSIGNED,
    transport_cost DECIMAL(9,2) UNSIGNED,
    assembly_cost DECIMAL(9,2) UNSIGNED,
    markup DECIMAL(3,2) UNSIGNED,
    FOREIGN KEY (project_id) REFERENCES Projects(id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

DROP TABLE IF EXISTS PricesOfBidElements;

CREATE TABLE PricesOfBidElements (
	bid_element_id INT UNSIGNED NOT NULL,
    amount SMALLINT UNSIGNED NOT NULL,
    concrete_cost DECIMAL(9,2) UNSIGNED,
    steel_cost DECIMAL(9,2) UNSIGNED,
    tension_steel_cost DECIMAL(9,2) UNSIGNED,
    framework_cost DECIMAL(9,2) UNSIGNED,
    man_hour_cost DECIMAL(9,2) UNSIGNED,
    energy_water_cost DECIMAL(9,2) UNSIGNED,
    faculty_cost DECIMAL(9,2) UNSIGNED,
    accessory_cost DECIMAL(9,2) UNSIGNED,
    production_cost DECIMAL(9,2) UNSIGNED,
    total_production_cost DECIMAL(10,2) UNSIGNED,
	transport_cost DECIMAL(9,2) UNSIGNED,
    total_transport_cost DECIMAL(10,2) UNSIGNED,
    assembly_cost DECIMAL(9,2) UNSIGNED,
    total_assembly_cost DECIMAL(10,2) UNSIGNED,
    element_cost DECIMAL(9,2) UNSIGNED,
    total_element_cost DECIMAL(10,2) UNSIGNED,
    element_price DECIMAL(9,2) UNSIGNED,
    total_element_price DECIMAL(10,2) UNSIGNED,
    FOREIGN KEY (bid_element_id) REFERENCES BidElements(id)
	ON UPDATE CASCADE
    ON DELETE CASCADE
);

DROP TABLE IF EXISTS Offers;

CREATE TABLE Offers (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
    project_id INT UNSIGNED NOT NULL,
    total_production_cost DECIMAL(11,2) UNSIGNED,
    total_transport_cost DECIMAL(11,2) UNSIGNED,
    total_assembly_cost DECIMAL(11,2) UNSIGNED,
    total_cost DECIMAL(11,2) UNSIGNED,
    markup DECIMAL(3,2) UNSIGNED,
    total_price DECIMAL(11,2) UNSIGNED,
	FOREIGN KEY (project_id) REFERENCES Projects(id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);