-- create function that calculates the risk factor for specific client and use it in select function
-- risk factor = invoice_total/number_of_invoices *5

DROP FUNCTION IF EXISTS calculate_risk_factor;

DELIMITER $$
CREATE FUNCTION calculate_risk_factor(client_id INT)
RETURNS INT
READS SQL DATA
BEGIN
	DECLARE risk_factor DECIMAL(9,2) DEFAULT 0;
    DECLARE invoice_sum DECIMAL(9,2);
    DECLARE number_of_invoices INT;
    
    SELECT COUNT(*), SUM(invoice_total)
    INTO number_of_invoices, invoice_sum
    FROM invoices i
    WHERE i.client_id = IFNULL(client_id, i.client_id);
    
    SET risk_factor = invoice_sum/number_of_invoices * 5;
	RETURN IFNULL(risk_factor, 0);
END$$
DELIMITER ;

SELECT
	client_id,
    name,
    calculate_risk_factor(client_id) AS risk_factor
FROM clients
ORDER BY risk_factor DESC;

-- create stored procedure that calculates the risk factor for specific client
-- risk factor = invoice_total/number_of_invoices *5

DROP PROCEDURE IF EXISTS calculate_risk_factor;

DELIMITER $$
CREATE PROCEDURE calculate_risk_factor (client_id INT)
BEGIN
	DECLARE risk_factor DECIMAL(9,2) DEFAULT 0;
    DECLARE invoice_sum DECIMAL(9,2);
    DECLARE number_of_invoices INT;
    
    SELECT COUNT(*), SUM(invoice_total)
    INTO number_of_invoices, invoice_sum
    FROM invoices i
    WHERE i.client_id = IFNULL(client_id, i.client_id);
    
    SET risk_factor = invoice_sum/number_of_invoices * 5;
    SELECT risk_factor;
END$$
DELIMITER ;
-- create procedur get_unpaid_invoices_from_client
-- where you select number of invoices of specific client and total amount of invoices
-- number of invoices and total amount add to variables as output parameters

DROP PROCEDURE IF EXISTS get_unpaid_invoices_from_client;

DELIMITER $$
CREATE PROCEDURE get_unpaid_invoices_from_client
(
	client_id INT,
    OUT number_of_invoices INT,
    OUT total_sum_of_invoices DECIMAL (9,2)
)
BEGIN
	SELECT COUNT(*), SUM(invoice_total)
    INTO number_of_invoices, total_sum_of_invoices
    FROM invoices i
    WHERE i.client_id = client_id;
END$$
DELIMITER ;

select @number_of_invoices, @total_sum_of_invoices;

-- create procedure 'make_payment' which
-- inserts payment into payments table
-- validate payment_amount value so it is more than 0

DROP PROCEDURE IF EXISTS make_payment;

DELIMITER $$
CREATE PROCEDURE make_payment
(
	p_invoice_id INT,
    p_amount DECIMAL (9,2),
    p_payment_method TINYINT
)
BEGIN
	IF p_amount <= 0 THEN
    SIGNAL SQLSTATE '22003'
    SET MESSAGE_TEXT = 'Amount must be greater than 0';
    ELSE
    INSERT INTO payments (invoice_id, client_id, date, amount, payment_method)
    VALUES (
			p_invoice_id,
			(SELECT i.client_id 
            FROM invoices i 
            WHERE i.invoice_id = p_invoice_id),
            CURDATE(),
            p_amount,
            p_payment_method
		);
    END IF;
END$$
DELIMITER ;

CALL make_payment (1, 14.53, 4);
CALL make_payment (1, 0, 1);
CALL make_payment (20, 1, 1);
CALL make_payment (1, 1, 5);


-- Write a stored procedure called get_payments
-- with two parameters
-- first parameter: client_id
-- second parameter: payment_method_id
-- both parameters are optional and if we provide NULL we want to retrieve all values

DROP PROCEDURE IF EXISTS get_payments;

DELIMITER $$
CREATE PROCEDURE get_payments(client_id INT, payment_method TINYINT)
BEGIN
	SELECT *
	FROM payments p
    WHERE p.client_id = IFNULL(client_id, p.client_id)
    AND p.payment_method = IFNULL(payment_method, p.payment_method);
END$$
DELIMITER ;

CALL get_payments(NULL,NULL);

-- Create a stored procedure called
-- get_invoices_with_balance
-- to return all the invoices with a balance > 0

DROP PROCEDURE IF EXISTS get_invoices_with_balance;

DELIMITER $$
CREATE PROCEDURE get_invoices_with_balance()
BEGIN
	SELECT * FROM invoice_with_balance;
END$$
DELIMITER ;

-- Write a stored procedure to return invoices
-- for a given client
-- get_invoicec_by_client

DROP PROCEDURE IF EXISTS get_invoicec_by_client;

DELIMITER $$
CREATE PROCEDURE get_invoice_by_client(client_id INT)
BEGIN
	SELECT * 
    FROM invoices i 
    WHERE i.client_id = client_id;
END$$
DELIMITER ;
