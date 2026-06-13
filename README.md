# 🚀 The 8-Week SQL Challenge Portfolio

## 📌 Project Overview
This repository contains my optimized, production-ready solutions for Danny Ma's **#8WeekSQLChallenge**. 

As an aspiring Data Engineer, I use these case studies to showcase my ability to translate complex business requirements into high-performance analytical queries. My solutions prioritize **query optimization, data pipeline modeling, and robust database architecture.**

---

## 🛠️ Technical Skill Stack
* **Linearized Pipelines:** Building cascading CTEs to pass metrics forward sequentially, minimizing CPU overhead by eliminating redundant joins.
* **Advanced Window Functions:** Implementing `DENSE_RANK()`, `ROW_NUMBER()`, `LEAD()`, and `LAG()` over custom partitions to dissect chronological business events.
* **Algorithmic Aggregations:** Stacking conditional aggregates (`CASE WHEN` inside `SUM`/`COUNT`) to engineer behavioral flags.
* **Multi-Layer Nesting:** Structuring multi-level subqueries to cleanly bypass database execution lifecycle limitations.

---

## 📂 Case Studies Index

| Case Study | Project Name | Focus Areas | Status |
| :--- | :--- | :--- | :--- |
| **Case Study -1** | 🍜 Danny's Diner | *Customer Behavior, Cohort Analysis, Joins & Aggregations* | **In Progress 🛠️** |

---

## 📊 Core Architecture Model: The Linear Data Pipeline
To avoid chaotic "spaghetti SQL," queries are structured as a clean declarative pipeline:
