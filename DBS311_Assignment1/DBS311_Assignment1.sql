-- *******************************
-- Student Name: Mengyao Liu 
-- Date: Mar/10/2022
-- Purpose: Assignment 1 - DBS311
-- *******************************
 
-- *Question#1* Display the employee number, full employee name, job title, and hire date of all employees hired 
-- in September with the most recently hired employees displayed first. 
-- Q1 SOLUTION 
SELECT employee_id AS "Employee Number", 
        first_name || ' ' || last_name as "Full Name", 
        job_title AS "Job Title", 
        TO_CHAR(hire_date, '[Month ddTH" of year "YYYY]') AS "Start Date"
FROM employees
WHERE hire_date LIKE '__SEP__'
ORDER BY hire_date DESC,
        employee_id;

-- *Question#2* The company wants to see the total sale amount per salesperson (salesman) for all orders. 
-- Assume that online orders do not have any sales representative. For online orders (orders with no salesman ID), consider the salesman ID as 0. 
-- Display the salesman ID and the total sale amount for each employee. Sort the result according to employee number.
-- Q2 SOLUTION 
SELECT NVL(orders.salesman_id,0) AS "Employee Number", 
        TO_CHAR(ROUND(SUM(ord.total),2), '$99,999,999.99') AS "Total Sale" 
FROM (SELECT order_id, SUM(quantity*unit_price) AS total
        FROM order_items 
        GROUP BY order_id 
        ORDER BY order_id) ord
INNER JOIN orders
ON ord.order_id = orders.order_id
GROUP BY orders.salesman_id
ORDER BY NVL(orders.salesman_id,0) ASC;

-- *Question#3* Display customer ID, customer name and total number of orders for customers that the value of their customer ID is in values from 35 to 45. 
-- Include the customers with no orders in your report if their customer ID falls in the range 35 and 45. Sort the result by the value of total orders.
-- Q3 SOLUTION 
SELECT customers.customer_id AS "Customer ID", 
        customers.name AS "Customer Name", 
        COUNT(ord.order_id) AS "Total Orders"
FROM customers
FULL OUTER JOIN orders ord
ON customers.customer_id = ord.customer_id 
WHERE customers.customer_id BETWEEN 35 and 45 
GROUP BY customers.customer_id, customers.name 
ORDER BY "Total Orders";

-- *Question#4* Display customer ID, customer name, and the order ID and the order date of all orders for customer whose ID is 44.
-- a) Show the total quantity and the total amount of each customer’s order.
-- b) Sort the result from the highest to lowest total order amount.
-- Q4 SOLUTION 
SELECT orders.customer_id AS "Customer ID", 
        customers.name AS "Customer Name",
        orders.order_id AS "Order Id", 
        TO_CHAR(orders.order_date,'DD-MON-YY') AS "Order Date", 
        ord.totalquantity AS "Total Items", 
        TO_CHAR(ord.totalsales,'$9,999,999.99') AS "Total Amount"
FROM (SELECT order_id, SUM(quantity) AS totalquantity, 
            SUM(quantity*unit_price) AS totalsales
        FROM order_items
        GROUP BY order_id) ord
JOIN orders
ON orders.order_id = ord.order_id
JOIN customers
ON orders.customer_id = customers.customer_id 
WHERE orders.customer_id = 44
ORDER BY ord.totalsales DESC;

-- *Question#5* Display customer Id, name, total number of orders, the total number of items ordered, and the total order amount for customers who have more than 30 orders. 
-- Sort the result based on the total number of orders.
-- Q5 SOLUTION 
SELECT customers.customer_id AS "Customer ID", 
        customers.name AS "Customer Name", 
        COUNT(orders.order_id) AS "Total Number of Orders",
        SUM(order_items.quantity) AS "Total Items",
        TO_CHAR(SUM(order_items.quantity*order_items.unit_price),'$99,999, 999.99') AS "Total Amount"
FROM customers 
JOIN orders
ON customers.customer_id = orders.customer_id 
JOIN order_items 
ON order_items.order_id = orders.order_id
GROUP BY customers.customer_id,
        customers.name 
HAVING COUNT(orders.order_id) > 30
ORDER BY "Total Number of Orders";

-- *Question#6* Display Warehouse ID, warehouse name, product category ID, product category name, and the lowest product standard cost for this combination.
-- a) In your result, include the rows that the lowest standard cost is less than $200.
-- b) Also, include the rows that the lowest cost is more than $500.
-- c) Sort the output according to Warehouse Id, warehouse name and then product category Id, and product category name.
-- Q6 SOLUTION 
SELECT warehouses.warehouse_id AS "Warehouse ID", 
        warehouses.warehouse_name AS "Warehouse Name", 
        products.category_id AS "Category ID", 
        product_categories.category_name AS "Category Name", 
        MIN(products.standard_cost) AS "Lowest Cost"
FROM warehouses
JOIN inventories
ON warehouses.warehouse_id = inventories.warehouse_id
JOIN products
ON inventories.product_id = products.product_id
JOIN product_categories
ON product_categories.category_id = products.category_id
GROUP BY warehouses.warehouse_id, 
        warehouses.warehouse_name, 
        products.category_id, 
        product_categories.category_name
HAVING MIN(products.standard_cost) > 500
OR MIN(products.standard_cost) < 200
ORDER BY warehouses.warehouse_id;

-- *Question#7* Display the total number of orders per month. Sort the result from January to December.
-- Q7 SOLUTION 
SELECT TO_CHAR(TO_DATE(EXTRACT(month FROM order_date),'MM'), 'Month') AS "Month", 
        COUNT(EXTRACT(month FROM order_date)) AS "Number of Orders"
FROM orders
GROUP BY EXTRACT(month FROM order_date) 
ORDER BY EXTRACT(month FROM order_date);

-- *Question#8* Display product ID, product name for products that their list price is more than any highest product standard cost per warehouse outside Americas regions. 
-- (You need to find the highest standard cost for each warehouse that is located outside the Americas regions. 
-- Then you need to return all products that their list price is higher than any highest standard cost of those warehouses.)
-- Sort the result according to list price from highest value to the lowest.
-- Q8 SOLUTION 
SELECT products.product_id AS "Product ID", 
        products.product_name AS "Product Name", 
        TO_CHAR(products.list_price,'$999,999,999.99') AS "Price" FROM products
WHERE products.list_price > ANY(SELECT MAX(products.standard_cost)
FROM products
JOIN inventories 
ON products.product_id = inventories.product_id
JOIN warehouses 
ON inventories.warehouse_id = warehouses.warehouse_id
JOIN locations 
ON warehouses.location_id = locations.location_id
JOIN countries 
ON locations.country_id = countries.country_id
JOIN regions 
ON countries.region_id = regions.region_id 
WHERE LOWER(regions.region_name) != 'americas' 
GROUP BY warehouses.warehouse_id)
ORDER BY "Price" DESC;

-- *Question#9* Write a SQL statement to display the most expensive and the cheapest product (list price). Display product ID, product name, and the list price.
-- Q9 SOLUTION 
SELECT product_id AS "Product ID", 
        product_name AS "Product Name", 
        list_price AS "Price"
FROM products
WHERE list_price = (SELECT MAX(list_price) FROM products)
UNION 
    SELECT product_id, 
            product_name, 
            list_price
    FROM products
    WHERE list_price = (SELECT MIN(list_price) FROM products);

-- *Question#10* Write a SQL query to display the number of customers with total order amount over the average amount of all orders, the number of customers with total order amount under the average amount of all orders, 
-- number of customers with no orders, and the total number of customers. See the format of the following result.
-- Q10 SOLUTION 
SELECT "Customer Report"
FROM (SELECT 'Number of customers with total purchase amount over average: ' || COUNT(*) AS "Customer Report", 
            1 SORTORDER
    FROM (SELECT customers.customer_id, 
                SUM(order_items.quantity*order_items.unit_price) AS total_amount
        FROM customers
        JOIN orders
        ON customers.customer_id = orders.customer_id 
        JOIN order_items
        ON order_items.order_id = orders.order_id 
    GROUP BY customers.customer_id)
    WHERE total_amount > (SELECT AVG (quantity*unit_price) FROM order_items)
    UNION ALL 
    SELECT 'Number of customers with total purchase amount over average: ' || COUNT(*) AS "Customer Report", 
            2 SORTORDER
    FROM (SELECT customers.customer_id, 
                SUM(order_items.quantity*order_items.unit_price) AS total_amount
        FROM customers
        JOIN orders
        ON customers.customer_id = orders.customer_id 
        JOIN order_items
        ON order_items.order_id = orders.order_id 
        GROUP BY customers.customer_id)
    WHERE total_amount < (SELECT AVG (quantity*unit_price) FROM order_items)
    UNION ALL 
    SELECT CONCAT('Number of customers with no orders: ',
            COUNT(CUSTOMERS) - COUNT(ORDERS)) AS "Customer Report", 
            3 SORTORDER
    FROM (SELECT customers.customer_id AS CUSTOMERS, SUM(orders.order_id) AS ORDERS
        FROM customers
        LEFT OUTER JOIN orders
        ON customers.customer_id = orders.customer_id 
        GROUP BY customers.customer_id)
    UNION ALL 
    SELECT CONCAT('Total number of customers: ',
            COUNT(CUSTOMERS)) AS "Customer Report", 
            4 SORTORDER
    FROM (SELECT customers.customer_id AS CUSTOMERS, 
                SUM(orders.order_id) AS ORDERS
        FROM customers
        LEFT OUTER JOIN orders
        ON customers.customer_id = orders.customer_id 
        GROUP BY customers.customer_id))
ORDER BY SORTORDER;
