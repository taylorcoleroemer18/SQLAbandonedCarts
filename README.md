# 🛒 SQL E-Commerce Funnel Analysis Project

This project explores how users interact with products in an e-commerce setting by tracking their behavior across four key funnel stages:

1. `product_view`
2. `add_to_cart`
3. `begin_checkout`
4. `purchase`

---

## 📊 Objectives

- Calculate **conversion rates** at each step of the funnel
- Identify products with the **highest and lowest purchase rates**
- Join events with product metadata (name, category, price)
- Deliver actionable insights for marketing or product strategy

---

## 🧠 Key SQL Concepts Used

- Common Table Expressions (CTEs)
- Aggregate functions (`SUM`, `MAX`, `COUNT`)
- CASE WHEN logic for event tagging
- Joins
- NULL handling and conversion math
- Clean conversion rate calculations (with rounding and %s)

---

## 🧩 Files in This Repo

| File | Description |
|------|-------------|
| `funnel_analysis.sql` | Full query to analyze funnel and sort by conversion |
| `products_table.sql` | Creates & populates a sample `products` table |
| `events_table.sql` | Creates and populates a sample `events` table |
| `README.md` | Project overview, goals, and technical details |

---

## 📷 Sample Output

![image](https://github.com/user-attachments/assets/ebe3c086-9a28-4589-8bb2-7d6977f554bb)

---

## 🛠 Built With

- Microsoft SQL Server Management Studio (SSMS)
- T-SQL
- Sample e-commerce event data

---

## 💼 Portfolio Description

Built a multi-step SQL funnel analysis to identify high/low-performing e-commerce products based on user events. Delivered insights using T-SQL, CTEs, and joins with real-world product metadata.

---

## 📩 Contact

Have questions? Feel free to reach out or fork this repo and remix it!

