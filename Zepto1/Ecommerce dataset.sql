


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


