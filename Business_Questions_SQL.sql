---1. What does male vs female customers generate in total revenue?
SELECT 
	gender,
	SUM(purchase_amount) AS revenue
From customer
GROUP BY gender

---2. Which customers used a discount but still spent more than the average purchase amount?
SELECT 
	customer_id,
	purchase_amount
FROM customer
WHERE discount_applied = 'Yes' 
AND purchase_amount > (SELECT AVG(purchase_amount) FROM customer)

---3. Which are the top 5 products with the highest average review rating?
SELECT TOP 5 
    item_purchased,
    CAST(AVG(CAST(review_rating AS DECIMAL(10,2))) AS DECIMAL(10,2)) AS [Average Product Rating]
FROM customer
GROUP BY item_purchased
ORDER BY AVG(CAST(review_rating AS DECIMAL(10,2))) DESC;

---4. Compare the average purchase Amount between standard express shipping.
SELECT 
	shipping_type,
	ROUND(AVG(purchase_amount),2) as 'Average Purchase Amount'
FROM customer
WHERE shipping_type in ('Standard', 'Express')
GROUP BY shipping_type
 
---5. Do subscribed customers spend more? Compare the average spend and total revenue between subscribers and non-subscribers.
SELECT 
    subscription_status,
    COUNT(customer_id) AS total_customers,
    FORMAT(AVG(CAST(purchase_amount AS DECIMAL(10,2))), 'N2') AS avg_spend,
    FORMAT(SUM(CAST(purchase_amount AS DECIMAL(10,2))), 'N2') AS total_revenue
FROM customer
GROUP BY subscription_status
ORDER BY SUM(purchase_amount) DESC;

---6. Which 5 products have the highest percentage of purchases with a discount applied?
SELECT TOP 5
	 item_purchased,
	 CAST
		(ROUND
			(100 * SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END)
			/ COUNT(*),2)
	 AS DECIMAL(10,2)) AS discount_rate
FROM customer
GROUP BY item_purchased
ORDER BY discount_rate DESC;

---7. Segment customers into New, Returning, and Loyal based on their total number of previous purchases, and show the count of each segment.
WITH customer_type AS(
SELECT 
	customer_id,
	previous_purchases,
CASE 
	WHEN previous_purchases = 1 THEN 'New'
	WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
	ELSE 'Loyal'
	END AS customer_segment
FROM customer
)

SELECT 
	customer_segment,
	COUNT(*) AS "Number of Customers"
FROM customer_type
GROUP BY customer_segment;

---8. What are the 3 top-purchased products within each category?

WITH item_counts AS (
    SELECT 
        category,
        item_purchased,
        COUNT(customer_id) AS total_orders,
        ROW_NUMBER() OVER (
            PARTITION BY category 
            ORDER BY COUNT(customer_id) DESC
        ) AS item_rank
    FROM customer
    GROUP BY category, item_purchased
)
SELECT 
	item_rank,
	category,
	item_purchased,
	total_orders
FROM item_counts
WHERE item_rank <= 3;

---9. Are customers who are repeat buyers (more than 5 previous purchases) also likely to subscribe?
SELECT
	subscription_status,
	COUNT(customer_id) AS repeat_buyers
FROM customer 
WHERE previous_purchases > 5
GROUP BY subscription_status

---10. What is the revenue contribution of each age group?
SELECT
	age_group,
	SUM(purchase_amount) AS total_revenue
FROM customer
GROUP BY age_group
ORDER BY total_revenue DESC
