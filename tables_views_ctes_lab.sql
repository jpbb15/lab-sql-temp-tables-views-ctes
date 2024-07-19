USE sakila;

-- Step 1: Create a View
-- First, create a view that summarizes rental information for each customer. The view should include the customer's ID, name, email address, and total number of rentals (rental_count).

CREATE VIEW customer_rental_summary AS
SELECT 
    c.customer_id AS customer_id,
    c.first_name AS customer_f_name,
    c.last_name AS customer_l_name,
    c.email AS customer_email,
    COUNT(r.rental_id) AS rental_count
FROM 
    customer c
LEFT JOIN 
    rental r ON c.customer_id = r.customer_id
GROUP BY 
    c.customer_id, 
    c.first_name, 
    c.last_name, 
    c.email;
    
SELECT * from customer_rental_summary;

-- Create a Temporary Table
-- Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.

CREATE TEMPORARY TABLE temp_customer_payment_summary AS
SELECT
    c.customer_id AS customer_id,
    c.customer_f_name AS customer_f_name,
    c.customer_l_name AS customer_l_name,
    c.customer_email AS customer_email,
    SUM(p.amount) AS total_paid
FROM
    customer_rental_summary c
LEFT JOIN
    payment p ON c.customer_id = p.customer_id
GROUP BY
    c.customer_id,
    c.customer_f_name,
    c.customer_l_name,
    c.customer_email;
    
SELECT * from temp_customer_payment_summary;

-- Create a CTE and the Customer Summary Report
-- Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. The CTE should include the customer's name, email address, rental count, and total amount paid.
WITH customer_summary_cte AS (
    SELECT
        c.customer_f_name AS customer_name,
        c.customer_email AS customer_email,
        c.rental_count AS rental_count,
        COALESCE(p.total_paid, 0) AS total_paid
    FROM
        customer_rental_summary c
    LEFT JOIN
        temp_customer_payment_summary p ON c.customer_id = p.customer_id
)

-- Next, using the CTE, create the query to generate the final customer summary report, which should include: customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.

SELECT
    customer_name,
    customer_email,
    rental_count,
    total_paid,
    CASE 
        WHEN rental_count > 0 THEN total_paid / rental_count
        ELSE 0
    END AS average_payment_per_rental
FROM
    customer_summary_cte;