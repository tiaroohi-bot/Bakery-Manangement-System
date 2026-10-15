CREATE DATABASE IF NOT EXISTS bakery_db;
USE bakery_db;


-- =========================================================
-- 1. CUSTOMER
-- =========================================================

CREATE TABLE IF NOT EXISTS Customer (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100),
    address VARCHAR(255)
);


-- =========================================================
-- 2. CATEGORY
-- =========================================================

CREATE TABLE IF NOT EXISTS Category (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE
);


-- =========================================================
-- 3. PRODUCT
-- =========================================================

CREATE TABLE IF NOT EXISTS Product (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category_id INT NOT NULL,
    price DECIMAL(10,2) NOT NULL DEFAULT 0,
    stock_quantity INT NOT NULL DEFAULT 0,

    CONSTRAINT chk_product_price
        CHECK (price >= 0),

    CONSTRAINT chk_product_stock
        CHECK (stock_quantity >= 0),

    CONSTRAINT fk_product_category
        FOREIGN KEY (category_id)
        REFERENCES Category(category_id)
);


-- =========================================================
-- 4. ORDERS
-- =========================================================

CREATE TABLE IF NOT EXISTS Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    order_status VARCHAR(30) NOT NULL DEFAULT 'Pending',

    CONSTRAINT chk_order_total
        CHECK (total_amount >= 0),

    CONSTRAINT fk_order_customer
        FOREIGN KEY (customer_id)
        REFERENCES Customer(customer_id)
);


-- =========================================================
-- 5. ORDER ITEM
-- =========================================================

CREATE TABLE IF NOT EXISTS Order_Item (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,

    CONSTRAINT chk_order_item_quantity
        CHECK (quantity > 0),

    CONSTRAINT chk_order_item_price
        CHECK (price >= 0),

    CONSTRAINT fk_order_item_order
        FOREIGN KEY (order_id)
        REFERENCES Orders(order_id),

    CONSTRAINT fk_order_item_product
        FOREIGN KEY (product_id)
        REFERENCES Product(product_id)
);


-- =========================================================
-- 6. PAYMENT
-- =========================================================

CREATE TABLE IF NOT EXISTS Payment (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    payment_method VARCHAR(30),
    payment_status VARCHAR(30) NOT NULL DEFAULT 'Pending',
    amount DECIMAL(10,2) NOT NULL DEFAULT 0,

    CONSTRAINT chk_payment_amount
        CHECK (amount >= 0),

    CONSTRAINT fk_payment_order
        FOREIGN KEY (order_id)
        REFERENCES Orders(order_id)
);


-- =========================================================
-- 7. EMPLOYEE
-- =========================================================

CREATE TABLE IF NOT EXISTS Employee (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    role VARCHAR(50),
    salary DECIMAL(10,2) DEFAULT 0,
    hire_date DATE,

    CONSTRAINT chk_employee_salary
        CHECK (salary >= 0)
);


-- =========================================================
-- 8. SUPPLIER
-- =========================================================

CREATE TABLE IF NOT EXISTS Supplier (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100),
    address VARCHAR(255)
);


-- =========================================================
-- 9. INGREDIENT
-- =========================================================

CREATE TABLE IF NOT EXISTS Ingredient (
    ingredient_id INT AUTO_INCREMENT PRIMARY KEY,
    ingredient_name VARCHAR(100) NOT NULL,
    quantity_available DECIMAL(10,2) NOT NULL DEFAULT 0,
    unit VARCHAR(20),
    supplier_id INT,

    CONSTRAINT chk_ingredient_quantity
        CHECK (quantity_available >= 0),

    CONSTRAINT fk_ingredient_supplier
        FOREIGN KEY (supplier_id)
        REFERENCES Supplier(supplier_id)
);


-- =========================================================
-- 10. PRODUCT INGREDIENT
-- =========================================================

CREATE TABLE IF NOT EXISTS Product_Ingredient (
    product_id INT NOT NULL,
    ingredient_id INT NOT NULL,
    quantity_required DECIMAL(10,2) NOT NULL,

    PRIMARY KEY (product_id, ingredient_id),

    CONSTRAINT chk_quantity_required
        CHECK (quantity_required > 0),

    CONSTRAINT fk_product_ingredient_product
        FOREIGN KEY (product_id)
        REFERENCES Product(product_id),

    CONSTRAINT fk_product_ingredient_ingredient
        FOREIGN KEY (ingredient_id)
        REFERENCES Ingredient(ingredient_id)
);


-- =========================================================
-- SAMPLE DATA
-- =========================================================

INSERT IGNORE INTO Category (category_name)
VALUES
('Cakes'),
('Pastries'),
('Brownies'),
('Bread');


INSERT IGNORE INTO Customer
(customer_id, name, phone, email, address)
VALUES
(1, 'Aarav Sharma', '9876543210', 'aarav@gmail.com', 'Delhi'),
(2, 'Riya Mehta', '9876543211', 'riya@gmail.com', 'Gurgaon'),
(3, 'Kabir Singh', '9876543212', 'kabir@gmail.com', 'Noida');


INSERT IGNORE INTO Product
(product_id, product_name, category_id, price, stock_quantity)
VALUES
(1, 'Chocolate Cake', 1, 1200.00, 10),
(2, 'Croissant', 2, 180.00, 25),
(3, 'Brownie', 3, 250.00, 20),
(4, 'Garlic Bread', 4, 300.00, 15);


INSERT IGNORE INTO Employee
(employee_id, employee_name, phone, role, salary, hire_date)
VALUES
(1, 'Rahul Verma', '9876500001', 'Baker', 30000, '2026-01-10'),
(2, 'Neha Singh', '9876500002', 'Cashier', 25000, '2026-02-15');


INSERT IGNORE INTO Supplier
(supplier_id, supplier_name, phone, email, address)
VALUES
(1, 'Fresh Foods Supply', '9876400001', 'fresh@example.com', 'Delhi'),
(2, 'BakeMart Suppliers', '9876400002', 'bakemart@example.com', 'Gurgaon');


INSERT IGNORE INTO Ingredient
(ingredient_id, ingredient_name, quantity_available, unit, supplier_id)
VALUES
(1, 'Flour', 100, 'kg', 1),
(2, 'Sugar', 50, 'kg', 1),
(3, 'Chocolate', 30, 'kg', 2);