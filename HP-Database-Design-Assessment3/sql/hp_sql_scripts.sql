-- =====================================================================
-- Hooray Partyware (HP) — SQL Scripts
-- Author: Ngo Hua Quoc Thinh (s3863887)
-- Source: "SQL Scripts.docx" / Section 2 of the assignment report
-- Engine: MySQL
-- =====================================================================


-- =====================================================================
-- SQL 1 — Auto-categorised Customer Membership
-- (Scalar function + Join + Group By + Nested query)
--
-- Purpose: Dynamically tiers every customer (V.I.P / Platinum / Gold /
-- Silver / Guest) based on their number of valid invoices and total
-- amount spent, then writes the result back onto the Customer table.
-- =====================================================================
SET SQL_SAFE_UPDATES = 0;

UPDATE Customer
JOIN (
    SELECT
        c.Cus_ID,
        COUNT(DISTINCT i.Invoice_ID) AS Total_PurchaseOrder,
        COALESCE(SUM(invd.InvD_QuantitySold * invd.InvD_UnitPrice), 0) AS Total_Spent
    FROM Customer c
    LEFT JOIN Invoice i
        ON c.Cus_ID = i.Cus_ID
        AND i.Invoice_Status IN ('Paid', 'Partially Paid')
    LEFT JOIN InvoiceDetail invd
        ON i.Invoice_ID = invd.Invoice_ID
    GROUP BY c.Cus_ID
) AS result
ON Customer.Cus_ID = result.Cus_ID
SET
    Customer.Cus_Membership = CASE
        WHEN result.Total_PurchaseOrder >= 200 AND result.Total_Spent >= 50000 THEN 'V.I.P'
        WHEN result.Total_PurchaseOrder >= 100 AND result.Total_Spent >= 10000 THEN 'Platinum'
        WHEN result.Total_PurchaseOrder >= 50  AND result.Total_Spent >= 5000  THEN 'Gold'
        WHEN result.Total_PurchaseOrder >= 10  AND result.Total_Spent >= 500   THEN 'Silver'
        ELSE 'Guest'
    END,
    Customer.Cus_NoPurchaseOrder = result.Total_PurchaseOrder,
    Customer.Cus_TotalSpentAmount = result.Total_Spent;

SET SQL_SAFE_UPDATES = 1;

-- Validation query — simulates the UPDATE logic above as a SELECT so the
-- expected membership tier can be checked without mutating the table.
SELECT
    c.Cus_ID,
    COUNT(DISTINCT i.Invoice_ID) AS Total_PurchaseOrder,
    COALESCE(SUM(invd.InvD_QuantitySold * invd.InvD_UnitPrice), 0) AS Total_Spent,
    CASE
        WHEN COUNT(DISTINCT i.Invoice_ID) >= 200 AND COALESCE(SUM(invd.InvD_QuantitySold * invd.InvD_UnitPrice), 0) >= 50000 THEN 'V.I.P'
        WHEN COUNT(DISTINCT i.Invoice_ID) >= 100 AND COALESCE(SUM(invd.InvD_QuantitySold * invd.InvD_UnitPrice), 0) >= 10000 THEN 'Platinum'
        WHEN COUNT(DISTINCT i.Invoice_ID) >= 50  AND COALESCE(SUM(invd.InvD_QuantitySold * invd.InvD_UnitPrice), 0) >= 5000  THEN 'Gold'
        WHEN COUNT(DISTINCT i.Invoice_ID) >= 10  AND COALESCE(SUM(invd.InvD_QuantitySold * invd.InvD_UnitPrice), 0) >= 500   THEN 'Silver'
        ELSE 'Guest'
    END AS Expected_Membership
FROM Customer c
LEFT JOIN Invoice i
    ON c.Cus_ID = i.Cus_ID
    AND i.Invoice_Status IN ('Paid', 'Partially Paid')
LEFT JOIN InvoiceDetail invd
    ON i.Invoice_ID = invd.Invoice_ID
GROUP BY c.Cus_ID;


-- =====================================================================
-- SQL 2 — Auto-calculate Invoice Total Amount
-- (Trigger)
--
-- Purpose: Automatically (re)calculates Invoice.Total_Amount whenever a
-- new line item is inserted into InvoiceDetail, removing the need for
-- manual total calculations.
-- =====================================================================
SET SQL_SAFE_UPDATES = 0;

ALTER TABLE Invoice
ADD COLUMN IF NOT EXISTS Total_Amount DECIMAL(10,2);

DROP TRIGGER IF EXISTS invoice_total;

DELIMITER $$
CREATE TRIGGER invoice_total
AFTER INSERT ON InvoiceDetail
FOR EACH ROW
BEGIN
    UPDATE Invoice
    SET Total_Amount = (
        SELECT SUM(InvD_QuantitySold * InvD_UnitPrice)
        FROM InvoiceDetail
        WHERE Invoice_ID = NEW.Invoice_ID
    )
    WHERE Invoice_ID = NEW.Invoice_ID;
END$$
DELIMITER ;

SET SQL_SAFE_UPDATES = 1;

-- Test: insert a new invoice, then insert its line items — the trigger
-- fires automatically and populates Invoice.Total_Amount.
INSERT INTO Invoice (Invoice_ID, Cus_ID, Str_ID, Invoice_Date, Invoice_PaymentMethod, Invoice_Status)
VALUES
    (3001, 10, 2, CURDATE(), 'CreditCard', 'Paid'),
    (3002, 11, 3, CURDATE(), 'DebitCard', 'Paid');

INSERT INTO InvoiceDetail (Prod_ID, Invoice_ID, InvD_QuantitySold, InvD_UnitPrice)
VALUES
    (101, 3001, 2, 25.00),
    (102, 3002, 7, 45.00);


-- =====================================================================
-- SQL 3 — Aggregated Sales Performance Report
-- (Stored function + aggregation)
--
-- Purpose: Reports total quantity sold and total revenue per product,
-- per month/quarter/year, and classifies each product's performance
-- using the get_sales_performance() function.
-- =====================================================================
DELIMITER $$
CREATE FUNCTION get_sales_performance (sales_amount DECIMAL(10,2))
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE performance VARCHAR(20);
    IF sales_amount >= 10000 THEN
        SET performance = 'Best Seller';
    ELSEIF sales_amount >= 5000 THEN
        SET performance = 'Average';
    ELSE
        SET performance = 'Low Sales';
    END IF;
    RETURN performance;
END$$
DELIMITER ;

-- Sales performance report, using the function above
SELECT
    YEAR(i.Invoice_Date) AS Year,
    LPAD(MONTH(i.Invoice_Date), 2, '0') AS Month,
    CONCAT('Q', QUARTER(i.Invoice_Date)) AS Quarter,
    p.Prod_Name,
    SUM(d.InvD_QuantitySold * d.InvD_UnitPrice) AS Total_Sales_Amount,
    SUM(d.InvD_QuantitySold) AS Total_Quantity_Sold,
    get_sales_performance(SUM(d.InvD_QuantitySold * d.InvD_UnitPrice)) AS Sales_Performance
FROM Invoice i
JOIN InvoiceDetail d
    ON i.Invoice_ID = d.Invoice_ID
JOIN Product p
    ON d.Prod_ID = p.Prod_ID
WHERE i.Invoice_Status IN ('Paid', 'Partially Paid')
GROUP BY Year, Month, Quarter, p.Prod_Name
ORDER BY Year, Month, Quarter, p.Prod_Name;
