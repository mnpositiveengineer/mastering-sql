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
    
    