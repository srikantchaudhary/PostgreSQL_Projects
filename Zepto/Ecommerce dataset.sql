


create table zepto(
sku_id SERIAL PRIMARY KEY,
category VARCHAR(120),
name VARCHAR(150) NOT NULL,
mrp NUMERIC(8,2),
discountPercent NUMERIC(5,2),
availableQuantity INTEGER,
discountedSellingPrice NUMERIC(8,2),
weightInGms INTEGER,
outOfStock BOOLEAN,
quantity INTEGER
)


-------  Data exploration



--  count of rows

select count(*) from zepto;


--  sample data

select * from zepto limit 10;



-- null values

select * from zepto
where category is null
or
name is null
or mrp is null
or discountPercent is null
or availableQuantity is null
or discountedSellingPrice is null
or weightInGms is null
or outOfStock is null 
or quantity is null;



--- different product categories

select distinct category from zepto
order by category;



-- products in stock vs out of stock

select outOfStock, count(*) from zepto group by outOfStock;


--  product names present multiple times

select name , count(*) from zepto 
group by name 
having count(*) > 1 
order by count(*) desc;




-- Data Cleaning Tasks

-- 1. Identify and remove products with MRP = 0 or discounted price = 0.

select count(*) from zepto where mrp != 0 or discountedsellingprice != 0;

-- Remove
DELETE FROM zepto
WHERE mrp = 0 OR discountedsellingprice = 0;


-- 2. Convert prices from paise to rupees.

update zepto set mrp = mrp/100.00 , discountedSellingPrice = discountedSellingPrice/100.00;


select * from zepto;


-- 3. Ensure duplicate products are handled correctly.

SELECT name, category, COUNT(*) AS duplicate_count
FROM zepto
GROUP BY name, category
HAVING COUNT(*) > 1;



-----------------  Questions  --------------------------

-- 1. Find the top 10 best-value products based on the discount percentage.

Select distinct name, mrp, discountPercent from zepto order by discountpercent desc limit 10;

-- 2. What are the Products with High MRP but Out of Stock.

select distinct name, category, mrp, outofstock from zepto 
where outofstock = true 
order by mrp desc limit 5;

-- 3. Calculate Estimated Revenue for each Cateory.

select category, sum(mrp) from zepto group by category;

-- 4. Find all products where MRP is greater than 500 and discount is less than 10%.
-- 5. Identify the top 5 categories offering the highest average discount percentage.
-- 6. Find the price per gram for products above 100g and sort by best value.
-- 7. Group the products into categories like LOW, Medium , Bulk.
-- 8. What is the Total Inventory Weight Per Category.








