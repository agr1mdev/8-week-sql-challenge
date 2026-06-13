SELECT * FROM dannys_diner.sales;
SELECT * FROM dannys_diner.members;
SELECT * FROM dannys_diner.menu;



-- Q1. What is the total amount each customer spent at the restaurant?

-- Approach 1: Optimized Direct Join (Recommended)
-- Why: Eliminates unnecessary nested subquery overhead for direct aggregations.
SELECT 
	ds.customer_id,
	SUM(dm.price) [TotalSpent]
FROM dannys_diner.sales ds
LEFT JOIN dannys_diner.menu dm
ON ds.product_id = dm.product_id
GROUP BY customer_id

-- Approach 2: Inline View / Subquery Method
-- Note: Valid logic but introduces an extra intermediate processing layer (T).
SELECT 
	customer_id,
	SUM(price) [amountspent]
FROM
(SELECT 
	ds.customer_id,
	ds.product_id,
	dm.product_name,
	dm.price
FROM dannys_diner.sales ds
LEFT JOIN dannys_diner.menu dm
ON ds.product_id = dm.product_id)T
GROUP BY customer_id


-- Q2. How many days has each customer visited the restaurant?

SELECT
	*
FROM dannys_diner.sales;

SELECT
	customer_id,
	COUNT(DISTINCT order_date) [daysvisited]
FROM dannys_diner.sales
GROUP BY customer_id;


-- Q3.What was the first item from the menu purchased by each customer?

SELECT * FROM dannys_diner.sales;
SELECT * FROM dannys_diner.menu;

-- Solution : Nested Subquery Method
-- Business Constraint Note: Because there are no timestamps on order transactions, 
-- multiple items purchased on day one will tie for rank 1. DENSE_RANK() is used to capture both.
SELECT 
	*
FROM
	(SELECT
		customer_id,
		product_name,
		DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date ASC) [firstitem]
	 FROM dannys_diner.sales ds
		LEFT JOIN dannys_diner.menu dm
		ON ds.product_id = dm.product_id)t
WHERE firstitem = 1
;


-- Q4. What is the most purchased item on the menu and how many times was it purchased by all customers?

-- Step 1: Previewing sales and menu dimensions to align aggregation keys
SELECT * FROM dannys_diner.sales;
SELECT * FROM dannys_diner.menu;

-- Step 2: Final Solution (Common Table Expression Method)
WITH cte_noofpurchase AS(
	SELECT
		product_id,
		COUNT(product_id) AS [NoOfPurchases]
	FROM dannys_diner.sales
	GROUP BY product_id
)
SELECT
	ctp.product_id,
	ddm.product_name,
	ctp.NoOfPurchases
FROM cte_noofpurchase ctp
LEFT JOIN dannys_diner.menu ddm
	ON ctp.product_id = ddm.product_id
ORDER BY NoOfPurchases DESC;

-- Question 5: Which item was the most popular for each customer?

SELECT * FROM dannys_diner.sales;
SELECT * FROM dannys_diner.menu;

-- (Multi-Layer Nested Subquery Method)
SELECT 
    t2.customer_id,
    dm.product_name,
    t2.nooforders
FROM (
	SELECT
		customer_id,
		product_id,
		nooforders,
		DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY nooforders DESC) [highestorder]
	FROM (
		SELECT
			customer_id,
			product_id,
			COUNT(*) [nooforders]
		FROM dannys_diner.sales
		GROUP BY customer_id, product_id

	)t1
)t2
LEFT JOIN dannys_diner.menu dm 
    ON t2.product_id = dm.product_id
WHERE t2.highestorder = 1;

-- Question 6: Which item was purchased first by the customer after they became a member?

-- Initial Exploratory Data Analysis (EDA)
SELECT * FROM dannys_diner.sales;
SELECT * FROM dannys_diner.members;

-- Final Solution (Linear CTE Pipeline)
WITH cte_member_transaction AS(
	
	SELECT
		dds.customer_id,
		dds.order_date,
		dds.product_id
	FROM dannys_diner.sales dds
	INNER JOIN dannys_diner.members ddm
		ON dds.customer_id = ddm.customer_id
	WHERE dds.order_date >= ddm.join_date
),
	
cte_chronologicalrank AS(
	SELECT
		customer_id,
		order_date,
		product_id,
		DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date ASC) AS [purchase_rank]
	FROM cte_member_transaction
)

SELECT
 ccr.customer_id,
 ccr.order_date,
 dm.product_name
FROM cte_chronologicalrank ccr
INNER JOIN dannys_diner.menu dm
	ON ccr.product_id = dm.product_id
WHERE purchase_rank = 1
ORDER BY ccr.customer_id;


-- Q7: Which item was purchased just before the customer became a member?

-- Initial Exploratory Data Analysis (EDA)
SELECT * FROM dannys_diner.members;
SELECT * FROM dannys_diner.sales;

-- Final Solution (Linear CTE Pipeline)
WITH cte_membertransaction AS (
    SELECT
        dds.customer_id,
        dds.order_date,
        dds.product_id
    FROM dannys_diner.sales dds
    INNER JOIN dannys_diner.members ddm
        ON dds.customer_id = ddm.customer_id
    WHERE dds.order_date < ddm.join_date
),

cte_chronologicalrank AS (
    SELECT
        customer_id,
        order_date,
        product_id,
        --  ORDER BY DESC moves the absolute latest pre-membership purchase to rank 1
        DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date DESC) [orderrank]
    FROM cte_membertransaction
)
SELECT
    ccr.customer_id,
    ccr.order_date,
    dm.product_name
FROM cte_chronologicalrank ccr
INNER JOIN dannys_diner.menu dm
    ON ccr.product_id = dm.product_id
WHERE orderrank = 1
ORDER BY customer_id ASC;


-- Question 8: What is the total items and amount spent for each member before they became a member?


SELECT * FROM dannys_diner.members;
SELECT * FROM dannys_diner.sales;

WITH cte_pre_membertransactions AS(
	
	SELECT
		dds.customer_id,
		dds.product_id
	FROM dannys_diner.sales dds
	INNER JOIN dannys_diner.members ddm
		ON dds.customer_id = ddm.customer_id
	WHERE dds.order_date < ddm.join_date
)
SELECT
	pmt.customer_id,
	COUNT(pmt.product_id) AS [totalitem],
	SUM(dm.price) AS [totalamtspent]
FROM cte_pre_membertransactions pmt
INNER JOIN dannys_diner.menu dm
	ON pmt.product_id = dm.product_id
GROUP BY pmt.customer_id
ORDER BY pmt.customer_id ASC;


-- Q9: If each $1 spent equates to 10 points and sushi has a 2x points multiplier how many points would each customer have?

-- Step 1: Initial Exploratory Data Analysis (EDA)
SELECT * FROM dannys_diner.sales;
SELECT * FROM dannys_diner.menu;

-- Step 2: Final Solution (Nested Subquery Method)
SELECT
    t.customer_id,
    SUM(t.points) AS [royaltypoints]
FROM (
    SELECT 
        dds.customer_id,
        dds.product_id,
        --  Conditional logic: Sushi (ID: 1) earns 20 points per $1 (2x), others earn 10 points per $1
        CASE 
            WHEN dds.product_id = 1 THEN ddm.price * 20
            ELSE ddm.price * 10
        END AS [points]
    FROM dannys_diner.sales dds
    LEFT JOIN dannys_diner.menu ddm
        ON dds.product_id = ddm.product_id
) t
GROUP BY t.customer_id
ORDER BY t.customer_id ASC;
