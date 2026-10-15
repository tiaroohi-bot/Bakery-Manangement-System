USE bakery_db;


-- =========================================================
-- BAKERY MANAGEMENT SYSTEM
-- RDBMS LAB EXPERIMENTS
-- =========================================================


-- =========================================================
-- EXPERIMENT 1
-- ER DIAGRAM AND RELATIONAL MODEL
-- =========================================================

-- Final relations:
--
-- Customer(customer_id PK, name, phone, email, address)
-- Category(category_id PK, category_name)
-- Product(product_id PK, product_name, category_id FK, price, stock_quantity)
-- Orders(order_id PK, customer_id FK, order_date, total_amount, order_status)
-- Order_Item(order_item_id PK, order_id FK, product_id FK, quantity, price)
-- Payment(payment_id PK, order_id FK, payment_date, payment_method,
--         payment_status, amount)
-- Employee(employee_id PK, employee_name, phone, role, salary, hire_date)
-- Supplier(supplier_id PK, supplier_name, phone, email, address)
-- Ingredient(ingredient_id PK, ingredient_name, quantity_available,
--            unit, supplier_id FK)
-- Product_Ingredient(product_id FK, ingredient_id FK,
--                    quantity_required,
--                    PK(product_id, ingredient_id))


-- =========================================================
-- EXPERIMENT 2
-- DDL
-- =========================================================

CREATE TABLE IF NOT EXISTS Lab_Test_Table (
    id INT,
    test_name VARCHAR(50)
);

DESCRIBE Lab_Test_Table;

ALTER TABLE Lab_Test_Table
ADD COLUMN test_value INT;

ALTER TABLE Lab_Test_Table
MODIFY COLUMN test_value DECIMAL(10,2);

ALTER TABLE Lab_Test_Table
RENAME COLUMN test_value TO value_amount;

ALTER TABLE Lab_Test_Table
DROP COLUMN value_amount;

CREATE TABLE IF NOT EXISTS Lab_Rename_Table (
    id INT
);

RENAME TABLE Lab_Rename_Table
TO Lab_Renamed_Table;

RENAME TABLE Lab_Renamed_Table
TO Lab_Rename_Table;

TRUNCATE TABLE Lab_Test_Table;

DROP TABLE Lab_Test_Table;


-- =========================================================
-- EXPERIMENT 3
-- CONSTRAINTS
-- =========================================================

-- PRIMARY KEY
-- Already implemented in the final schema.

-- FOREIGN KEY
-- Already implemented in the final schema.

-- NOT NULL
-- Already implemented in the final schema.

-- DEFAULT
-- Already implemented in the final schema.

-- CHECK
-- Already implemented in the final schema.


-- Test CHECK constraint.
-- This should fail because price cannot be negative.

-- INSERT INTO Product
-- (product_name, category_id, price, stock_quantity)
-- VALUES ('Invalid Cake', 1, -100, 5);


-- Test CHECK constraint for stock.
-- This should fail.

-- INSERT INTO Product
-- (product_name, category_id, price, stock_quantity)
-- VALUES ('Invalid Product', 1, 500, -5);


-- Test foreign key.
-- This should fail if category 999 does not exist.

-- INSERT INTO Product
-- (product_name, category_id, price, stock_quantity)
-- VALUES ('Wrong Category Product', 999, 500, 5);


-- =========================================================
-- EXPERIMENT 4
-- DML
-- =========================================================

-- SINGLE ROW INSERT

INSERT INTO Customer
(name, phone, email, address)
VALUES
('Lab Customer', '9999999999', 'lab@example.com', 'Delhi');


-- MULTI ROW INSERT

INSERT INTO Customer
(name, phone, email, address)
VALUES
('Test Customer 1', '9000000001', 'test1@example.com', 'Delhi'),
('Test Customer 2', '9000000002', 'test2@example.com', 'Gurgaon');


-- UPDATE

UPDATE Product
SET price = price + 50
WHERE product_id = 1;


-- INSERT ... SELECT

CREATE TABLE IF NOT EXISTS High_Value_Products (
    product_id INT,
    product_name VARCHAR(100),
    price DECIMAL(10,2)
);

INSERT INTO High_Value_Products
SELECT
    product_id,
    product_name,
    price
FROM Product
WHERE price > 500;


-- DELETE

DELETE FROM Customer
WHERE name = 'Lab Customer';


-- =========================================================
-- EXPERIMENT 5
-- SELECT / WHERE / LIKE / DISTINCT / BETWEEN / IN
-- =========================================================

-- SELECT

SELECT *
FROM Product;


-- WHERE

SELECT *
FROM Product
WHERE price > 200;


-- LIKE

SELECT *
FROM Customer
WHERE name LIKE 'A%';


-- DISTINCT

SELECT DISTINCT role
FROM Employee;


-- BETWEEN

SELECT *
FROM Product
WHERE price BETWEEN 200 AND 1000;


-- IN

SELECT *
FROM Product
WHERE category_id IN (1, 2);


-- NOT IN

SELECT *
FROM Product
WHERE category_id NOT IN (1, 2);


-- NOT BETWEEN

SELECT *
FROM Product
WHERE price NOT BETWEEN 200 AND 1000;


-- =========================================================
-- EXPERIMENT 6
-- AGGREGATE / GROUPING / ORDERING
-- =========================================================

-- COUNT

SELECT COUNT(*) AS total_products
FROM Product;


-- COUNT DISTINCT

SELECT COUNT(DISTINCT category_id) AS total_categories_used
FROM Product;


-- SUM

SELECT SUM(stock_quantity) AS total_stock
FROM Product;


-- AVG

SELECT AVG(price) AS average_price
FROM Product;


-- MAX

SELECT MAX(price) AS highest_price
FROM Product;


-- MIN

SELECT MIN(price) AS lowest_price
FROM Product;


-- ORDER BY

SELECT *
FROM Product
ORDER BY price DESC;


-- LIMIT

SELECT *
FROM Product
ORDER BY price DESC
LIMIT 3;


-- GROUP BY

SELECT
    category_id,
    COUNT(*) AS product_count
FROM Product
GROUP BY category_id;


-- GROUP BY + AVG

SELECT
    category_id,
    AVG(price) AS average_price
FROM Product
GROUP BY category_id;


-- HAVING

SELECT
    category_id,
    AVG(price) AS average_price
FROM Product
GROUP BY category_id
HAVING AVG(price) > 200;


-- ORDER BY GROUPED RESULT

SELECT
    category_id,
    SUM(stock_quantity) AS total_stock
FROM Product
GROUP BY category_id
ORDER BY total_stock DESC;


-- =========================================================
-- EXPERIMENT 7
-- JOINS
-- =========================================================

-- INNER JOIN

SELECT
    p.product_name,
    c.category_name,
    p.price
FROM Product p
INNER JOIN Category c
    ON p.category_id = c.category_id;


-- LEFT JOIN

SELECT
    c.category_name,
    p.product_name
FROM Category c
LEFT JOIN Product p
    ON c.category_id = p.category_id;


-- RIGHT JOIN

SELECT
    c.category_name,
    p.product_name
FROM Category c
RIGHT JOIN Product p
    ON c.category_id = p.category_id;


-- FULL OUTER JOIN EQUIVALENT IN MYSQL

SELECT
    c.category_name,
    p.product_name
FROM Category c
LEFT JOIN Product p
    ON c.category_id = p.category_id

UNION

SELECT
    c.category_name,
    p.product_name
FROM Category c
RIGHT JOIN Product p
    ON c.category_id = p.category_id;


-- SELF JOIN

SELECT
    e1.employee_name AS employee_1,
    e2.employee_name AS employee_2,
    e1.role
FROM Employee e1
JOIN Employee e2
    ON e1.role = e2.role
   AND e1.employee_id < e2.employee_id;


-- NON-EQUI JOIN

SELECT
    p1.product_name AS product_1,
    p1.price AS price_1,
    p2.product_name AS product_2,
    p2.price AS price_2
FROM Product p1
JOIN Product p2
    ON p1.price > p2.price;


-- THREE TABLE JOIN

SELECT
    c.name AS customer_name,
    o.order_id,
    oi.quantity,
    p.product_name,
    oi.price
FROM Customer c
JOIN Orders o
    ON c.customer_id = o.customer_id
JOIN Order_Item oi
    ON o.order_id = oi.order_id
JOIN Product p
    ON oi.product_id = p.product_id;


-- =========================================================
-- EXPERIMENT 8
-- SUBQUERIES
-- =========================================================

-- IN

SELECT *
FROM Product
WHERE category_id IN (
    SELECT category_id
    FROM Category
    WHERE category_name IN ('Cakes', 'Pastries')
);


-- NOT IN

SELECT *
FROM Customer
WHERE customer_id NOT IN (
    SELECT customer_id
    FROM Orders
);


-- ANY

SELECT *
FROM Product
WHERE price > ANY (
    SELECT price
    FROM Product
    WHERE category_id = 2
);


-- ALL

SELECT *
FROM Product
WHERE price > ALL (
    SELECT price
    FROM Product
    WHERE category_id = 2
);


-- EXISTS

SELECT *
FROM Customer c
WHERE EXISTS (
    SELECT 1
    FROM Orders o
    WHERE o.customer_id = c.customer_id
);


-- CORRELATED SUBQUERY

SELECT
    p.product_name,
    p.price,
    p.category_id
FROM Product p
WHERE p.price > (
    SELECT AVG(p2.price)
    FROM Product p2
    WHERE p2.category_id = p.category_id
);


-- SUBQUERY WITH AGGREGATE

SELECT *
FROM Product
WHERE price = (
    SELECT MAX(price)
    FROM Product
);


-- =========================================================
-- EXPERIMENT 9
-- VIEWS
-- =========================================================

DROP VIEW IF EXISTS order_details_view;

CREATE VIEW order_details_view AS
SELECT
    o.order_id,
    c.name AS customer_name,
    o.order_date,
    o.total_amount,
    o.order_status
FROM Orders o
JOIN Customer c
    ON o.customer_id = c.customer_id;


SELECT *
FROM order_details_view;


-- SIMPLE VIEW

DROP VIEW IF EXISTS low_stock_products;

CREATE VIEW low_stock_products AS
SELECT
    product_id,
    product_name,
    price,
    stock_quantity
FROM Product
WHERE stock_quantity < 10;


SELECT *
FROM low_stock_products;


-- UPDATE THROUGH SIMPLE VIEW
-- Only run if you want to demonstrate updatable views.

-- UPDATE low_stock_products
-- SET price = price + 10
-- WHERE product_id = 1;


-- SHOW VIEWS

SHOW FULL TABLES
WHERE Table_type = 'VIEW';


-- DROP VIEW

DROP VIEW IF EXISTS low_stock_products;


-- =========================================================
-- EXPERIMENT 10
-- ACCESS AND PRIVILEGES
-- =========================================================

-- These commands require MySQL administrative privileges.

-- CREATE USER

-- CREATE USER 'bakery_staff'@'localhost'
-- IDENTIFIED BY 'BakeryStaff123!';


-- GRANT

-- GRANT SELECT, INSERT
-- ON bakery_db.*
-- TO 'bakery_staff'@'localhost';


-- GRANT UPDATE ON SPECIFIC TABLE

-- GRANT UPDATE
-- ON bakery_db.Product
-- TO 'bakery_staff'@'localhost';


-- SHOW GRANTS

-- SHOW GRANTS
-- FOR 'bakery_staff'@'localhost';


-- REVOKE

-- REVOKE UPDATE
-- ON bakery_db.Product
-- FROM 'bakery_staff'@'localhost';


-- DROP USER

-- DROP USER 'bakery_staff'@'localhost';


-- =========================================================
-- EXPERIMENT 11
-- TRANSACTION CONTROL
-- =========================================================

-- Check autocommit

SELECT @@autocommit;


-- TRANSACTION

START TRANSACTION;

UPDATE Product
SET stock_quantity = stock_quantity + 5
WHERE product_id = 1;

ROLLBACK;


-- TRANSACTION + COMMIT

START TRANSACTION;

UPDATE Product
SET stock_quantity = stock_quantity + 5
WHERE product_id = 1;

COMMIT;


-- SAVEPOINT

START TRANSACTION;

UPDATE Product
SET stock_quantity = stock_quantity + 10
WHERE product_id = 1;

SAVEPOINT stock_update;

UPDATE Product
SET stock_quantity = stock_quantity - 5
WHERE product_id = 2;

ROLLBACK TO SAVEPOINT stock_update;

COMMIT;


-- =========================================================
-- EXPERIMENT 12
-- TRIGGERS
-- =========================================================

-- STOCK AUDIT TABLE

CREATE TABLE IF NOT EXISTS Stock_Audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    old_stock INT,
    new_stock INT,
    changed_at DATETIME DEFAULT CURRENT_TIMESTAMP
);


-- BEFORE UPDATE TRIGGER
-- Prevent negative stock.

DROP TRIGGER IF EXISTS trg_prevent_negative_stock;

DELIMITER $$

CREATE TRIGGER trg_prevent_negative_stock
BEFORE UPDATE ON Product
FOR EACH ROW
BEGIN
    IF NEW.stock_quantity < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stock quantity cannot be negative';
    END IF;
END $$

DELIMITER ;


-- AFTER UPDATE TRIGGER
-- Record stock changes.

DROP TRIGGER IF EXISTS trg_stock_audit;

DELIMITER $$

CREATE TRIGGER trg_stock_audit
AFTER UPDATE ON Product
FOR EACH ROW
BEGIN
    IF OLD.stock_quantity <> NEW.stock_quantity THEN
        INSERT INTO Stock_Audit
        (product_id, old_stock, new_stock)
        VALUES
        (NEW.product_id, OLD.stock_quantity, NEW.stock_quantity);
    END IF;
END $$

DELIMITER ;


-- BEFORE INSERT TRIGGER
-- Prevent invalid product prices.

DROP TRIGGER IF EXISTS trg_product_price_check;

DELIMITER $$

CREATE TRIGGER trg_product_price_check
BEFORE INSERT ON Product
FOR EACH ROW
BEGIN
    IF NEW.price < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Product price cannot be negative';
    END IF;
END $$

DELIMITER ;


-- SHOW TRIGGERS

SHOW TRIGGERS;


-- =========================================================
-- EXPERIMENT 12
-- STORED PROCEDURES
-- =========================================================

-- PROCEDURE 1
-- Customer order summary

DROP PROCEDURE IF EXISTS CustomerOrderSummary;

DELIMITER $$

CREATE PROCEDURE CustomerOrderSummary(
    IN p_customer_id INT,
    OUT p_total_orders INT,
    OUT p_total_spent DECIMAL(12,2)
)
BEGIN

    SELECT COUNT(*)
    INTO p_total_orders
    FROM Orders
    WHERE customer_id = p_customer_id;

    SELECT IFNULL(SUM(total_amount), 0)
    INTO p_total_spent
    FROM Orders
    WHERE customer_id = p_customer_id;

END $$

DELIMITER ;


-- CALL PROCEDURE

CALL CustomerOrderSummary(
    1,
    @total_orders,
    @total_spent
);

SELECT
    @total_orders AS total_orders,
    @total_spent AS total_spent;


-- PROCEDURE 2
-- Apply discount to a category

DROP PROCEDURE IF EXISTS ApplyCategoryDiscount;

DELIMITER $$

CREATE PROCEDURE ApplyCategoryDiscount(
    IN p_category_id INT,
    IN p_discount DECIMAL(5,2)
)
BEGIN

    UPDATE Product
    SET price = price - (price * p_discount / 100)
    WHERE category_id = p_category_id;

END $$

DELIMITER ;


-- =========================================================
-- ADDITIONAL EXPERIMENT 1
-- CURSORS AND FUNCTIONS
-- =========================================================

-- FUNCTION
-- Calculate total amount spent by a customer.

DROP FUNCTION IF EXISTS CustomerTotalSpent;

DELIMITER $$

CREATE FUNCTION CustomerTotalSpent(
    p_customer_id INT
)
RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN

    DECLARE total_spent DECIMAL(12,2);

    SELECT IFNULL(SUM(total_amount), 0)
    INTO total_spent
    FROM Orders
    WHERE customer_id = p_customer_id;

    RETURN total_spent;

END $$

DELIMITER ;


-- USE FUNCTION

SELECT
    customer_id,
    name,
    CustomerTotalSpent(customer_id) AS total_spent
FROM Customer;


-- FUNCTION
-- Count customer orders.

DROP FUNCTION IF EXISTS CustomerOrderCount;

DELIMITER $$

CREATE FUNCTION CustomerOrderCount(
    p_customer_id INT
)
RETURNS INT
DETERMINISTIC
BEGIN

    DECLARE total_orders INT;

    SELECT COUNT(*)
    INTO total_orders
    FROM Orders
    WHERE customer_id = p_customer_id;

    RETURN total_orders;

END $$

DELIMITER ;


SELECT
    customer_id,
    name,
    CustomerOrderCount(customer_id) AS number_of_orders
FROM Customer;


-- =========================================================
-- CURSOR PROCEDURE
-- List low-stock products
-- =========================================================

DROP PROCEDURE IF EXISTS ListLowStockProducts;

DELIMITER $$

CREATE PROCEDURE ListLowStockProducts()
BEGIN

    DECLARE done INT DEFAULT FALSE;
    DECLARE v_product_id INT;
    DECLARE v_product_name VARCHAR(100);
    DECLARE v_stock INT;

    DECLARE product_cursor CURSOR FOR
        SELECT
            product_id,
            product_name,
            stock_quantity
        FROM Product
        WHERE stock_quantity < 10;

    DECLARE CONTINUE HANDLER
        FOR NOT FOUND SET done = TRUE;

    DROP TEMPORARY TABLE IF EXISTS temp_low_stock;

    CREATE TEMPORARY TABLE temp_low_stock (
        product_id INT,
        product_name VARCHAR(100),
        stock_quantity INT
    );

    OPEN product_cursor;

    read_loop: LOOP

        FETCH product_cursor
        INTO v_product_id, v_product_name, v_stock;

        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO temp_low_stock
        VALUES (
            v_product_id,
            v_product_name,
            v_stock
        );

    END LOOP;

    CLOSE product_cursor;

    SELECT *
    FROM temp_low_stock;

END $$

DELIMITER ;


CALL ListLowStockProducts();


-- =========================================================
-- ADDITIONAL EXPERIMENT 2
-- MYSQL EQUIVALENT OF PL/SQL COMMANDS
-- =========================================================


-- IF / ELSEIF / ELSE

DROP PROCEDURE IF EXISTS ClassifyProductStock;

DELIMITER $$

CREATE PROCEDURE ClassifyProductStock(
    IN p_product_id INT
)
BEGIN

    DECLARE v_stock INT;
    DECLARE v_status VARCHAR(30);

    SELECT stock_quantity
    INTO v_stock
    FROM Product
    WHERE product_id = p_product_id;

    IF v_stock IS NULL THEN

        SET v_status = 'NOT FOUND';

    ELSEIF v_stock = 0 THEN

        SET v_status = 'OUT OF STOCK';

    ELSEIF v_stock <= 10 THEN

        SET v_status = 'LOW';

    ELSEIF v_stock <= 50 THEN

        SET v_status = 'MEDIUM';

    ELSE

        SET v_status = 'GOOD';

    END IF;

    SELECT
        p_product_id AS product_id,
        v_stock AS stock_quantity,
        v_status AS stock_status;

END $$

DELIMITER ;


CALL ClassifyProductStock(1);


-- CASE

DROP PROCEDURE IF EXISTS CategoryClassification;

DELIMITER $$

CREATE PROCEDURE CategoryClassification(
    IN p_category_id INT
)
BEGIN

    DECLARE v_category_name VARCHAR(50);
    DECLARE v_type VARCHAR(30);

    SELECT category_name
    INTO v_category_name
    FROM Category
    WHERE category_id = p_category_id;

    SET v_type =
        CASE
            WHEN v_category_name = 'Cakes'
                THEN 'Premium Bakery'
            WHEN v_category_name = 'Pastries'
                THEN 'Pastry'
            WHEN v_category_name = 'Brownies'
                THEN 'Dessert'
            ELSE
                'Other'
        END;

    SELECT
        v_category_name AS category,
        v_type AS category_type;

END $$

DELIMITER ;


CALL CategoryClassification(1);


-- =========================================================
-- WHILE LOOP
-- =========================================================

DROP PROCEDURE IF EXISTS WhileDemo;

DELIMITER $$

CREATE PROCEDURE WhileDemo()
BEGIN

    DECLARE counter INT DEFAULT 1;

    WHILE counter <= 5 DO

        SELECT counter AS iteration_number;

        SET counter = counter + 1;

    END WHILE;

END $$

DELIMITER ;


CALL WhileDemo();


-- =========================================================
-- REPEAT LOOP
-- =========================================================

DROP PROCEDURE IF EXISTS RepeatDemo;

DELIMITER $$

CREATE PROCEDURE RepeatDemo()
BEGIN

    DECLARE counter INT DEFAULT 1;

    REPEAT

        SELECT counter AS iteration_number;

        SET counter = counter + 1;

    UNTIL counter > 5
    END REPEAT;

END $$

DELIMITER ;


CALL RepeatDemo();


-- =========================================================
-- LOOP + LEAVE
-- =========================================================

DROP PROCEDURE IF EXISTS LoopDemo;

DELIMITER $$

CREATE PROCEDURE LoopDemo()
BEGIN

    DECLARE counter INT DEFAULT 1;

    main_loop: LOOP

        SELECT counter AS iteration_number;

        SET counter = counter + 1;

        IF counter > 5 THEN
            LEAVE main_loop;
        END IF;

    END LOOP;

END $$

DELIMITER ;


CALL LoopDemo();


-- =========================================================
-- PROCEDURE WITH TRANSACTION + CONDITIONAL LOGIC
-- =========================================================

DROP PROCEDURE IF EXISTS IncreaseLowStock;

DELIMITER $$

CREATE PROCEDURE IncreaseLowStock(
    IN p_amount INT
)
BEGIN

    START TRANSACTION;

    UPDATE Product
    SET stock_quantity = stock_quantity + p_amount
    WHERE stock_quantity < 10;

    COMMIT;

END $$

DELIMITER ;


-- =========================================================
-- SHOW FINAL DATABASE OBJECTS
-- =========================================================

SHOW TABLES;

SHOW FULL TABLES
WHERE Table_type = 'VIEW';

SHOW TRIGGERS;

SHOW PROCEDURE STATUS
WHERE Db = 'bakery_db';

SHOW FUNCTION STATUS
WHERE Db = 'bakery_db';