import os

from flask import Flask, render_template, request, redirect, url_for

import mysql.connector

from dotenv import load_dotenv


# ============================================================
# APP SETUP
# ============================================================

load_dotenv()

app = Flask(__name__)


# ============================================================
# DATABASE CONNECTION
# ============================================================

def get_db_connection():
    return mysql.connector.connect(
        host=os.getenv("DB_HOST", "localhost"),
        user=os.getenv("DB_USER", "root"),
        password=os.getenv("DB_PASSWORD", ""),
        database=os.getenv("DB_NAME", "bakery_db")
    )


# ============================================================
# DASHBOARD
# ============================================================

@app.route("/")
def dashboard():

    db = get_db_connection()
    cursor = db.cursor()

    # Total customers
    cursor.execute("""
        SELECT COUNT(*)
        FROM Customer
    """)
    total_customers = cursor.fetchone()[0]

    # Total products
    cursor.execute("""
        SELECT COUNT(*)
        FROM Product
    """)
    total_products = cursor.fetchone()[0]

    # Total ACTIVE orders
    # Cancelled orders are NOT included
    cursor.execute("""
        SELECT COUNT(*)
        FROM Orders
        WHERE order_status != 'Cancelled'
    """)
    total_orders = cursor.fetchone()[0]

    # Total suppliers
    cursor.execute("""
        SELECT COUNT(*)
        FROM Supplier
    """)
    total_suppliers = cursor.fetchone()[0]

    # Total ingredients
    cursor.execute("""
        SELECT COUNT(*)
        FROM Ingredient
    """)
    total_ingredients = cursor.fetchone()[0]

    # Pending orders
    cursor.execute("""
        SELECT COUNT(*)
        FROM Orders
        WHERE order_status = 'Pending'
    """)
    pending_orders = cursor.fetchone()[0]

    cursor.close()
    db.close()

    return render_template(
        "dashboard.html",
        total_customers=total_customers,
        total_products=total_products,
        total_orders=total_orders,
        total_suppliers=total_suppliers,
        total_ingredients=total_ingredients,
        pending_orders=pending_orders
    )


# ============================================================
# CUSTOMERS
# ============================================================

@app.route("/customers")
def customers():

    db = get_db_connection()
    cursor = db.cursor(dictionary=True)

    cursor.execute("""
        SELECT *
        FROM Customer
        ORDER BY customer_id
    """)

    customer_list = cursor.fetchall()

    cursor.close()
    db.close()

    return render_template(
        "customers.html",
        customers=customer_list
    )


@app.route("/add_customer", methods=["POST"])
def add_customer():

    name = request.form["name"]
    phone = request.form["phone"]
    email = request.form["email"]
    address = request.form["address"]

    db = get_db_connection()
    cursor = db.cursor()

    cursor.execute("""
        INSERT INTO Customer
        (name, phone, email, address)
        VALUES (%s, %s, %s, %s)
    """, (
        name,
        phone,
        email,
        address
    ))

    db.commit()

    cursor.close()
    db.close()

    return redirect(url_for("customers"))


@app.route("/edit_customer/<int:customer_id>")
def edit_customer(customer_id):

    db = get_db_connection()
    cursor = db.cursor(dictionary=True)

    cursor.execute("""
        SELECT *
        FROM Customer
        WHERE customer_id = %s
    """, (customer_id,))

    customer = cursor.fetchone()

    cursor.close()
    db.close()

    return render_template(
        "edit_customer.html",
        customer=customer
    )


@app.route("/update_customer/<int:customer_id>", methods=["POST"])
def update_customer(customer_id):

    name = request.form["name"]
    phone = request.form["phone"]
    email = request.form["email"]
    address = request.form["address"]

    db = get_db_connection()
    cursor = db.cursor()

    cursor.execute("""
        UPDATE Customer
        SET
            name = %s,
            phone = %s,
            email = %s,
            address = %s
        WHERE customer_id = %s
    """, (
        name,
        phone,
        email,
        address,
        customer_id
    ))

    db.commit()

    cursor.close()
    db.close()

    return redirect(url_for("customers"))


@app.route("/delete_customer/<int:customer_id>", methods=["POST"])
def delete_customer(customer_id):

    db = get_db_connection()
    cursor = db.cursor()

    cursor.execute("""
        DELETE FROM Customer
        WHERE customer_id = %s
    """, (customer_id,))

    db.commit()

    cursor.close()
    db.close()

    return redirect(url_for("customers"))


# ============================================================
# CATEGORIES
# ============================================================

@app.route("/categories")
def categories():

    db = get_db_connection()
    cursor = db.cursor(dictionary=True)

    cursor.execute("""
        SELECT *
        FROM Category
        ORDER BY category_name
    """)

    category_list = cursor.fetchall()

    cursor.close()
    db.close()

    return render_template(
        "categories.html",
        categories=category_list
    )


@app.route("/add_category", methods=["POST"])
def add_category():

    category_name = request.form["category_name"]

    db = get_db_connection()
    cursor = db.cursor()

    cursor.execute("""
        INSERT INTO Category
        (category_name)
        VALUES (%s)
    """, (category_name,))

    db.commit()

    cursor.close()
    db.close()

    return redirect(url_for("categories"))


@app.route("/delete_category/<int:category_id>", methods=["POST"])
def delete_category(category_id):

    db = get_db_connection()
    cursor = db.cursor()

    cursor.execute("""
        DELETE FROM Category
        WHERE category_id = %s
    """, (category_id,))

    db.commit()

    cursor.close()
    db.close()

    return redirect(url_for("categories"))


# ============================================================
# PRODUCTS
# ============================================================

@app.route("/products")
def products():

    db = get_db_connection()
    cursor = db.cursor(dictionary=True)

    cursor.execute("""
        SELECT
            p.product_id,
            p.product_name,
            p.category_id,
            c.category_name,
            p.price,
            p.stock_quantity
        FROM Product p
        LEFT JOIN Category c
            ON p.category_id = c.category_id
        ORDER BY p.product_id
    """)

    product_list = cursor.fetchall()

    cursor.execute("""
        SELECT *
        FROM Category
        ORDER BY category_name
    """)

    category_list = cursor.fetchall()

    cursor.close()
    db.close()

    return render_template(
        "products.html",
        products=product_list,
        categories=category_list
    )


@app.route("/add_product", methods=["POST"])
def add_product():

    product_name = request.form["product_name"]
    category_id = request.form["category_id"]
    price = request.form["price"]
    stock_quantity = request.form["stock_quantity"]

    db = get_db_connection()
    cursor = db.cursor()

    cursor.execute("""
        INSERT INTO Product
        (
            product_name,
            category_id,
            price,
            stock_quantity
        )
        VALUES (%s, %s, %s, %s)
    """, (
        product_name,
        category_id,
        price,
        stock_quantity
    ))

    db.commit()

    cursor.close()
    db.close()

    return redirect(url_for("products"))


@app.route("/edit_product/<int:product_id>")
def edit_product(product_id):

    db = get_db_connection()
    cursor = db.cursor(dictionary=True)

    cursor.execute("""
        SELECT *
        FROM Product
        WHERE product_id = %s
    """, (product_id,))

    product = cursor.fetchone()

    cursor.execute("""
        SELECT *
        FROM Category
        ORDER BY category_name
    """)

    category_list = cursor.fetchall()

    cursor.close()
    db.close()

    return render_template(
        "edit_product.html",
        product=product,
        categories=category_list
    )


@app.route("/update_product/<int:product_id>", methods=["POST"])
def update_product(product_id):

    product_name = request.form["product_name"]
    category_id = request.form["category_id"]
    price = request.form["price"]
    stock_quantity = request.form["stock_quantity"]

    db = get_db_connection()
    cursor = db.cursor()

    cursor.execute("""
        UPDATE Product
        SET
            product_name = %s,
            category_id = %s,
            price = %s,
            stock_quantity = %s
        WHERE product_id = %s
    """, (
        product_name,
        category_id,
        price,
        stock_quantity,
        product_id
    ))

    db.commit()

    cursor.close()
    db.close()

    return redirect(url_for("products"))


@app.route("/delete_product/<int:product_id>", methods=["POST"])
def delete_product(product_id):

    db = get_db_connection()
    cursor = db.cursor()

    cursor.execute("""
        DELETE FROM Product
        WHERE product_id = %s
    """, (product_id,))

    db.commit()

    cursor.close()
    db.close()

    return redirect(url_for("products"))


# ============================================================
# EMPLOYEES
# ============================================================

@app.route("/employees")
def employees():

    db = get_db_connection()
    cursor = db.cursor(dictionary=True)

    cursor.execute("""
        SELECT *
        FROM Employee
        ORDER BY employee_id
    """)

    employee_list = cursor.fetchall()

    cursor.close()
    db.close()

    return render_template(
        "employees.html",
        employees=employee_list
    )


@app.route("/add_employee", methods=["POST"])
def add_employee():

    employee_name = request.form["employee_name"]
    phone = request.form["phone"]
    role = request.form["role"]
    salary = request.form["salary"]
    hire_date = request.form["hire_date"]

    db = get_db_connection()
    cursor = db.cursor()

    cursor.execute("""
        INSERT INTO Employee
        (
            employee_name,
            phone,
            role,
            salary,
            hire_date
        )
        VALUES (%s, %s, %s, %s, %s)
    """, (
        employee_name,
        phone,
        role,
        salary,
        hire_date
    ))

    db.commit()

    cursor.close()
    db.close()

    return redirect(url_for("employees"))


@app.route("/delete_employee/<int:employee_id>", methods=["POST"])
def delete_employee(employee_id):

    db = get_db_connection()
    cursor = db.cursor()

    cursor.execute("""
        DELETE FROM Employee
        WHERE employee_id = %s
    """, (employee_id,))

    db.commit()

    cursor.close()
    db.close()

    return redirect(url_for("employees"))


# ============================================================
# SUPPLIERS
# ============================================================

@app.route("/suppliers")
def suppliers():

    db = get_db_connection()
    cursor = db.cursor(dictionary=True)

    cursor.execute("""
        SELECT *
        FROM Supplier
        ORDER BY supplier_id
    """)

    supplier_list = cursor.fetchall()

    cursor.close()
    db.close()

    return render_template(
        "suppliers.html",
        suppliers=supplier_list
    )


@app.route("/add_supplier", methods=["POST"])
def add_supplier():

    supplier_name = request.form["supplier_name"]
    phone = request.form["phone"]
    email = request.form["email"]
    address = request.form["address"]

    db = get_db_connection()
    cursor = db.cursor()

    cursor.execute("""
        INSERT INTO Supplier
        (
            supplier_name,
            phone,
            email,
            address
        )
        VALUES (%s, %s, %s, %s)
    """, (
        supplier_name,
        phone,
        email,
        address
    ))

    db.commit()

    cursor.close()
    db.close()

    return redirect(url_for("suppliers"))


@app.route("/delete_supplier/<int:supplier_id>", methods=["POST"])
def delete_supplier(supplier_id):

    db = get_db_connection()
    cursor = db.cursor()

    cursor.execute("""
        DELETE FROM Supplier
        WHERE supplier_id = %s
    """, (supplier_id,))

    db.commit()

    cursor.close()
    db.close()

    return redirect(url_for("suppliers"))


# ============================================================
# INGREDIENTS
# ============================================================

@app.route("/ingredients")
def ingredients():

    db = get_db_connection()
    cursor = db.cursor(dictionary=True)

    cursor.execute("""
        SELECT
            i.ingredient_id,
            i.ingredient_name,
            i.quantity_available,
            i.unit,
            i.supplier_id,
            s.supplier_name
        FROM Ingredient i
        LEFT JOIN Supplier s
            ON i.supplier_id = s.supplier_id
        ORDER BY i.ingredient_id
    """)

    ingredient_list = cursor.fetchall()

    cursor.execute("""
        SELECT *
        FROM Supplier
        ORDER BY supplier_name
    """)

    supplier_list = cursor.fetchall()

    cursor.close()
    db.close()

    return render_template(
        "ingredients.html",
        ingredients=ingredient_list,
        suppliers=supplier_list
    )


@app.route("/add_ingredient", methods=["POST"])
def add_ingredient():

    ingredient_name = request.form["ingredient_name"]
    quantity_available = request.form["quantity_available"]
    unit = request.form["unit"]
    supplier_id = request.form["supplier_id"]

    db = get_db_connection()
    cursor = db.cursor()

    cursor.execute("""
        INSERT INTO Ingredient
        (
            ingredient_name,
            quantity_available,
            unit,
            supplier_id
        )
        VALUES (%s, %s, %s, %s)
    """, (
        ingredient_name,
        quantity_available,
        unit,
        supplier_id
    ))

    db.commit()

    cursor.close()
    db.close()

    return redirect(url_for("ingredients"))


@app.route("/delete_ingredient/<int:ingredient_id>", methods=["POST"])
def delete_ingredient(ingredient_id):

    db = get_db_connection()
    cursor = db.cursor()

    cursor.execute("""
        DELETE FROM Ingredient
        WHERE ingredient_id = %s
    """, (ingredient_id,))

    db.commit()

    cursor.close()
    db.close()

    return redirect(url_for("ingredients"))


# ============================================================
# ORDERS
# ============================================================

@app.route("/orders")
def orders():

    db = get_db_connection()
    cursor = db.cursor(dictionary=True)

    # Get all orders
    # Cancelled orders remain visible for order history
    cursor.execute("""
        SELECT
            o.order_id,
            o.customer_id,
            c.name AS customer_name,
            o.order_date,
            o.total_amount,
            o.order_status
        FROM Orders o
        JOIN Customer c
            ON o.customer_id = c.customer_id
        ORDER BY o.order_id DESC
    """)

    order_list = cursor.fetchall()

    # Customers for Add Order form
    cursor.execute("""
        SELECT *
        FROM Customer
        ORDER BY name
    """)

    customer_list = cursor.fetchall()

    # Products for Add Order form
    cursor.execute("""
        SELECT *
        FROM Product
        ORDER BY product_name
    """)

    product_list = cursor.fetchall()

    cursor.close()
    db.close()

    return render_template(
        "orders.html",
        orders=order_list,
        customers=customer_list,
        products=product_list
    )


# ============================================================
# ADD ORDER
# ============================================================

@app.route("/add_order", methods=["POST"])
def add_order():

    customer_id = request.form["customer_id"]
    product_id = request.form["product_id"]
    quantity = int(request.form["quantity"])

    db = get_db_connection()
    cursor = db.cursor(dictionary=True)

    try:

        # ----------------------------------------------------
        # Get product price and current stock
        # ----------------------------------------------------

        cursor.execute("""
            SELECT
                product_name,
                price,
                stock_quantity
            FROM Product
            WHERE product_id = %s
        """, (product_id,))

        product = cursor.fetchone()

        if product is None:

            db.rollback()
            cursor.close()
            db.close()

            return "Product not found", 404

        # ----------------------------------------------------
        # Validate quantity
        # ----------------------------------------------------

        if quantity <= 0:

            db.rollback()
            cursor.close()
            db.close()

            return "Quantity must be greater than 0", 400

        # ----------------------------------------------------
        # Check stock
        # ----------------------------------------------------

        if quantity > product["stock_quantity"]:

            db.rollback()
            cursor.close()
            db.close()

            return (
                f"Not enough stock available for "
                f"{product['product_name']}. "
                f"Available: {product['stock_quantity']}"
            ), 400

        # ----------------------------------------------------
        # Calculate total
        # ----------------------------------------------------

        total_amount = product["price"] * quantity

        # ----------------------------------------------------
        # Create order
        # ----------------------------------------------------

        cursor.execute("""
            INSERT INTO Orders
            (
                customer_id,
                total_amount,
                order_status
            )
            VALUES (%s, %s, 'Pending')
        """, (
            customer_id,
            total_amount
        ))

        order_id = cursor.lastrowid

        # ----------------------------------------------------
        # Create order item
        # ----------------------------------------------------

        cursor.execute("""
            INSERT INTO Order_Item
            (
                order_id,
                product_id,
                quantity,
                price
            )
            VALUES (%s, %s, %s, %s)
        """, (
            order_id,
            product_id,
            quantity,
            product["price"]
        ))

        # ----------------------------------------------------
        # Reduce stock
        # ----------------------------------------------------

        cursor.execute("""
            UPDATE Product
            SET stock_quantity = stock_quantity - %s
            WHERE product_id = %s
        """, (
            quantity,
            product_id
        ))

        db.commit()

    except Exception as e:

        db.rollback()

        cursor.close()
        db.close()

        return f"Error creating order: {e}", 500

    cursor.close()
    db.close()

    return redirect(url_for("orders"))


# ============================================================
# UPDATE ORDER STATUS
# ============================================================

@app.route("/update_order_status/<int:order_id>", methods=["POST"])
def update_order_status(order_id):

    new_status = request.form["order_status"]

    db = get_db_connection()
    cursor = db.cursor(dictionary=True)

    try:

        # ----------------------------------------------------
        # Get current order status
        # ----------------------------------------------------

        cursor.execute("""
            SELECT
                order_status
            FROM Orders
            WHERE order_id = %s
        """, (order_id,))

        order = cursor.fetchone()

        if order is None:

            db.rollback()
            cursor.close()
            db.close()

            return "Order not found", 404

        old_status = order["order_status"]

        # ----------------------------------------------------
        # If nothing changed, don't change stock
        # ----------------------------------------------------

        if old_status == new_status:

            db.commit()

            cursor.close()
            db.close()

            return redirect(url_for("orders"))

        # ====================================================
        # PENDING / CONFIRMED / COMPLETED
        #                ↓
        #             CANCELLED
        #
        # Restore stock
        # ====================================================

        if new_status == "Cancelled" and old_status != "Cancelled":

            cursor.execute("""
                SELECT
                    product_id,
                    quantity
                FROM Order_Item
                WHERE order_id = %s
            """, (order_id,))

            items = cursor.fetchall()

            for item in items:

                cursor.execute("""
                    UPDATE Product
                    SET stock_quantity =
                        stock_quantity + %s
                    WHERE product_id = %s
                """, (
                    item["quantity"],
                    item["product_id"]
                ))

        # ====================================================
        # CANCELLED
        #       ↓
        # PENDING / CONFIRMED / COMPLETED
        #
        # Reduce stock again
        # ====================================================

        elif old_status == "Cancelled" and new_status != "Cancelled":

            cursor.execute("""
                SELECT
                    oi.product_id,
                    oi.quantity,
                    p.stock_quantity,
                    p.product_name
                FROM Order_Item oi
                JOIN Product p
                    ON oi.product_id = p.product_id
                WHERE oi.order_id = %s
            """, (order_id,))

            items = cursor.fetchall()

            # ------------------------------------------------
            # Check ALL stock first
            # ------------------------------------------------

            for item in items:

                if item["quantity"] > item["stock_quantity"]:

                    db.rollback()

                    cursor.close()
                    db.close()

                    return (
                        f"Not enough stock available for "
                        f"{item['product_name']}. "
                        f"Available: {item['stock_quantity']}. "
                        f"Required: {item['quantity']}."
                    ), 400

            # ------------------------------------------------
            # Reduce stock
            # ------------------------------------------------

            for item in items:

                cursor.execute("""
                    UPDATE Product
                    SET stock_quantity =
                        stock_quantity - %s
                    WHERE product_id = %s
                """, (
                    item["quantity"],
                    item["product_id"]
                ))

        # ====================================================
        # Update order status
        # ====================================================

        cursor.execute("""
            UPDATE Orders
            SET order_status = %s
            WHERE order_id = %s
        """, (
            new_status,
            order_id
        ))

        db.commit()

    except Exception as e:

        db.rollback()

        cursor.close()
        db.close()

        return f"Error updating order: {e}", 500

    cursor.close()
    db.close()

    return redirect(url_for("orders"))


# ============================================================
# PAYMENTS
# ============================================================

@app.route("/payments")
def payments():

    db = get_db_connection()
    cursor = db.cursor(dictionary=True)

    # Payment history
    cursor.execute("""
        SELECT
            p.payment_id,
            p.order_id,
            p.payment_date,
            p.payment_method,
            p.payment_status,
            p.amount,
            c.name AS customer_name
        FROM Payment p
        JOIN Orders o
            ON p.order_id = o.order_id
        JOIN Customer c
            ON o.customer_id = c.customer_id
        ORDER BY p.payment_id DESC
    """)

    payment_list = cursor.fetchall()

    # Orders available for payment
    cursor.execute("""
        SELECT
            o.order_id,
            c.name AS customer_name,
            o.total_amount
        FROM Orders o
        JOIN Customer c
            ON o.customer_id = c.customer_id
        WHERE o.order_status != 'Cancelled'
        ORDER BY o.order_id DESC
    """)

    order_list = cursor.fetchall()

    cursor.close()
    db.close()

    return render_template(
        "payments.html",
        payments=payment_list,
        orders=order_list
    )


@app.route("/add_payment", methods=["POST"])
def add_payment():

    order_id = request.form["order_id"]
    payment_method = request.form["payment_method"]
    payment_status = request.form["payment_status"]
    amount = request.form["amount"]

    db = get_db_connection()
    cursor = db.cursor()

    cursor.execute("""
        INSERT INTO Payment
        (
            order_id,
            payment_method,
            payment_status,
            amount
        )
        VALUES (%s, %s, %s, %s)
    """, (
        order_id,
        payment_method,
        payment_status,
        amount
    ))

    db.commit()

    cursor.close()
    db.close()

    return redirect(url_for("payments"))


# ============================================================
# RUN APPLICATION
# ============================================================

if __name__ == "__main__":
    app.run(debug=True)