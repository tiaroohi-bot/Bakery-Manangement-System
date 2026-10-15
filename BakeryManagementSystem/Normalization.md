# Bakery Management System
# Database Normalization

## 1. Unnormalized Form (UNF)

A poorly designed bakery order table could contain repeating product information:

| order_id | customer_name | product1 | quantity1 | product2 | quantity2 |
|----------|---------------|----------|-----------|----------|-----------|
| 101 | Aarav Sharma | Chocolate Cake | 1 | Brownie | 2 |

This design contains repeating groups of product and quantity information.

Therefore, it is not in First Normal Form.

---

# 2. First Normal Form (1NF)

A relation is in 1NF when:

1. Every attribute contains atomic values.
2. There are no repeating groups.
3. Each row represents a single record.

The Bakery Management System achieves 1NF by separating order products into the Order_Item table.

## Orders

| order_id | customer_id | order_date | total_amount | order_status |
|----------|-------------|------------|--------------|--------------|

## Order_Item

| order_item_id | order_id | product_id | quantity | price |
|---------------|----------|------------|----------|-------|

Each Order_Item row represents one product within an order.

Therefore:

> The Bakery Management System satisfies 1NF because all attributes are atomic and repeating product groups have been removed.

---

# 3. Second Normal Form (2NF)

A relation is in 2NF when:

1. It is already in 1NF.
2. Every non-key attribute is fully dependent on the complete primary key.
3. There are no partial dependencies.

The Order_Item relationship separates order-specific information from product-specific information.

For example:

Product information belongs to Product:

```text
product_id → product_name, category_id, price, stock_quantity