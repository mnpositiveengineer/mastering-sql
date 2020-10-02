-- creating procedures and functions

USE prefab_sales;
SET GLOBAL log_bin_trust_function_creators = 1;

-- 1. Creating function that calculates volume of bid element

DROP FUNCTION IF EXISTS calculate_volume;

DELIMITER $$
CREATE FUNCTION calculate_volume (bid_element_id INT)
RETURNS DECIMAL(9,2)
READS SQL DATA
MODIFIES SQL DATA
BEGIN
    DECLARE length DECIMAL(9,2);
    DECLARE height DECIMAL(9,2);
    DECLARE width DECIMAL(9,2);
    DECLARE volume DECIMAL(9,2) DEFAULT 0;
    
    SELECT b.length, b.width, b.height
    INTO length, width, height
    FROM bidelements b
    WHERE b.id = bid_element_id;
    
    SET volume = length * height * width;
    
    UPDATE bidelements b
    SET b.volume = volume
    WHERE b.id = bid_element_id;
    
    RETURN volume;
END$$
DELIMITER ;

SELECT calculate_volume(1);

-- 2. Creating function that calculates total_volume of bid element

DROP FUNCTION IF EXISTS calculate_total_volume;

DELIMITER $$
CREATE FUNCTION calculate_total_volume (bid_element_id INT)
RETURNS DECIMAL(9,2)
READS SQL DATA
MODIFIES SQL DATA
BEGIN
    DECLARE volume DECIMAL(9,2);
    DECLARE amount INT;
    DECLARE total_volume DECIMAL(9,2) DEFAULT 0;
    
    SELECT b.volume, b.amount
    INTO volume, amount
    FROM bidelements b
    WHERE b.id = bid_element_id;

    SET total_volume = volume * amount;
    
    UPDATE bidelements b
    SET b.total_volume = total_volume
    WHERE b.id = bid_element_id;
    
    RETURN total_volume;
END$$
DELIMITER ;

SELECT calculate_total_volume(1);

-- 3. Creating function that calculates area of element (width * length)

DROP FUNCTION IF EXISTS calculate_area;

DELIMITER $$
CREATE FUNCTION calculate_area(bid_element_id INT)
RETURNS DECIMAL(9,2)
READS SQL DATA
MODIFIES SQL DATA
BEGIN
    DECLARE length DECIMAL(9,2);
    DECLARE width DECIMAL(9,2);
    DECLARE area DECIMAL(9,2) DEFAULT 0;
    
    SELECT b.length, b.width
    INTO length, width
    FROM bidelements b
    WHERE b.id = bid_element_id;
    
    SET area = length * width;
    
    UPDATE bidelements b
    SET b.area = area
    WHERE b.id = bid_element_id;
    
    RETURN area;
END$$
DELIMITER ;

SELECT calculate_area(1);

-- 4. Creating function that calculates total_area of bid element

DROP FUNCTION IF EXISTS calculate_total_area;

DELIMITER $$
CREATE FUNCTION calculate_total_area (bid_element_id INT)
RETURNS DECIMAL(9,2)
READS SQL DATA
MODIFIES SQL DATA
BEGIN
    DECLARE area DECIMAL(9,2);
    DECLARE amount INT;
    DECLARE total_area DECIMAL(9,2) DEFAULT 0;
    
    SELECT b.area, b.amount
    INTO area, amount
    FROM bidelements b
    WHERE b.id = bid_element_id;
    
    SET total_area = area * amount;
    
    UPDATE bidelements b
    SET b.total_area = total_area
    WHERE b.id = bid_element_id;
    
    RETURN total_area;
END$$
DELIMITER ;

SELECT calculate_total_area(1);

-- 5. Creating function that calculates weight of element (volume * 2,5)

DROP FUNCTION IF EXISTS calculate_weight;

DELIMITER $$
CREATE FUNCTION calculate_weight(bid_element_id INT)
RETURNS DECIMAL(9,2)
READS SQL DATA
MODIFIES SQL DATA
BEGIN
    DECLARE volume DECIMAL(9,2);
    DECLARE weight DECIMAL(9,2) DEFAULT 0;
    
    SELECT b.volume
    INTO volume
    FROM bidelements b
    WHERE b.id = bid_element_id;
    
    SET weight = volume * 2.5;
    
    UPDATE bidelements b
    SET b.weight = weight
    WHERE b.id = bid_element_id;
    
    RETURN weight;
END$$
DELIMITER ;

SELECT calculate_weight(1);

-- 6. Creating function that calculates total_weight of bid element

DROP FUNCTION IF EXISTS calculate_total_weight;

DELIMITER $$
CREATE FUNCTION calculate_total_weight (bid_element_id INT)
RETURNS DECIMAL(9,2)
READS SQL DATA
MODIFIES SQL DATA
BEGIN
    DECLARE weight DECIMAL(9,2);
    DECLARE amount INT;
    DECLARE total_weight DECIMAL(9,2) DEFAULT 0;
    
    SELECT b.weight, b.amount
    INTO weight, amount
    FROM bidelements b
    WHERE b.id = bid_element_id;
    
    SET total_weight = weight * amount;
    
    UPDATE bidelements b
    SET b.total_weight = total_weight
    WHERE b.id = bid_element_id;
    
    RETURN total_weight;
END$$
DELIMITER ;

SELECT calculate_total_weight(1);

-- 7. Creating Procedure that calculates all parameters - volume, total volume, area, total area, weight, total weight

DROP PROCEDURE IF EXISTS calculate_all_parameters;

DELIMITER $$
CREATE PROCEDURE calculate_all_parameters(bid_element_id INT)
BEGIN
	SELECT calculate_volume(bid_element_id);
    SELECT calculate_total_volume(bid_element_id);
	SELECT calculate_area(bid_element_id);
    SELECT calculate_total_area(bid_element_id);
	SELECT calculate_weight(bid_element_id);
    SELECT calculate_total_weight(bid_element_id);
END$$
DELIMITER ;

CALL calculate_all_parameters(2);

-- 8. Creating procedure that retrieve all bid elements which belong to selected project

DROP PROCEDURE IF EXISTS select_all_bid_elements_in_project;

DELIMITER $$
CREATE PROCEDURE select_all_bid_elements_in_project (project_id INT)
BEGIN
	SELECT
		b.name,
        t.name AS type,
        b.amount,
        b.height,
        width,
        length,
        volume,
        total_volume,
        area,
        total_area,
        weight,
        total_weight,
        steel_saturation,
        tension_steel_saturation,
        assembly_start,
        assembly_end
	FROM bidelements b 
    JOIN typeofelement t
    ON b.typeOfElement_id = t.id
    WHERE b.project_id = project_id
    ORDER BY type;
END$$
DELIMITER ;

CALL select_all_bid_elements_in_project(3);

-- 9. Creating Procedure that calculates all parameters in every bid elements in selected project

DROP PROCEDURE IF EXISTS calculate_all_parameters_in_selected_project;
