# NovaStoreDB: E-Commerce Database Management and Analytical Reporting System

NovaStoreDB is a relational database (RDBMS) project developed on SQL Server to manage the operational data flow of a modern e-commerce platform, automate data integrity, and support strategic decision-making processes.

The project offers an end-to-end database architecture encompassing database schema design (DDL), data manipulation (DML), data consistency automation (Triggers), and business intelligence analytics (Reporting Queries).

## Technical Architecture and Solution Components

* **Relational Data Model (DDL):** An optimized 5-core-table architecture (`Categories`, `Customers`, `Products`, `Orders`, `OrderDetails`) engineered to ensure data standardization and prevent anomalies.
* **Data Integrity and Automation (Trigger):** An `AFTER TRIGGER` mechanism activated by any data modification (`INSERT`, `UPDATE`, `DELETE`) in the `OrderDetails` table to compute and update the associated order's total amount (`TotalAmount`) asynchronously in real-time.
* **Abstraction Layer (View):** The `vw_SiparisOzet` view layer, which masks complex multi-table `INNER JOIN` structures to optimize system performance and standardize query workflows.
* **Business Intelligence and Analytical Queries:**
  * Critical stock level monitoring and proactive inventory management.
  * Customer segmentation and lifetime revenue analysis.
  * Time-based order performance metrics and data analytics using `DATEDIFF`.

## Repository Structure

* `EcemOzen_NovaStore_Proje.sql`: The primary SQL script containing the complete database schema, triggers, views, testing datasets, and advanced analytical reporting queries.

## Deployment and Setup

1. Initialize a preferred SQL Server management tool (SSMS, Azure Data Studio, etc.).
2. Clone or download the `.sql` script file from this repository.
3. Execute the script to automatically configure the `NovaStoreDB` database, structural schemas, sample datasets, and analytical views.
