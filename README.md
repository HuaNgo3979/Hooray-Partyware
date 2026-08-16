# HP (Hooray Partyware) — Database Design & Development, Assessment 3

Database Design and Development coursework project building a data system for **Hooray Partyware (HP)**, a partyware retailer run by business owner *Wendy*: an ERD and normalised (3NF) relational model, MySQL scripts (automatic customer membership tiering, an invoice-total trigger, and a sales performance report), and a predictive model of customer Spending Score using Orange Data Mining, comparing Linear Regression, Random Forest, and k-NN.

**Author:** Hua Quoc Thinh, Ngo , Master of Business Information Technology.

---

## 1. Project Overview

HP wants to digitalise its operations across its stores. This assignment delivers three connected pieces of work for that goal:

1. **Data Modelling:** an Entity Relationship Diagram (ERD) and a normalised (3NF) Relational Model Diagram (RMD) for HP's database, covering customers, products, stores, suppliers, employees, and invoices.
2. **SQL Scripts:** three working MySQL scripts that automate customer segmentation, invoice totals, and sales performance reporting.
3. **Data Analytics with Orange:** a predictive modelling workflow (Orange Data Mining) that pre-processes, explores, and predicts customer `Spending Score` from the HP customer dataset, comparing Linear Regression, Random Forest, and k-NN.

Full written analysis, explanations, and screenshots are in the report (see [`docs/`](HP-Database-Design-Assessment3/docs) and [`pdf`](HP-Database-Design-Assessment3/docs/ASM3-Database-IndividualAssignment-NgoHuaQuocThinh-s3863887.pdf) version).

---

## 2. Repository Structure

```
HP-Database-Design-Assessment3/
├── README.md                     ← this file
├── docs/                         ← written report & submitted deliverables
│   ├── SQL Scripts.docx                  (SQL scripts as submitted, with line-by-line explanations)
│   └── ASM3-...-s3863887.pdf             (final submitted PDF version of the report)
├── database-design/
│   └── ASM 4 - ERD & Relation.drawio     (draw.io file - 2 pages: ERD + Relational Model Diagram)
├── sql/
│   └── hp_sql_scripts.sql                (clean, runnable MySQL script — all 3 SQL tasks, extracted & tidied from docs/SQL Scripts.docx)
├── data-analytics/
│   ├── ASM3-...-s3863887.ows             (Orange Data Mining workflow file — open with Orange3)
│   ├── ASM3-...-s3863887.xlsx            (working data extract used in Orange)
│   ├── HPCustomers.xlsx                  (raw HP customer dataset, 1000 records)
│   └── HPDataset-header-description.txt  (data dictionary for HPCustomers.xlsx)
└── media/
    └── ASM3-...-s3863887.mp4             (video walkthrough / demonstration of the assignment)
```

> Original filenames (containing the student ID `s3863887`) were kept as-is for traceability to the original submission.

---

## 3. Data Modelling (Click [`./database-design`](HP-Database-Design-Assessment3/database-design) to see ERD/RMD)

The ERD/RMD (open with [`draw.io`](https://www.drawio.com/) or the [`draw.io VS Code extension`](https://marketplace.visualstudio.com/items?itemName=hediet.vscode-drawio)) models HP's core business entities:

| Entity | Purpose |
|---|---|
| **Customer** | Customer profile, membership tier, spend history |
| **Product** | Products sold, linked to a Supplier |
| **Store** | HP's physical stores |
| **Employee** | Staff records |
| **Supplier** | Product suppliers |
| **Invoice** | Sales transactions, linked to a Customer & Store |

Plus three **associative entities** resolving many-to-many relationships:

- **InvoiceDetail:** line items per invoice (Product × Invoice).
- **Inventory:** stock levels per store (Product × Store).
- **Responsibility:** staff rostering (Employee × Store).

The Relational Model Diagram (RMD) normalises this design to **Third Normal Form (3NF)**, with primary/foreign keys enforcing referential integrity across all tables. Full attribute lists, cardinalities, and business rules/assumptions are documented in [`docs/ASM 3 - Database.docx`](HP-Database-Design-Assessment3/docs) (Tables 1–3 and Appendices 1-2).

---

## 4. SQL Scripts (Click [`./sql`](HP-Database-Design-Assessment3/sql) to see SQL scripts)

Three MySQL scripts, consolidated into 2 version ([`docx`](HP-Database-Design-Assessment3/docs/SQL-Scripts.docx) and [`sql`](HP-Database-Design-Assessment3/sql/hp_sql_scripts.sql)):

| # | Script | Technique | What it does |
|---|---|---|---|
| 1 | **Auto-categorised Customer Membership** | Scalar function, JOIN, GROUP BY, nested query | Tiers each customer as `V.I.P` / `Platinum` / `Gold` / `Silver` / `Guest` based on paid invoice count and total spend, and writes the result back to `Customer`. |
| 2 | **Auto-calculate Invoice Total Amount** | Trigger | Automatically recalculates `Invoice.Total_Amount` whenever a new line item is inserted into `InvoiceDetail`. |
| 3 | **Aggregated Sales Performance Report** | Stored function + aggregation | Reports total quantity/revenue sold per product by month/quarter/year, and labels each as `Best Seller` / `Average` / `Low Sales` via `get_sales_performance()`. |

Business rationale, line-by-line explanations, and tested output tables for each script are in [`docs/`](HP-Database-Design-Assessment3/docs) and Section 2 of the main report.

---

## 5. Data Analytics with Orange (Click [`./data-analytics`](HP-Database-Design-Assessment3/data-analytics) to see the analytics)

Uses [`Orange Data Mining`](https://orangedatamining.com/) (open `*.ows` with Orange3) on the `HPCustomers.xlsx` dataset (1000 customers; see [`HPDataset-header-description.txt`](HP-Database-Design-Assessment3/data-analytics/HPDataset-header-description.txt) for the data dictionary — Age, Married, Annual Income, Subscription, Satisfaction, Frequency, and target variable **Spending Score**) (contact me for dataset).

**Workflow:**

1. **Pre-processing:** `Impute` widget: numeric fields (Age, Annual Income) filled with the mean; categorical fields (Married, Subscription, Satisfaction, Frequency) filled with the mode; rows missing the target `Spending Score` were dropped → 989 clean rows.
2. **Exploratory analysis:** box plots and distribution plots revealed a right-skew in Age/Annual Income (younger, low-to-middle income customers dominate) and a uniform spread in Spending Score, with a dispersion of 0.56.
3. **Predictive modelling:** three models trained to predict `Spending Score`:

   | Model | R² | RMSE | Verdict |
   |---|---|---|---|
   | **Random Forest** | **0.974** (highest) | **4,648** (lowest) | Best performer — recommended for HP |
   | Linear Regression | lower | higher | Least accurate; only suited to strongly linear relationships |
   | k-NN | mid | mid | Useful for localized/clustered customer behaviour |

   **Recommendation:** Random Forest most accurately predicts customer spending, enabling HP to target high-value customer segments and tailor promotions using Satisfaction and Annual Income as key drivers.

---

## 6. How to Use This Repo

- **Read the full write-up:** open [`docs/`](HP-Database-Design-Assessment3/docs) or the [`pdf`](HP-Database-Design-Assessment3/docs/ASM3-Database-IndividualAssignment-NgoHuaQuocThinh-s3863887.pdf) for the complete report with figures, tables, and references.
- **View the ERD/RMD:** open [`ASM 3 - ERD & Relation.drawio`](HP-Database-Design-Assessment3/database-design/) in draw.io.
- **Run the SQL:** load `sql/hp_sql_scripts.sql` into a MySQL client against a database that implements the `Customer`, `Invoice`, `InvoiceDetail`, and `Product` schema described above.
- **Reproduce the analytics:** install [Orange3](https://orangedatamining.com/download/), open the `.ows` file in `data-analytics/`, and run the workflow against `HPCustomers.xlsx`.
- **Watch the demo:** `media/*.mp4` walks through the assignment end-to-end.

