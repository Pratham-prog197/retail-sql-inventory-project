CREATE DATABASE Bigbazar;
USE Bigbazar;

CREATE TABLE Products(
product_id INT primary key,
product_name  VARCHAR(50) ,
category  VARCHAR(50),
unit_price  DECIMAL(10,2),
reorder_level INT
);
CREATE TABLE Stores(
store_id INT PRIMARY KEY,
store_name VARCHAR(50),
location VARCHAR(50)

);
CREATE TABLE Inventory (
    inventory_id INT PRIMARY KEY,
    store_id INT,
    product_id INT,
    quantity_on_hand INT,
    last_updated varchar(50),
    FOREIGN KEY (store_id) REFERENCES Stores(store_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);
CREATE TABLE Purchases (
    purchase_id INT PRIMARY KEY,
    product_id INT,
    store_id INT,
    supplier_id INT,
    purchase_date VARCHAR(50),
    quantity_purchased INT,
    total_cost DECIMAL(10,2),
    FOREIGN KEY (product_id) REFERENCES Products(product_id),
    FOREIGN KEY (store_id) REFERENCES Stores(store_id),
    FOREIGN KEY (supplier_id) REFERENCES Suppliers(supplier_id)
);
CREATE TABLE Sales (
    sale_id INT PRIMARY KEY,
    store_id INT,
    product_id INT,
    sale_date varchar(50),
   quantity_sold INT,
    total_amount DECIMAL(10,2),
    FOREIGN KEY (store_id) REFERENCES Stores(store_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);
CREATE TABLE suppliers(
supplier_id INT PRIMARY KEY,
supplier_name VARCHAR(50),
cleaned_phone  VARCHAR(50)
);


LOAD DATA LOCAL INFILE 'C:/Users/PRATHAM/OneDrive/Desktop/Data Science/New project/inventory.csv'
INTO TABLE Inventory
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

DESCRIBE bigbazar.inventory;
ALTER TABLE inventory ADD COLUMN last_updated_new DATE;
SELECT
 
  last_updated
FROM
  inventory
ORDER BY
  STR_TO_DATE(last_updated, '%d-%m-%Y') DESC;

Select --  out of stock k liye
p.product_name,
s.store_name,
i.quantity_on_hand,
p.reorder_level
from inventory as i
JOIN products p ON i.product_id=p.product_id
JOIN stores s ON i.store_id=s.store_id
WHERE i.quantity_on_hand < p.reorder_level;


-- Top 5 selling product
SELECT 
p.product_name,
SUM(s.total_amount) AS revenue
FROM Sales s
JOIN products p ON s.product_id=p.product_id
GROUP BY p.product_id
ORDER BY revenue DESC
LIMIT 5;

-- sales per stores
SELECT 
    st.store_name,
    MONTH(s.sale_date) AS month,
    SUM(s.total_amount) AS monthly_sales
FROM Sales s
JOIN Stores st ON s.store_id = st.store_id
GROUP BY st.store_id, MONTH(s.sale_date)
ORDER BY st.store_name, month ;



SET SQL_SAFE_UPDATES = 0;

UPDATE sales
SET sale_date = STR_TO_DATE(sale_date, '%d-%m-%Y');

select 
p.product_id,p.product_name
FROM products p
LEFT JOIN purchases pu ON p.product_id= pu.product_id
WHERE pu.product_id is NULL;

CREATE VIEW DailyStoreSales AS
SELECT 
    store_id,
    sale_date,
    SUM(total_amount) AS daily_revenue
FROM Sales
GROUP BY store_id, sale_date;
  
  SELECT * FROM DailyStoreSales 




DELIMITER //

CREATE PROCEDURE Reorder_Alert()
BEGIN
    SELECT 
        p.product_name,
        i.store_id,
        i.quantity_on_hand,
        p.reorder_level
    FROM Inventory i
    JOIN Products p ON i.product_id = p.product_id
    WHERE i.quantity_on_hand < p.reorder_level;
END //

DELIMITER ;

CALL Reorder_Alert();

DELIMETER;


DELIMITER //

CREATE TRIGGER update_last_updated
BEFORE UPDATE ON Inventory
FOR EACH ROW
BEGIN
    SET NEW.last_updated = CURDATE();
END //

DELIMITER ;
