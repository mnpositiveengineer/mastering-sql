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

-- 12. Creating procedure that calculates prices of all bid elements in selected project

DROP PROCEDURE IF EXISTS calculated_all_prices_of_bid_elements_in_seleced_project;

DELIMITER $$
CREATE PROCEDURE calculated_all_prices_of_bid_elements_in_seleced_project(project_id INT)
BEGIN
    IF 
    NOT EXISTS (SELECT * FROM financialdetails fd WHERE fd.project_id = project_id)
    THEN
	SIGNAL SQLSTATE '22003'
	SET MESSAGE_TEXT = "No financial details assign to the project. Assign financial details first";
    ELSE
		BEGIN
		DECLARE number_of_bid_elements INT;
        DECLARE current_row INT;
        DECLARE current_bid_element_id INT;
        
        SELECT count(*)
        INTO number_of_bid_elements
        FROM bidelements b
        WHERE b.project_id = project_id;
        
        SET current_row = 0;
        
        WHILE current_row < number_of_bid_elements DO
        
        SELECT b.id
        INTO current_bid_element_id
        FROM bidelements b
        WHERE b.project_id = project_id
        LIMIT current_row,1;
        
        DELETE FROM pricesofbidelements pb
        WHERE pb.bid_element_id = current_bid_element_id;
        
        INSERT INTO pricesofbidelements 
        (
			bid_element_id, 
			amount, 
			concrete_cost, 
			steel_cost, 
			tension_steel_cost, 
			framework_cost, 
			man_hour_cost, 
			energy_water_cost, 
			faculty_cost, 
			accessory_cost, 
			production_cost, 
			total_production_cost, 
			transport_cost, 
			total_transport_cost, 
			assembly_cost, 
			total_assembly_cost, 
			element_cost, 
			total_element_cost, 
			element_price, 
			total_element_price
		) VALUES
        (
			current_bid_element_id,
            (SELECT amount FROM bidelements b WHERE b.id = current_bid_element_id),
            (SELECT calculate_element_concrete_cost (current_bid_element_id)),
			(SELECT calculate_element_steel_cost (current_bid_element_id)),
			(SELECT calculate_element_tension_steel_cost (current_bid_element_id)),
			(SELECT calculate_element_framework_cost (current_bid_element_id)),
			(SELECT calculate_man_hour_cost (current_bid_element_id)),
			(SELECT calculate_energy_water_cost (current_bid_element_id)),
			(SELECT calculate_faculty_cost (current_bid_element_id)),
			(SELECT calculate_accessory_cost (current_bid_element_id)),
            (SELECT calculate_production_cost (current_bid_element_id)),
            (SELECT calculate_total_production_cost (current_bid_element_id)),
            (SELECT calculate_transport_cost (current_bid_element_id)),
            (SELECT calculate_total_transport_cost (current_bid_element_id)),
            (SELECT calculate_assembly_cost (current_bid_element_id)),
            (SELECT calculate_total_assembly_cost (current_bid_element_id)),
            (SELECT calculate_element_cost (current_bid_element_id)),
            (SELECT calculate_total_element_cost(current_bid_element_id)),
            (SELECT calculate_element_price(current_bid_element_id)),
            (SELECT calculate_total_element_price(current_bid_element_id))
        );
        
        SET current_row = current_row + 1;
        
        END WHILE;
        END;
	END IF;
END$$
DELIMITER ;

-- 13. Creating procedure that updates pricesofbidelement for selected bidelement

DROP PROCEDURE IF EXISTS update_prices_for_selected_bid_element;

DELIMITER $$
CREATE PROCEDURE update_prices_for_selected_bid_element(bid_element_id INT)
BEGIN
	DECLARE amount INT;
    
    SELECT b.amount
    INTO amount
    FROM bidelements b
    WHERE b.id = bid_element_id;
    
	UPDATE pricesofbidelements pb
    SET
			pb.amount = amount,
			pb.concrete_cost =  calculate_element_concrete_cost (bid_element_id),
			pb.steel_cost = calculate_element_steel_cost (bid_element_id),
			pb.tension_steel_cost = calculate_element_tension_steel_cost (bid_element_id),
			pb.framework_cost = calculate_element_framework_cost (bid_element_id),
			pb.man_hour_cost = calculate_man_hour_cost (bid_element_id),
			pb.energy_water_cost = calculate_energy_water_cost (bid_element_id),
			pb.faculty_cost = calculate_faculty_cost (bid_element_id),
			pb.accessory_cost = calculate_accessory_cost (bid_element_id),
			pb.production_cost = calculate_production_cost (bid_element_id),
			pb.total_production_cost = calculate_total_production_cost (bid_element_id),
			pb.transport_cost = calculate_transport_cost (bid_element_id),
			pb.total_transport_cost = calculate_total_transport_cost (bid_element_id),
			pb.assembly_cost = calculate_assembly_cost (bid_element_id),
			pb.total_assembly_cost = calculate_total_assembly_cost (bid_element_id),
			pb.element_cost = calculate_element_cost (bid_element_id),
			pb.total_element_cost = calculate_total_element_cost(bid_element_id),
			pb.element_price = calculate_element_price(bid_element_id),
			pb.total_element_price = calculate_total_element_price(bid_element_id)
		WHERE pb.bid_element_id = bid_element_id;
END$$
DELIMITER ;

-- 14. Creating procedure that adds console to bid element

DROP PROCEDURE IF EXISTS add_console_to_bid_element;

DELIMITER $$
CREATE PROCEDURE add_console_to_bid_element 
(
	bid_element_id INT,
    name VARCHAR(50),
    amount INT, 
    height DECIMAL (3,2), 
    width DECIMAL (3,2), 
    length DECIMAL (3,2)
)
BEGIN
	IF (SELECT b.other_properties 
		FROM bidelements b 
        WHERE b.id = bid_element_id) 
        IS NULL
    THEN
	START TRANSACTION;
		UPDATE bidelements b
		SET other_properties = JSON_OBJECT(
			CONCAT('console_',name), JSON_OBJECT('amount', amount,
								'height', height,
								'width', width,
								'length', length
							)
		)
		WHERE b.id = bid_element_id;
		
		CALL calculate_all_parameters(bid_element_id);
	COMMIT;
    ELSE
    	START TRANSACTION;
		UPDATE bidelements b
		SET other_properties = JSON_SET(
			other_properties,
			CONCAT('$.console_',name), JSON_OBJECT(
								'amount', amount,
								'height', height,
								'width', width,
								'length', length
							)
		)
		WHERE b.id = bid_element_id;
		
		CALL calculate_all_parameters(bid_element_id);
	COMMIT;
    END IF;
END$$
DELIMITER ;

-- 15. Creating procedure that adds cutout to bid element

DROP PROCEDURE IF EXISTS add_cutout_to_bid_element;

DELIMITER $$
CREATE PROCEDURE  add_cutout_to_bid_element 
(
	bid_element_id INT,
    name VARCHAR(50),
    amount INT, 
    height DECIMAL (3,2), 
    width DECIMAL (3,2), 
    length DECIMAL (3,2)
)
BEGIN
	IF (SELECT b.other_properties 
		FROM bidelements b 
        WHERE b.id = bid_element_id) 
        IS NULL
    THEN
	START TRANSACTION;
		UPDATE bidelements b
		SET other_properties = JSON_OBJECT(
			CONCAT('cutout_',name), JSON_OBJECT('amount', amount,
								'height', height,
								'width', width,
								'length', length
							)
		)
		WHERE b.id = bid_element_id;
		
		CALL calculate_all_parameters(bid_element_id);
	COMMIT;
    ELSE
    	START TRANSACTION;
		UPDATE bidelements b
		SET other_properties = JSON_SET(
			other_properties,
			CONCAT('$.cutout_',name), JSON_OBJECT(
								'amount', amount,
								'height', height,
								'width', width,
								'length', length
							)
		)
		WHERE b.id = bid_element_id;
		
		CALL calculate_all_parameters(bid_element_id);
	COMMIT;
    END IF;
END$$
DELIMITER ;

