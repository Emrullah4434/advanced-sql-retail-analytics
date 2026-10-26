-- SQLite-compatible retail analytics schema
PRAGMA foreign_keys=ON;
CREATE TABLE customers (customer_id INTEGER PRIMARY KEY, city TEXT NOT NULL, segment TEXT NOT NULL);
CREATE TABLE products (product_id INTEGER PRIMARY KEY, category TEXT NOT NULL, unit_price REAL NOT NULL CHECK(unit_price>=0));
CREATE TABLE orders (order_id INTEGER PRIMARY KEY, customer_id INTEGER NOT NULL REFERENCES customers(customer_id), order_date TEXT NOT NULL, status TEXT NOT NULL CHECK(status IN ('Completed','Returned','Cancelled')));
CREATE TABLE order_items (item_id INTEGER PRIMARY KEY, order_id INTEGER NOT NULL REFERENCES orders(order_id), product_id INTEGER NOT NULL REFERENCES products(product_id), quantity INTEGER NOT NULL CHECK(quantity>0), discount_rate REAL NOT NULL CHECK(discount_rate BETWEEN 0 AND 1));
CREATE INDEX idx_orders_date_status ON orders(order_date,status);
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_items_order ON order_items(order_id);
CREATE INDEX idx_items_product ON order_items(product_id);
