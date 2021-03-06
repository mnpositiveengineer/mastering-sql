-- crearing transaction

use sql_store;

START TRANSACTION;

	INSERT INTO orders (customer_id, order_date, status)
    VALUES (1, '2020-09-10', 1);
    
    INSERT INTO order_items
    VALUES (LAST_INSERT_ID(), 1, 1, 1);
    
ROLLBACK;

SHOW VARIABLES LIKE 'autocommit';

SET autocommit = OFF;

CREATE OR REPLACE VIEW invoice_with_balance AS
SELECT
	*
FROM invoices
WHERE (invoice_total-payment_total) > 0
WITH CHECK OPTION;

UPDATE invoice_with_balance
SET payment_total = invoice_total
WHERE invoice_id = 1;

UPDATE invoice_with_balance
SET payment_total = invoice_total
WHERE invoice_id = 5;

-- create a view to see the balance for each client

use sql_invoicing;

CREATE VIEW clients_balance AS
	SELECT 
		c.client_id,
        c.name,
        SUM(i.payment_total - i.invoice_total) AS balance
	FROM clients c
    JOIN invoices i
    USING (client_id)
    GROUP BY client_id, name;

-- write a querry to produce a table consist of cutomer full name, points and category
-- category = Gold if points > 3000
-- category = Silver if points between 2000 and 3000
-- cateogry = Bronce if points less than 2000

SELECT
	CONCAT(first_name, ' ', last_name) AS name,
    points,
    CASE
		WHEN points > 3000 THEN 'Gold'
        WHEN points BETWEEN 2000 AND 3000 THEN 'Silver'
        ELSE 'Bronze'
	END AS category
FROM customers
ORDER BY points DESC;

-- write a querry to produce table consists of 'product_id', 'name', how many time it was ordered,
-- and if more that once display 'many times' otherwise 'Once'

use sql_store;

SELECT 
	DISTINCT p.product_id,
    p.name,
    COUNT(*) AS orders,
    IF ( COUNT(*) > 1, 
        'Many times',
        'Once') AS frequency
FROM products p
JOIN order_items oi
USING (product_id)
GROUP BY product_id;


-- Select customer first name and last name in one column and phone number and if the phone is null then return "Unknown"

SELECT
	CONCAT(first_name, ' ', last_name) AS name,
    IFNULL(phone, 'Unknown') AS phone
FROM customers;

-- retrieve the table that shows client_id, client name,
-- total sales of that client, average sales of all client
-- the difference between total sales and average
USE sql_invoicing;

SELECT
	client_id,
    name,
    (SELECT SUM(invoice_total) FROM invoices
    WHERE client_id = c.client_id)
    AS total_sales,
    (SELECT AVG(invoice_total) FROM invoices)
    AS average,
    ((SELECT total_sales) - (SELECT average))
    AS difference
FROM clients c;
    
-- get invoices that are larger than the
-- client's average invoice amount

USE sql_invoicing;

SELECT invoice_id
FROM invoices i
WHERE invoice_total > 
			(SELECT AVG(invoice_total)
			FROM invoices
			WHERE client_id = i.client_id);

-- select employees whose salary is above the average in their office

USE sql_hr;

SELECT e.first_name, e.last_name
FROM employees e
JOIN
(SELECT office_id, AVG(salary) AS average_salary
FROM employees
GROUP BY office_id) j
USING (office_id)
WHERE salary > j.average_salary;

SELECT e.first_name, e.last_name
FROM employees e
WHERE salary > (SELECT AVG(salary)
				FROM employees
                WHERE office_id = e.office_id);


-- select clients with at least two invoices

use sql_invoicing;

SELECT client_id, count(*) as numbers_of_invoices
FROM invoices
GROUP BY client_id
HAVING numbers_of_invoices >=2;

-- select clients that have an invoice

USE sql_invoicing;

SELECT client_id 
FROM clients
WHERE client_id IN 
		(SELECT client_id
		FROM invoices);
        
-- MORE EFFICIENT:

SELECT client_id
FROM clients c
WHERE EXISTS (SELECT * FROM invoices
				WHERE client_id = c.client_id);
        

-- select invoices larger than all invoices of client 3
USE sql_invoicing;

SELECT invoice_id
FROM invoices
WHERE invoice_total > ALL (SELECT invoice_total
							FROM invoices
                            WHERE client_id = 3);


-- find customers who have ordered product (id = 3)
-- select customer_id, first_name, last_name

USE sql_store;

SELECT DISTINCT c.customer_id, c.first_name, c.last_name
FROM customers c
JOIN orders o USING (customer_id)
WHERE o.order_id IN
				(SELECT DISTINCT order_id
                FROM order_items
                WHERE product_id = 3);


-- find clients without invoicing

USE sql_invoicing;

SELECT * FROM clients
WHERE client_id NOT IN 
			(SELECT DISTINCT client_id
            FROM invoices);
            
SELECT c.client_id, c.name
FROM clients c
LEFT JOIN invoices i USING (client_id)
WHERE invoice_id IS NULL;

-- find the products that have never been ordered
USE sql_store;

SELECT * FROM products
WHERE product_id NOT IN 
		(SELECT product_id
        FROM order_items);
        
-- MORE EFFICIENT

SELECT * FROM products p
WHERE NOT EXISTS (SELECT * FROM order_items
				WHERE product_id = p.product_id);

-- find all employees who earn more than average
use sql_hr;

SELECT * FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees)
ORDER BY salary DESC;

-- find products that are more expensive than Lettuce (id = 3)
use sql_store;
SELECT * FROM products
WHERE unit_price > (SELECT unit_price
                    FROM products
                    WHERE product_id = 3);


                    
-- Select all orders from this year

use sql_store;

SELECT *
FROM orders
WHERE YEAR(order_date) = YEAR(NOW());


-- write a sql statement to
-- give any customers born before 1990
-- 50 extra points

use sql_store;

UPDATE customers
SET points = points + 50
WHERE birth_date < '1990-01-01';

-- update column comments in sql_store.orders table to inform that this order belongs to a customers with more than 3000 points ('gold customers')
use sql_store;

UPDATE orders
SET comments = "gold customer"
WHERE customer_id IN
	(SELECT customer_id 
    FROM customers
    WHERE points > 3000);


-- generating report

use sql_invoicing;

SELECT 
"First half of 2019" AS date_range,
SUM(invoice_total) AS total_sales,
SUM(payment_total) AS total_payments,
SUM(invoice_total) - SUM(payment_total) AS what_we_expect
FROM invoices WHERE invoice_date < '2019-07-01'
UNION
SELECT 
"Second half of 2019" AS date_range,
SUM(invoice_total) AS total_sales,
SUM(payment_total) AS total_payments,
SUM(invoice_total) - SUM(payment_total) AS what_we_expect
FROM invoices WHERE invoice_date >= '2019-07-01'
UNION
SELECT
"Total" AS date_range,
SUM(invoice_total) AS total_sales,
SUM(payment_total) AS total_payments,
SUM(invoice_total) - SUM(payment_total) AS what_we_expect
FROM invoices;

-- retireve total payment for each date and payment_method combination

use sql_invoicing;

SELECT 
p.date,
pm.name AS payment_method,
SUM(p.amount) AS total_payment
FROM payments p
JOIN payment_methods pm
ON p.payment_method = pm.payment_method_id
GROUP BY p.date, pm.name;

-- Get the customers
-- who are located in Virginia
-- who have spent more than $100

use sql_invoicing;

SELECT c.client_id, SUM(i.payment_total) AS total_spent
FROM clients c
JOIN invoices i USING (client_id)
WHERE c.state = 'VA'
GROUP BY c.client_id
HAVING total_spent > 100;

use sql_store;

SELECT c.customer_id, SUM(oi.quantity * oi.unit_price) as total_amount_spent_by_customer
FROM customers c
JOIN orders o USING (customer_id)
JOIN order_items oi USING (order_id)
WHERE c.state = 'VA'
GROUP BY c.customer_id
HAVING total_amount_spent_by_customer > 100;


-- retrieve total amount of payment for each payment_method with rollup

use sql_invoicing;

SELECT pm.name AS payment_method, SUM(p.amount)
FROM payment_methods pm
JOIN payments p
ON p.payment_method = pm.payment_method_id
GROUP BY pm.name WITH ROLLUP;
    
    