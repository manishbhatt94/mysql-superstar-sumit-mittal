-- @@@@@@@ Another session (2nd one) on ROW_NUMBER() Window Function @@@@@@@

USE trendytech_joins_practice;
SHOW TABLES;

/* Tables:

1. categories
2. customers
3. departments
4. order_items
5. orders
6. products

*/

/*
This `trendytech_joins_practice` databases, its tables & data were created / seeded in INNER JOIN
session, in file "21-inner-joins/README.md".

This data is similar to the data that was previously also imported into `retail_db` database.
*/


-- ====== Find the top selling product, in each category ========
/*
- Table `order_items` has columns:
	- `order_item_order_id` - Refers to order_id PK of `orders` table.
	- `product_id` - PK of product purchased as part of current order_item.
    - `total_amount` - Total amount spent on this product (multiple quantity)
						as part of current order_item.
- Table `products` has columns:
	- `product_id`: PK of a product.
    - `product_category_id`: PK of category to which this product belongs.
    - `product_name`: Name of this product.
- Table `categories` has columns:
	- `category_id`: PK of category.
    - `category_name`: Name of this category.
*/

-- *** First Approach *****

-- First, let's see the product_id along with the total sales of those product_id's:
SELECT product_id, SUM(total_amount) AS sale_amount,
	SUM(quantity) AS qty_sold
FROM order_items GROUP BY product_id;

-- Then, let's JOIN above, with `products` table to get the essential `category_id`
-- info along with each `product_id`:
SELECT
	pis.product_id, p.product_category_id AS category_id,
	p.product_name, pis.sale_amount, pis.qty_sold
FROM products p
INNER JOIN (
	SELECT product_id, SUM(total_amount) AS sale_amount,
		SUM(quantity) AS qty_sold
	FROM order_items GROUP BY product_id
) pis ON pis.product_id = p.product_id;

-- Then we use ROW_NUMBER() on above result-set, to assign ordered number
-- to each record in the partition by category_id, according to descending
-- order of sale_amount in that category_id partition:
SELECT
	pis.product_id, p.product_category_id AS category_id,
	p.product_name, pis.sale_amount, pis.qty_sold,
    ROW_NUMBER() OVER(PARTITION BY p.product_category_id ORDER BY pis.sale_amount DESC)
		AS row_num
FROM products p
INNER JOIN (
	SELECT product_id, SUM(total_amount) AS sale_amount,
		SUM(quantity) AS qty_sold
	FROM order_items GROUP BY product_id
) pis ON pis.product_id = p.product_id;

-- Now we'll limit these results to only show the top selling product
-- against each category_id:
SELECT t.* FROM (
	SELECT
		pis.product_id, p.product_category_id AS category_id,
		p.product_name, pis.sale_amount, pis.qty_sold,
		ROW_NUMBER() OVER(PARTITION BY p.product_category_id ORDER BY pis.sale_amount DESC)
			AS row_num
	FROM products p
	INNER JOIN (
		SELECT product_id, SUM(total_amount) AS sale_amount,
			SUM(quantity) AS qty_sold
		FROM order_items GROUP BY product_id
	) pis ON pis.product_id = p.product_id
) t WHERE t.row_num = 1;

-- Clean up a little, using CTEs:
WITH product_id_sales AS (
	SELECT product_id, SUM(total_amount) AS sale_amount,
		SUM(quantity) AS qty_sold
	FROM order_items GROUP BY product_id
),
product_sales_ranked AS (
	SELECT
		pis.product_id, p.product_category_id AS category_id,
		p.product_name, pis.sale_amount, pis.qty_sold,
		ROW_NUMBER() OVER(
			PARTITION BY p.product_category_id ORDER BY pis.sale_amount DESC
		) AS row_num
	FROM products p
    INNER JOIN product_id_sales pis ON pis.product_id = p.product_id
)
SELECT psr.* FROM product_sales_ranked psr
WHERE psr.row_num = 1;

-- Now, we need to JOIN above result with `categories` table:
-- Final query:
WITH product_id_sales AS (
	SELECT product_id, SUM(total_amount) AS sale_amount,
		SUM(quantity) AS qty_sold
	FROM order_items GROUP BY product_id
),
product_sales_ranked AS (
	SELECT
		pis.product_id, p.product_category_id AS category_id,
		p.product_name, pis.sale_amount, pis.qty_sold,
		ROW_NUMBER() OVER(
			PARTITION BY p.product_category_id ORDER BY pis.sale_amount DESC
		) AS row_num
	FROM products p
    INNER JOIN product_id_sales pis ON pis.product_id = p.product_id
),
top_selling_products AS (
	SELECT psr.* FROM product_sales_ranked psr WHERE psr.row_num = 1
)
SELECT
	c.category_id, c.category_name, tsp.product_id,
	tsp.product_name, tsp.sale_amount, tsp.qty_sold
FROM categories c LEFT JOIN top_selling_products tsp
	ON c.category_id = tsp.category_id
ORDER BY tsp.sale_amount DESC;


-- *** Second Approach *****

-- First step. Build intermediate result-set product-wise total
-- sale_amount & qty_sold (along with category_id of the product):
SELECT
	p.product_category_id AS category_id, oi.product_id,
	p.product_name, SUM(oi.total_amount) AS sale_amount,
	SUM(oi.quantity) AS qty_sold
FROM order_items oi
	INNER JOIN products p ON oi.product_id = p.product_id
GROUP BY oi.product_id;

-- Now, we keep above result-set as a CTE, and then use ROW_NUMBER()
-- window func. to place ordered numbers in a new column according
-- to our criteria of higher "sale_amount" preferred per partition
-- of "category_id":
WITH products_aggregated AS (
	SELECT
		p.product_category_id AS category_id, oi.product_id,
		p.product_name, SUM(oi.total_amount) AS sale_amount,
		SUM(oi.quantity) AS qty_sold
	FROM order_items oi
		INNER JOIN products p ON oi.product_id = p.product_id
	GROUP BY oi.product_id
)
SELECT pa.*,
	ROW_NUMBER() OVER(PARTITION BY pa.category_id ORDER BY pa.sale_amount DESC)
		AS row_num
FROM products_aggregated pa;

-- Now, we will need to have only the top-selling products from each
-- category, by using above query's result-set and filtering on its
-- derived `row_num` column using "WHERE row_num = 1" filter condition:
WITH products_aggregated AS (
	SELECT
		p.product_category_id AS category_id, oi.product_id,
		p.product_name, SUM(oi.total_amount) AS sale_amount,
		SUM(oi.quantity) AS qty_sold
	FROM order_items oi
		INNER JOIN products p ON oi.product_id = p.product_id
	GROUP BY oi.product_id
),
products_ranked AS (
	SELECT pa.*,
		ROW_NUMBER() OVER(
			PARTITION BY pa.category_id ORDER BY pa.sale_amount DESC
		) AS row_num
	FROM products_aggregated pa
)
SELECT pr.* FROM products_ranked pr WHERE pr.row_num = 1;

-- Finally, to get the category_name as well, we need to join the
-- above result-set with the `categories` table:
WITH products_aggregated AS (
	SELECT
		p.product_category_id AS category_id, oi.product_id,
		p.product_name, SUM(oi.total_amount) AS sale_amount,
		SUM(oi.quantity) AS qty_sold
	FROM order_items oi
		INNER JOIN products p ON oi.product_id = p.product_id
	GROUP BY oi.product_id
),
products_ranked AS (
	SELECT pa.*,
		ROW_NUMBER() OVER(
			PARTITION BY pa.category_id ORDER BY pa.sale_amount DESC
		) AS row_num
	FROM products_aggregated pa
),
top_selling_products AS (
	SELECT pr.* FROM products_ranked pr WHERE pr.row_num = 1
)
SELECT
	c.category_id, c.category_name, tsp.product_id,
    tsp.product_name, tsp.sale_amount, tsp.qty_sold
FROM categories c LEFT OUTER JOIN top_selling_products tsp
	ON c.category_id = tsp.category_id;
-- ORDER BY tsp.sale_amount DESC;
