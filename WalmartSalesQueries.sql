CREATE DATABASE IF NOT EXISTS WalmartSalesData;

CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL, 
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL, 
    product_line VARCHAR(100) NOT NULL, 
    unit_price DECIMAL(10,2) NOT NULL, 
    quantity INT NOT NULL,
    VAT FLOAT(6, 4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL, 
    date DATETIME NOT NULL, 
    time TIME NOT NULL,
    payment_method VARCHAR(15) NOT NULL, 
    cogs DECIMAL(10, 2) NOT NULL, 
    gross_margin_percentage FLOAT(11, 9),
    gross_income DECIMAL(12, 4) NOT NULL, 
    rating FLOAT(2, 1)
);
    ##Creating the dataset with Not Null to keep it clean before I work on it
    
    #####################Feature Engineering################################
    
    ##Finding the time of day for purchases

SELECT
	time,
    (CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END
    ) AS time_of_day
FROM sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

##Updating the dataset with a new 'time_of_day' column

UPDATE sales
SET time_of_day = (
	CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END
);

##Finding the day of the week for purchases and creating a column for it

SELECT
	date,
    DAYNAME(date) AS day_name
FROM sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

UPDATE sales
SET day_name = DAYNAME(date);

##Finding the month for purchases and creating a column for it

SELECT
	date,
    MONTHNAME(date) AS month_name
FROM sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);

UPDATE sales
SET month_name = MONTHNAME(date);


############################### Exploratory Data Analysis ######################################


## Each unique city with a walmart

SELECT
	DISTINCT city
FROM sales;

## Branch in each city

SELECT
	DISTINCT branch
FROM sales;

SELECT
	DISTINCT city, 
    branch
FROM sales;


######################################## Product Questions ##########################################


## How many unique product lines do these Walmart branches have?

SELECT
	COUNT(DISTINCT product_line)
FROM sales;

## Most common payment method

SELECT
	payment_method,
	COUNT(payment_method) AS cnt
FROM sales
GROUP BY payment_method
ORDER BY cnt DESC;

## Highest selling product line

SELECT
	product_line,
    COUNT(product_line) AS cnt
FROM sales
GROUP BY product_line
ORDER BY cnt DESC;

## Total revenue by month

SELECT
	month_name AS month,
    SUM(total) AS total_revenue
FROM sales
GROUP BY month_name
ORDER BY total_revenue DESC;

## Month with highest Cost Of Goods Sold

SELECT
	month_name AS month,
    SUM(cogs) AS cogs
FROM sales
GROUP BY month_name
ORDER BY cogs DESC;

## Product line with the largest revenue

SELECT
	product_line,
    SUM(total) AS total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC;

## City with the largest revenue

SELECT
	branch,
	city,
    SUM(total) AS total_revenue
FROM sales
GROUP BY city, branch
ORDER BY total_revenue DESC;

## Product line with the largest Value Added Tax

SELECT
	product_line,
    AVG(VAT) AS avg_tax
FROM sales
GROUP BY product_line
ORDER BY avg_tax DESC;

## Showing if sales are better or worse than the average by product line

SELECT
	product_line,
    ROUND(AVG(total), 2) AS avg_sales,
    (CASE
		WHEN AVG(total) > (SELECT AVG(total) FROM sales) THEN "Better"
        ELSE "Worse"
        END
	) AS remarks
FROM sales
GROUP BY product_line
ORDER BY avg_sales DESC;

## Branch that sold more products than the average

SELECT
	branch,
    SUM(quantity) AS qty
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales)
ORDER BY qty DESC;

## Most common product lines by gender

SELECT
	gender,
    product_line,
    COUNT(gender) AS total_cnt
FROM sales
GROUP BY gender, product_line
ORDER BY total_cnt DESC;

## Average rating of each product line

SELECT
	ROUND(AVG(rating), 2) AS avg_rating,
    product_line
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;


####################################### Sales Analysis #################################################

## Number of sales made in each time of the day per weekday

SELECT
	time_of_day,
    COUNT(*) AS total_sales
FROM sales
WHERE day_name = "Monday"    ##Change to whatever day you want to see
GROUP BY time_of_day
ORDER BY total_sales DESC;

## Most revenue per customer type, Member or Normal

SELECT
	customer_type,
    SUM(total) AS total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue DESC;

## City with the largest average Value Added Tax

SELECT
	city,
    AVG(VAT) AS avg_VAT
FROM sales
GROUP BY city
ORDER BY avg_VAT DESC;

## Customer type that pays the most in Value Added Tax

SELECT
	customer_type,
    AVG(VAT) AS avg_VAT
FROM sales
GROUP BY customer_type
ORDER BY avg_VAT DESC;


########################################## Customer Information ###############################################

## Unque customer types

SELECT
	DISTINCT customer_type
FROM sales;

## Unque payment methods

SELECT
	DISTINCT payment_method
FROM sales;

## Most common customer type

SELECT
	customer_type,
    COUNT(customer_type) AS total_customer_type
FROM sales
GROUP BY customer_type
ORDER BY total_customer_type DESC;

## Customer type that spends more

SELECT
	customer_type,
    SUM(total) AS total_bought
FROM sales
GROUP BY customer_type
ORDER BY total_bought DESC;

## Most common customer gender

SELECT
	gender,
    COUNT(*) AS gender_cnt
FROM sales
GROUP BY gender
ORDER BY gender_cnt DESC;

## Gender distribution per branch

SELECT
	gender,
    COUNT(*) AS gender_cnt
FROM sales
WHERE branch = "A"     ## Change to whatever branch you want to see
GROUP BY gender
ORDER BY gender_cnt DESC;

## Time of day that most ratings are given per branch

SELECT
	time_of_day,
    branch,
    COUNT(rating) AS cnt_ratings
FROM sales
GROUP BY branch, time_of_day
ORDER BY cnt_ratings DESC LIMIT 3;

## Day of the week with the best average ratings

SELECT
	day_name,
    ROUND(AVG(rating), 2) AS avg_rating
FROM sales
GROUP BY day_name
ORDER BY avg_rating DESC;

## Day of the week with the best average ratings per branch

SELECT
	day_name,
    branch,
    ROUND(AVG(rating), 2) AS avg_rating
FROM sales
GROUP BY day_name, branch
ORDER BY avg_rating DESC LIMIT 3;



