-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema video_rental_store
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema video_rental_store
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `video_rental_store` DEFAULT CHARACTER SET utf8 ;
USE `video_rental_store` ;

-- -----------------------------------------------------
-- Table `video_rental_store`.`stocks`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `video_rental_store`.`stocks` (
  `id` TINYINT NOT NULL,
  `name` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `video_rental_store`.`genres`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `video_rental_store`.`genres` (
  `id` TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `video_rental_store`.`movies`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `video_rental_store`.`movies` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `barcode` CHAR(10) NOT NULL,
  `daily_rental_rate` DECIMAL(4,2) NOT NULL,
  `stock_id` TINYINT NOT NULL,
  `genre_id` TINYINT UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `barcode_UNIQUE` (`barcode` ASC) VISIBLE,
  INDEX `fk_movies_stock_idx` (`stock_id` ASC) VISIBLE,
  INDEX `fk_movies_genres1_idx` (`genre_id` ASC) VISIBLE,
  CONSTRAINT `fk_movies_stock`
    FOREIGN KEY (`stock_id`)
    REFERENCES `video_rental_store`.`stocks` (`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_movies_genres1`
    FOREIGN KEY (`genre_id`)
    REFERENCES `video_rental_store`.`genres` (`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `video_rental_store`.`customers`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `video_rental_store`.`customers` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `first_name` VARCHAR(50) NOT NULL,
  `last_name` VARCHAR(50) NOT NULL,
  `email` VARCHAR(255) NOT NULL,
  `phone_number` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `video_rental_store`.`coupons`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `video_rental_store`.`coupons` (
  `id` TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `code` VARCHAR(50) NOT NULL,
  `description` VARCHAR(255) NULL,
  `discount_percantage` TINYINT NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `video_rental_store`.`rents`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `video_rental_store`.`rents` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `rent_date` DATE NOT NULL,
  `return_date` DATE NULL,
  `payment` DECIMAL(5,2) NULL,
  `lost` TINYINT NULL DEFAULT 0,
  `movie_id` INT UNSIGNED NOT NULL,
  `customer_id` INT UNSIGNED NOT NULL,
  `coupon_id` TINYINT UNSIGNED NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_rents_movies1_idx` (`movie_id` ASC) VISIBLE,
  INDEX `fk_rents_customers1_idx` (`customer_id` ASC) VISIBLE,
  INDEX `fk_rents_coupons1_idx` (`coupon_id` ASC) VISIBLE,
  CONSTRAINT `fk_rents_movies1`
    FOREIGN KEY (`movie_id`)
    REFERENCES `video_rental_store`.`movies` (`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_rents_customers1`
    FOREIGN KEY (`customer_id`)
    REFERENCES `video_rental_store`.`customers` (`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_rents_coupons1`
    FOREIGN KEY (`coupon_id`)
    REFERENCES `video_rental_store`.`coupons` (`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `video_rental_store`.`customers_coupons`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `video_rental_store`.`customers_coupons` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `coupon_id` TINYINT UNSIGNED NOT NULL,
  `customer_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_customers_coupons_coupons1_idx` (`coupon_id` ASC) VISIBLE,
  INDEX `fk_customers_coupons_customers1_idx` (`customer_id` ASC) VISIBLE,
  CONSTRAINT `fk_customers_coupons_coupons1`
    FOREIGN KEY (`coupon_id`)
    REFERENCES `video_rental_store`.`coupons` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_customers_coupons_customers1`
    FOREIGN KEY (`customer_id`)
    REFERENCES `video_rental_store`.`customers` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `video_rental_store`.`users`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `video_rental_store`.`users` (
  `id` INT UNSIGNED NOT NULL,
  `name` VARCHAR(50) NOT NULL,
  `password` VARCHAR(255) NOT NULL,
  `role` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `name_UNIQUE` (`name` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `video_rental_store`.`permissions`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `video_rental_store`.`permissions` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `description` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `video_rental_store`.`users_permissions`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `video_rental_store`.`users_permissions` (
  `user_id` INT UNSIGNED NOT NULL,
  `permission_id` INT UNSIGNED NOT NULL,
  INDEX `fk_users_permissions_users1_idx` (`user_id` ASC) VISIBLE,
  INDEX `fk_users_permissions_permissions1_idx` (`permission_id` ASC) VISIBLE,
  PRIMARY KEY (`user_id`, `permission_id`),
  CONSTRAINT `fk_users_permissions_users1`
    FOREIGN KEY (`user_id`)
    REFERENCES `video_rental_store`.`users` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_users_permissions_permissions1`
    FOREIGN KEY (`permission_id`)
    REFERENCES `video_rental_store`.`permissions` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
