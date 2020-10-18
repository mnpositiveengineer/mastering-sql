-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema flight_system
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema flight_system
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `flight_system` DEFAULT CHARACTER SET utf8 COLLATE utf8_icelandic_ci ;
USE `flight_system` ;

-- -----------------------------------------------------
-- Table `flight_system`.`passengers`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `flight_system`.`passengers` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `first_name` VARCHAR(50) NOT NULL,
  `second_name` VARCHAR(50) NOT NULL,
  `passport_number` VARCHAR(255) NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `flight_system`.`tickets`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `flight_system`.`tickets` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `number` VARCHAR(255) NOT NULL,
  `price` DECIMAL(9,2) NOT NULL,
  `purchase_date` DATETIME NOT NULL,
  `passenger_id` BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_tickets_passengers_idx` (`passenger_id` ASC) VISIBLE,
  CONSTRAINT `fk_tickets_passengers`
    FOREIGN KEY (`passenger_id`)
    REFERENCES `flight_system`.`passengers` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `flight_system`.`airports`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `flight_system`.`airports` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL,
  `city` VARCHAR(50) NOT NULL,
  `country` VARCHAR(50) NOT NULL,
  `code` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `flight_system`.`airlines`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `flight_system`.`airlines` (
  `id` INT UNSIGNED NOT NULL,
  `name` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `flight_system`.`flights`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `flight_system`.`flights` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `number` VARCHAR(255) NOT NULL,
  `distance_miles` INT UNSIGNED NULL,
  `duration_minutes` INT UNSIGNED NULL,
  `depart_time` DATETIME NOT NULL,
  `arrive_time` DATETIME NOT NULL,
  `available_seats` INT UNSIGNED NOT NULL,
  `depart_airport_id` INT UNSIGNED NOT NULL,
  `arrive_airport_id` INT UNSIGNED NOT NULL,
  `airline_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_flights_airports1_idx` (`depart_airport_id` ASC) VISIBLE,
  INDEX `fk_flights_airports2_idx` (`arrive_airport_id` ASC) VISIBLE,
  INDEX `fk_flights_airlines1_idx` (`airline_id` ASC) VISIBLE,
  CONSTRAINT `fk_flights_airports1`
    FOREIGN KEY (`depart_airport_id`)
    REFERENCES `flight_system`.`airports` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_flights_airports2`
    FOREIGN KEY (`arrive_airport_id`)
    REFERENCES `flight_system`.`airports` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_flights_airlines1`
    FOREIGN KEY (`airline_id`)
    REFERENCES `flight_system`.`airlines` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `flight_system`.`classes`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `flight_system`.`classes` (
  `id` TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `flight_system`.`confirmations`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `flight_system`.`confirmations` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `number` VARCHAR(50) NOT NULL,
  `airlines_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_confirmation_airlines1_idx` (`airlines_id` ASC) VISIBLE,
  CONSTRAINT `fk_confirmation_airlines1`
    FOREIGN KEY (`airlines_id`)
    REFERENCES `flight_system`.`airlines` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `flight_system`.`tickets_flights`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `flight_system`.`tickets_flights` (
  `ticket_id` BIGINT UNSIGNED NOT NULL,
  `flight_id` BIGINT UNSIGNED NOT NULL,
  `class_id` TINYINT UNSIGNED NOT NULL,
  `confirmation_id` INT UNSIGNED NOT NULL,
  INDEX `fk_tickets_flights_tickets1_idx` (`ticket_id` ASC) VISIBLE,
  INDEX `fk_tickets_flights_flights1_idx` (`flight_id` ASC) VISIBLE,
  INDEX `fk_tickets_flights_classes1_idx` (`class_id` ASC) VISIBLE,
  INDEX `fk_tickets_flights_confirmation1_idx` (`confirmation_id` ASC) VISIBLE,
  PRIMARY KEY (`ticket_id`, `flight_id`),
  CONSTRAINT `fk_tickets_flights_tickets1`
    FOREIGN KEY (`ticket_id`)
    REFERENCES `flight_system`.`tickets` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_tickets_flights_flights1`
    FOREIGN KEY (`flight_id`)
    REFERENCES `flight_system`.`flights` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_tickets_flights_classes1`
    FOREIGN KEY (`class_id`)
    REFERENCES `flight_system`.`classes` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_tickets_flights_confirmation1`
    FOREIGN KEY (`confirmation_id`)
    REFERENCES `flight_system`.`confirmations` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
