-- create procedure 'make_payment'
-- insert payment into payments table
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
