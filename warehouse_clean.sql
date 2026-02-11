--  Create new table for backup
-- Create backup table
CREATE TABLE warehouse_backup
LIKE warehouse_messy_data;

-- Copy table values from the original table into backup 
INSERT INTO warehouse_backup
SELECT *
FROM warehouse_messy_data;

SELECT*
FROM warehouse_messy_data;

-- Change Column Name
ALTER TABLE warehouse_backup
RENAME COLUMN `Product ID` TO product_id;

ALTER TABLE warehouse_backup
RENAME COLUMN `Product Name` TO `product_name`;

ALTER TABLE warehouse_backup
RENAME COLUMN Warehouse TO warehouse;

ALTER TABLE warehouse_backup
RENAME COLUMN Location TO location;

ALTER TABLE warehouse_backup
RENAME COLUMN Quantity TO quantity;

ALTER TABLE warehouse_backup
RENAME COLUMN Price TO price;

ALTER TABLE warehouse_backup
RENAME COLUMN Supplier TO supplier;

ALTER TABLE warehouse_backup
RENAME COLUMN `Status` TO `current_status`;

ALTER TABLE warehouse_backup
RENAME COLUMN `Last Restocked` TO last_restocked;

ALTER TABLE warehouse_backup
RENAME COLUMN Category TO category;


-- Check Duplicate
WITH cte_duplicate AS (
SELECT *,ROW_NUMBER()OVER(PARTITION BY product_id, product_name)
AS row_num
FROM warehouse_backup
)
SELECT*
FROM cte_duplicate
WHERE row_num>1;

-- Create new table with added row_num
CREATE TABLE `warehouse_backup2` (
  `product_id` int DEFAULT NULL,
  `product_name` text,
  `category` text,
  `warehouse` text,
  `location` text,
  `quantity` text,
  `price` double DEFAULT NULL,
  `supplier` text,
  `current_status` text,
  `last_restocked` text,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Copy & paste every value from backup table to the newly created table  
INSERT INTO warehouse_backup2
SELECT* , ROW_NUMBER()OVER(PARTITION BY product_id, product_name)
FROM warehouse_backup;

-- Check table
SELECT* 
FROM warehouse_backup2
ORDER BY product_id;

-- Delete Duplicates 
DELETE FROM warehouse_backup2
WHERE row_num>1;



-- Standardize data

-- Check unique values 
SELECT DISTINCT(product_name)
FROM warehouse_backup2;

-- Remove empty spaces
UPDATE warehouse_backup2
SET product_name = TRIM(product_name);

-- Search for specific value in a column
SELECT product_id, product_name
FROM warehouse_backup2
WHERE product_name LIKE 'g% x';

-- Fix spelling error
UPDATE warehouse_backup2
SET product_name = 'Gadget X'
WHERE product_name LIKE 'g% x';

-- Fix spelling error
UPDATE warehouse_backup2
SET product_name = 'Gadget Y'
WHERE product_name LIKE 'g% y';

-- Fix spelling error
UPDATE warehouse_backup2
SET product_name = 'Gadget Z'
WHERE product_name LIKE 'g% z';

-- Fix spelling error
UPDATE warehouse_backup2
SET product_name = 'Widget A'
WHERE product_name LIKE 'w% a';

-- Fix spelling error
UPDATE warehouse_backup2
SET product_name = 'Widget B'
WHERE product_name LIKE 'w% b';

-- Fix spelling error
UPDATE warehouse_backup2
SET product_name = 'Widget C'
WHERE product_name LIKE 'w% c';

-- Check the result after changes have been made
SELECT DISTINCT(product_name)
FROM warehouse_backup2;

-- Apply the same procedure for the category column 
SELECT DISTINCT(category)
FROM warehouse_backup2;
UPDATE warehouse_backup2
SET category = 'Electronics'
WHERE category LIKE 'e%';
UPDATE warehouse_backup2
SET category = 'Clothing'
WHERE category LIKE 'c%';
UPDATE warehouse_backup2
SET category = 'Furniture'
WHERE category LIKE 'f%';
UPDATE warehouse_backup2
SET category = 'Toys'
WHERE category LIKE 't%';
-- Check the current table
SELECT *
FROM warehouse_backup2;

-- Table with name, id, quantity, and a case statement
-- Case statement - changing table values
-- test the case statement in a select statement to ensure no logical errors before updating
SELECT product_name, product_id,quantity,
CASE quantity
	WHEN 'two hundred' THEN 200
    WHEN 'NaN' THEN NULL
    ELSE quantity
END AS quantity_constraint
FROM warehouse_backup2;

-- Update table with the Case statement
UPDATE warehouse_backup2
SET quantity = CASE quantity
	WHEN 'two hundred' THEN 200
    WHEN 'NaN' THEN NULL
    ELSE quantity 
END;

-- Change quantity datatype
ALTER TABLE warehouse_backup2
MODIFY quantity INT UNSIGNED;

-- Looking for NaN before setting them as NULL value
SELECT last_restocked
FROM warehouse_backup2
WHERE last_restocked LIKE 'NaN';

UPDATE warehouse_backup2
SET last_restocked = NULL
WHERE last_restocked LIKE 'NaN';

SELECT last_restocked
FROM warehouse_backup2
WHERE last_restocked IS NULL;

-- Test STR_TO_DATE command
SELECT *, STR_TO_DATE(last_restocked,'%d/%m/%Y') AS date_parsed, DATE_FORMAT(STR_TO_DATE(last_restocked,'%d/%m/%Y'),'%d/%m/%Y')
FROM warehouse_backup2;

-- Changing Date Format
UPDATE warehouse_backup2
SET last_restocked =  STR_TO_DATE(last_restocked, '%d/%m/%Y');

-- Changing columnn date datatype 
ALTER TABLE warehouse_backup2
MODIFY last_restocked DATE;

-- Check current state
SELECT *
FROM warehouse_backup2;

-- Check columns data type
DESCRIBE warehouse_backup2; 

-- Delete column row_num
ALTER TABLE warehouse_backup2
DROP COLUMN row_num;