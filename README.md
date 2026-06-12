# 🍜 Case Study 1: Danny's Diner

## 📌 Project Overview
This repository contains my solutions to the **Danny's Diner** SQL challenge from the #8WeekSQLChallenge. The project focuses on analyzing customer capture data, sales patterns, and loyalty program performance for a small restaurant using relational databases.

## 🛠️ Technical Concepts Applied
* **Advanced Aggregations:** Utilizing `SUM`, `COUNT`, and `COUNT(DISTINCT)` to collapse transactional logs into business metrics.
* **Window Functions:** Implementing `DENSE_RANK() OVER (PARTITION BY...)` to handle chronological ties and customer purchasing behaviors.
* **Modern SQL Architecture:** Designing linearized, cascading **Common Eyepression Statements (CTEs)** to pass data forward sequentially, optimizing query execution by eliminating redundant joins.
* **Subquery Nesting:** Layering multi-level subqueries to filter analytical boundaries.

## 📁 Repository Structure
* `solutions.sql` - Complete annotated SQL scripts covering business insights.
