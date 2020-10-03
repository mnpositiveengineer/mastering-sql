-- creating procedures

USE prefab_sales;
SET GLOBAL log_bin_trust_function_creators = 1;

-- 1. Creating procedure that calculates volume of bid element

DROP PROCEDURE IF EXISTS calculate_volume;

DELIMITER $$
CREATE PROCEDURE calculate_volume (bid_element_id INT)
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
END$$
DELIMITER ;

-- 2. Creating procedure that calculates total_volume of bid element

DROP PROCEDURE IF EXISTS calculate_total_volume;

DELIMITER $$
CREATE PROCEDURE calculate_total_volume (bid_element_id INT)
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
END$$
DELIMITER ;

-- 3. Creating procedure that calculates area of element (width * length)

DROP PROCEDURE IF EXISTS calculate_area;

DELIMITER $$
CREATE PROCEDURE calculate_area(bid_element_id INT)
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
END$$
DELIMITER ;

-- 4. Creating procedure that calculates total_area of bid element

DROP PROCEDURE IF EXISTS calculate_total_area;

DELIMITER $$
CREATE PROCEDURE calculate_total_area (bid_element_id INT)
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
END$$
DELIMITER ;

-- 5. Creating function that calculates weight of element (volume * 2,5)

DROP PROCEDURE IF EXISTS calculate_weight;

DELIMITER $$
CREATE PROCEDURE calculate_weight(bid_element_id INT)
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
END$$
DELIMITER ;

-- 6. Creating PROCEDURE that calculates total_weight of bid element

DROP PROCEDURE IF EXISTS calculate_total_weight;

DELIMITER $$
CREATE PROCEDURE calculate_total_weight (bid_element_id INT)
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
END$$
DELIMITER ;

-- 7. Creating Procedure that calculates all parameters - volume, total volume, area, total area, weight, total weight

DROP PROCEDURE IF EXISTS calculate_all_parameters;

DELIMITER $$
CREATE PROCEDURE calculate_all_parameters(bid_element_id INT)
BEGIN
	CALL calculate_volume(bid_element_id);
    CALL calculate_total_volume(bid_element_id);
	CALL calculate_area(bid_element_id);
    CALL calculate_total_area(bid_element_id);
	CALL calculate_weight(bid_element_id);
    CALL calculate_total_weight(bid_element_id);
END$$
DELIMITER ;

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

-- 9. Creating Procedure that calculates all parameters in every bid elements in selected project

DROP PROCEDURE IF EXISTS calculate_all_parameters_in_selected_project;

DELIMITER $$
CREATE PROCEDURE calculate_all_parameters_in_selected_project(project_id INT)
BEGIN
	DECLARE number_of_rows INT DEFAULT 0;
    DECLARE current_row INT DEFAULT 0;
    DECLARE current_id INT DEFAULT 0;
    
    SELECT count(*)
    INTO number_of_rows
    FROM (SELECT b.id FROM bidelements b WHERE b.project_id = project_id) a;
    
    SET current_row = 0;
    
    WHILE current_row < number_of_rows DO
    SELECT a.id INTO current_id 
    FROM (SELECT b.id FROM bidelements b WHERE b.project_id = project_id) a
    LIMIT current_row,1;
    
    CALL calculate_all_parameters(current_id);
    
    SET current_row = current_row + 1;
    END WHILE;
END$$
DELIMITER ;

-- 10. Creating procedure to set assembly_start and assembly_end of project

DROP PROCEDURE IF EXISTS assign_date_of_project;

DELIMITER $$
CREATE PROCEDURE assign_date_of_project(project_id INT , assembly_start DATE, assembly_end DATE)
BEGIN
	IF assembly_start > assembly_end THEN
		SIGNAL SQLSTATE '22003'
		SET MESSAGE_TEXT = "Assembly start must not be later than assembly end.";
    ELSE
		UPDATE bidelements b
        SET b.assembly_start = assembly_start, b.assembly_end = assembly_end
        WHERE b.project_id = project_id;
    END IF;
END$$
DELIMITER ;

-- 11. Create procedure that assign_financial_details_to_project

DROP PROCEDURE IF EXISTS assign_financial_details_to_project;

DELIMITER $$
CREATE PROCEDURE assign_financial_details_to_project
(
	project_id INT,
	concrete_cost DECIMAL(9,2),
	steel_cost DECIMAL(9,2),
    tension_steel_cost DECIMAL(9,2),
	framework_cost DECIMAL(9,2),
    man_hour_cost DECIMAL(9,2),
    energy_water_cost DECIMAL(9,2),
    faculty_cost DECIMAL(9,2),
    transport_cost DECIMAL(9,2),
    assembly_cost DECIMAL(9,2),
    markup DECIMAL(2,2)
)
BEGIN
	INSERT INTO financialdetails 
    (
		project_id,
		concrete_cost,
		steel_cost,
		tension_steel_cost,
		framework_cost,
		man_hour_cost,
		energy_water_cost,
		faculty_cost,
		transport_cost,
		assembly_cost,
		markup
    ) 
    VALUES
    (	
    	project_id,
		concrete_cost,
		steel_cost,
		tension_steel_cost,
		framework_cost,
		man_hour_cost,
		energy_water_cost,
		faculty_cost,
		transport_cost,
		assembly_cost,
		markup
    );
END$$
DELIMITER ;

-- 12. Creating Procedures that calculates prices of bid elements

-- to calculate prices in price_of_bidelements table use following formulas:
-- concrete_cost = financialdetails.concrete_cost * volume
-- steel_cost = financialdetails.steel_cost * (steel_saturation * volume)
-- tension_steel_cost = financialdetails.tension_steel_cost * (tension_steel_saturation * volume)
-- framework_cost = financialdetails.framework_cost * (area + width * height * 2 + length * height * 2)
-- man_hour_cost = financialdetails.man_hour_cost * volume
-- energy_water_cost = financialdetails.energy_water_cost * volume
-- faculty_cost = financialdetails.faculty_cost * volume
-- accessory_cost = accessories_bidelements.amount * accesories.unit_price
-- production_cost = concrete_cost + steel_cost + tension_steel_cost + framework_cost + man_hour_cost + energy_water_cost + faculty_cost + accessory_cost
-- total_production_cost = production_cost * amount
-- transport_cost = (total_weight of each type of elements / 21 ton) * financialdetails.transport_cost
-- total_transport_cost = transport_cost * amount
-- assembly_cost = financialdetails.assembly_cost
-- total_assembly_cost = total_assembly_cost * amount
-- element_cost = production_cost + transport_cost + ssembly_cost
-- total_element_cost = element_cost * amount
-- element_price = element_cost * (1 + markup)
-- total_element_price = element_price * amount

DROP FUNCTION IF EXISTS calculate_element_concrete_cost;

DELIMITER $$
CREATE FUNCTION calculate_element_concrete_cost (bid_element_id INT)
RETURNS DECIMAL (9,2)
READS SQL DATA
BEGIN
	DECLARE fd_concrete_cost DECIMAL (9,2);
    DECLARE b_volume DECIMAL (9,2);
    DECLARE pb_concrete_cost DECIMAL (9,2);
    
    SELECT fd.concrete_cost, b.volume
    INTO fd_concrete_cost, b_volume
    FROM bidelements b
    JOIN financialdetails fd
    USING (project_id)
    WHERE b.id = bid_element_id;
    
    SET pb_concrete_cost = fd_concrete_cost * b_volume;
    
    RETURN pb_concrete_cost;
END$$
DELIMITER ;

DROP FUNCTION IF EXISTS calculate_element_steel_cost;

DELIMITER $$
CREATE FUNCTION calculate_element_steel_cost (bid_element_id INT)
RETURNS DECIMAL (9,2)
READS SQL DATA
BEGIN
    DECLARE fd_steel_cost DECIMAL (9,2);
    DECLARE b_steel_saturation INT;
	DECLARE b_volume DECIMAL (9,2);
    DECLARE pb_steel_cost DECIMAL (9,2);
    
    SELECT fd.steel_cost, b.volume, b.steel_saturation
    INTO fd_steel_cost, b_volume, b_steel_saturation
    FROM bidelements b
    JOIN financialdetails fd
    USING (project_id)
    WHERE b.id = bid_element_id;
    
    SET pb_steel_cost = fd_steel_cost * b_steel_saturation * b_volume;
    
    RETURN pb_steel_cost;
END$$
DELIMITER ;

SELECT calculate_element_steel_cost (40);

DROP FUNCTION IF EXISTS calculate_element_tension_steel_cost;

DELIMITER $$
CREATE FUNCTION calculate_element_tension_steel_cost (bid_element_id INT)
RETURNS DECIMAL (9,2)
READS SQL DATA
BEGIN
    DECLARE fd_tension_steel_cost DECIMAL (9,2);
    DECLARE b_tension_steel_saturation INT;
	DECLARE b_volume DECIMAL (9,2);
    DECLARE pb_tension_steel_cost DECIMAL (9,2);
    
    SELECT fd.tension_steel_cost, b.volume, b.tension_steel_saturation
    INTO fd_tension_steel_cost, b_volume, b_tension_steel_saturation
    FROM bidelements b
    JOIN financialdetails fd
    USING (project_id)
    WHERE b.id = bid_element_id;
    
    SET pb_tension_steel_cost = fd_tension_steel_cost * b_tension_steel_saturation * b_volume;
    
    RETURN pb_tension_steel_cost;
END$$
DELIMITER ;