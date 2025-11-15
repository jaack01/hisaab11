-- ============================================================================
-- KHATABOOK CLONE - DATABASE SCHEMA
-- SQLite3 Database Schema for Flutter App
-- ============================================================================
-- Version: 1.0
-- Last Updated: November 15, 2025
-- Description: Complete database schema for a production-grade Khatabook clone
-- ============================================================================

-- ============================================================================
-- 1. BUSINESSES TABLE
-- Supports multiple business books within the same app
-- ============================================================================
CREATE TABLE IF NOT EXISTS businesses (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    owner_name TEXT,
    phone TEXT,
    email TEXT,
    address TEXT,
    gstin TEXT,
    pan TEXT,
    logo_path TEXT,
    currency_symbol TEXT DEFAULT '₹',
    is_default INTEGER DEFAULT 0,
    is_active INTEGER DEFAULT 1,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
);

CREATE INDEX idx_businesses_active ON businesses(is_active);
CREATE INDEX idx_businesses_default ON businesses(is_default);

-- ============================================================================
-- 2. CUSTOMERS TABLE
-- Core entity for tracking all customers/parties
-- ============================================================================
CREATE TABLE IF NOT EXISTS customers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    business_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    phone TEXT,
    email TEXT,
    address TEXT,
    gstin TEXT,
    pan TEXT,
    opening_balance REAL DEFAULT 0,
    opening_balance_type TEXT DEFAULT 'CREDIT', -- CREDIT (you gave) or DEBIT (you got)
    current_balance REAL DEFAULT 0, -- Calculated field, updated via triggers
    profile_image_path TEXT,
    notes TEXT,
    is_active INTEGER DEFAULT 1,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE
);

CREATE INDEX idx_customers_business ON customers(business_id);
CREATE INDEX idx_customers_phone ON customers(phone);
CREATE INDEX idx_customers_name ON customers(name COLLATE NOCASE);
CREATE INDEX idx_customers_active ON customers(is_active);
CREATE UNIQUE INDEX idx_customers_phone_business ON customers(phone, business_id) WHERE phone IS NOT NULL;

-- ============================================================================
-- 3. TRANSACTIONS TABLE
-- Records all credit/debit transactions
-- ============================================================================
CREATE TABLE IF NOT EXISTS transactions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    business_id INTEGER NOT NULL,
    customer_id INTEGER NOT NULL,
    transaction_type TEXT NOT NULL CHECK(transaction_type IN ('CREDIT', 'DEBIT')),
    -- CREDIT: You Gave (customer owes you)
    -- DEBIT: You Got (you owe customer or customer paid)
    amount REAL NOT NULL CHECK(amount > 0),
    description TEXT,
    transaction_date INTEGER NOT NULL, -- Unix timestamp
    attachment_path TEXT,
    payment_mode TEXT, -- CASH, UPI, CARD, CHEQUE, BANK_TRANSFER, OTHER
    reference_number TEXT, -- Cheque number, UPI transaction ID, etc.
    is_deleted INTEGER DEFAULT 0,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE
);

CREATE INDEX idx_transactions_customer ON transactions(customer_id);
CREATE INDEX idx_transactions_business ON transactions(business_id);
CREATE INDEX idx_transactions_date ON transactions(transaction_date DESC);
CREATE INDEX idx_transactions_type ON transactions(transaction_type);
CREATE INDEX idx_transactions_deleted ON transactions(is_deleted);

-- ============================================================================
-- 4. ITEMS/PRODUCTS TABLE
-- For inventory management
-- ============================================================================
CREATE TABLE IF NOT EXISTS items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    business_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    sku TEXT,
    hsn_code TEXT, -- HSN code for GST
    unit TEXT DEFAULT 'PCS', -- PCS, KG, LITER, etc.
    sale_price REAL DEFAULT 0,
    purchase_price REAL DEFAULT 0,
    tax_rate REAL DEFAULT 0, -- GST percentage
    stock_quantity REAL DEFAULT 0,
    low_stock_threshold REAL DEFAULT 10,
    image_path TEXT,
    category TEXT,
    is_active INTEGER DEFAULT 1,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE
);

CREATE INDEX idx_items_business ON items(business_id);
CREATE INDEX idx_items_name ON items(name COLLATE NOCASE);
CREATE INDEX idx_items_sku ON items(sku);
CREATE INDEX idx_items_active ON items(is_active);

-- ============================================================================
-- 5. INVOICES TABLE
-- For generating sales invoices
-- ============================================================================
CREATE TABLE IF NOT EXISTS invoices (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    business_id INTEGER NOT NULL,
    invoice_number TEXT NOT NULL,
    customer_id INTEGER NOT NULL,
    invoice_date INTEGER NOT NULL,
    due_date INTEGER,
    subtotal REAL NOT NULL DEFAULT 0,
    discount_percentage REAL DEFAULT 0,
    discount_amount REAL DEFAULT 0,
    tax_amount REAL DEFAULT 0,
    total_amount REAL NOT NULL,
    paid_amount REAL DEFAULT 0,
    balance_amount REAL DEFAULT 0,
    status TEXT DEFAULT 'UNPAID' CHECK(status IN ('PAID', 'UNPAID', 'PARTIAL', 'CANCELLED')),
    payment_terms TEXT,
    notes TEXT,
    terms_conditions TEXT,
    is_gst_invoice INTEGER DEFAULT 0,
    transaction_id INTEGER, -- Link to transaction if payment recorded
    is_deleted INTEGER DEFAULT 0,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    FOREIGN KEY (transaction_id) REFERENCES transactions(id)
);

CREATE UNIQUE INDEX idx_invoices_number_business ON invoices(invoice_number, business_id);
CREATE INDEX idx_invoices_customer ON invoices(customer_id);
CREATE INDEX idx_invoices_business ON invoices(business_id);
CREATE INDEX idx_invoices_date ON invoices(invoice_date DESC);
CREATE INDEX idx_invoices_status ON invoices(status);
CREATE INDEX idx_invoices_deleted ON invoices(is_deleted);

-- ============================================================================
-- 6. INVOICE_ITEMS TABLE
-- Line items for each invoice
-- ============================================================================
CREATE TABLE IF NOT EXISTS invoice_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    invoice_id INTEGER NOT NULL,
    item_id INTEGER, -- NULL if ad-hoc item
    item_name TEXT NOT NULL,
    description TEXT,
    hsn_code TEXT,
    quantity REAL NOT NULL CHECK(quantity > 0),
    unit TEXT DEFAULT 'PCS',
    rate REAL NOT NULL CHECK(rate >= 0),
    discount_percentage REAL DEFAULT 0,
    discount_amount REAL DEFAULT 0,
    taxable_amount REAL NOT NULL,
    tax_rate REAL DEFAULT 0,
    tax_amount REAL DEFAULT 0,
    total_amount REAL NOT NULL,
    created_at INTEGER NOT NULL,
    FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES items(id) ON DELETE SET NULL
);

CREATE INDEX idx_invoice_items_invoice ON invoice_items(invoice_id);
CREATE INDEX idx_invoice_items_item ON invoice_items(item_id);

-- ============================================================================
-- 7. REMINDERS TABLE
-- Payment reminders for customers
-- ============================================================================
CREATE TABLE IF NOT EXISTS reminders (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    business_id INTEGER NOT NULL,
    customer_id INTEGER NOT NULL,
    reminder_type TEXT DEFAULT 'PAYMENT' CHECK(reminder_type IN ('PAYMENT', 'FOLLOWUP', 'CUSTOM')),
    reminder_date INTEGER NOT NULL,
    reminder_time INTEGER, -- Specific time if scheduled
    message TEXT,
    channel TEXT DEFAULT 'WHATSAPP' CHECK(channel IN ('WHATSAPP', 'SMS', 'BOTH')),
    is_sent INTEGER DEFAULT 0,
    sent_at INTEGER,
    is_recurring INTEGER DEFAULT 0,
    recurrence_pattern TEXT, -- DAILY, WEEKLY, MONTHLY
    next_reminder_date INTEGER,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE
);

CREATE INDEX idx_reminders_customer ON reminders(customer_id);
CREATE INDEX idx_reminders_business ON reminders(business_id);
CREATE INDEX idx_reminders_date ON reminders(reminder_date);
CREATE INDEX idx_reminders_sent ON reminders(is_sent);

-- ============================================================================
-- 8. EXPENSES TABLE
-- Business expense tracking
-- ============================================================================
CREATE TABLE IF NOT EXISTS expenses (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    business_id INTEGER NOT NULL,
    category TEXT NOT NULL, -- RENT, SALARY, ELECTRICITY, TRANSPORTATION, etc.
    amount REAL NOT NULL CHECK(amount > 0),
    description TEXT,
    expense_date INTEGER NOT NULL,
    payment_mode TEXT,
    vendor_name TEXT,
    attachment_path TEXT,
    is_recurring INTEGER DEFAULT 0,
    recurrence_pattern TEXT,
    is_deleted INTEGER DEFAULT 0,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE
);

CREATE INDEX idx_expenses_business ON expenses(business_id);
CREATE INDEX idx_expenses_date ON expenses(expense_date DESC);
CREATE INDEX idx_expenses_category ON expenses(category);
CREATE INDEX idx_expenses_deleted ON expenses(is_deleted);

-- ============================================================================
-- 9. PAYMENTS TABLE
-- Track payments received from customers
-- ============================================================================
CREATE TABLE IF NOT EXISTS payments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    business_id INTEGER NOT NULL,
    customer_id INTEGER NOT NULL,
    invoice_id INTEGER, -- NULL if payment without invoice
    amount REAL NOT NULL CHECK(amount > 0),
    payment_date INTEGER NOT NULL,
    payment_mode TEXT NOT NULL,
    reference_number TEXT,
    notes TEXT,
    transaction_id INTEGER, -- Link to transaction entry
    is_deleted INTEGER DEFAULT 0,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE SET NULL,
    FOREIGN KEY (transaction_id) REFERENCES transactions(id)
);

CREATE INDEX idx_payments_customer ON payments(customer_id);
CREATE INDEX idx_payments_business ON payments(business_id);
CREATE INDEX idx_payments_invoice ON payments(invoice_id);
CREATE INDEX idx_payments_date ON payments(payment_date DESC);
CREATE INDEX idx_payments_deleted ON payments(is_deleted);

-- ============================================================================
-- 10. SETTINGS TABLE
-- App-level and business-level settings
-- ============================================================================
CREATE TABLE IF NOT EXISTS settings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    business_id INTEGER, -- NULL for app-level settings
    key TEXT NOT NULL,
    value TEXT,
    data_type TEXT DEFAULT 'STRING' CHECK(data_type IN ('STRING', 'INTEGER', 'REAL', 'BOOLEAN', 'JSON')),
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE
);

CREATE UNIQUE INDEX idx_settings_key_business ON settings(key, COALESCE(business_id, 0));

-- ============================================================================
-- 11. BACKUP_LOG TABLE
-- Track backup history
-- ============================================================================
CREATE TABLE IF NOT EXISTS backup_log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    backup_path TEXT NOT NULL,
    backup_size INTEGER, -- Size in bytes
    backup_type TEXT DEFAULT 'MANUAL' CHECK(backup_type IN ('MANUAL', 'AUTO', 'SCHEDULED')),
    status TEXT DEFAULT 'SUCCESS' CHECK(status IN ('SUCCESS', 'FAILED', 'IN_PROGRESS')),
    error_message TEXT,
    created_at INTEGER NOT NULL
);

CREATE INDEX idx_backup_log_date ON backup_log(created_at DESC);

-- ============================================================================
-- 12. REPORTS_CACHE TABLE
-- Cache generated reports for faster access
-- ============================================================================
CREATE TABLE IF NOT EXISTS reports_cache (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    business_id INTEGER NOT NULL,
    report_type TEXT NOT NULL,
    report_params TEXT, -- JSON string of parameters
    file_path TEXT,
    generated_at INTEGER NOT NULL,
    expires_at INTEGER,
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE
);

CREATE INDEX idx_reports_cache_business ON reports_cache(business_id);
CREATE INDEX idx_reports_cache_type ON reports_cache(report_type);
CREATE INDEX idx_reports_cache_expires ON reports_cache(expires_at);

-- ============================================================================
-- TRIGGERS FOR AUTOMATIC BALANCE CALCULATION
-- ============================================================================

-- Trigger: Update customer balance after INSERT on transactions
CREATE TRIGGER IF NOT EXISTS update_customer_balance_insert
AFTER INSERT ON transactions
WHEN NEW.is_deleted = 0
BEGIN
    UPDATE customers
    SET current_balance = current_balance +
        CASE
            WHEN NEW.transaction_type = 'CREDIT' THEN NEW.amount
            WHEN NEW.transaction_type = 'DEBIT' THEN -NEW.amount
        END,
        updated_at = strftime('%s', 'now')
    WHERE id = NEW.customer_id;
END;

-- Trigger: Update customer balance after UPDATE on transactions
CREATE TRIGGER IF NOT EXISTS update_customer_balance_update
AFTER UPDATE ON transactions
WHEN NEW.is_deleted = 0 OR OLD.is_deleted = 0
BEGIN
    UPDATE customers
    SET current_balance = current_balance
        -- Reverse old transaction
        + CASE
            WHEN OLD.is_deleted = 0 AND OLD.transaction_type = 'CREDIT' THEN -OLD.amount
            WHEN OLD.is_deleted = 0 AND OLD.transaction_type = 'DEBIT' THEN OLD.amount
            ELSE 0
        END
        -- Apply new transaction
        + CASE
            WHEN NEW.is_deleted = 0 AND NEW.transaction_type = 'CREDIT' THEN NEW.amount
            WHEN NEW.is_deleted = 0 AND NEW.transaction_type = 'DEBIT' THEN -NEW.amount
            ELSE 0
        END,
        updated_at = strftime('%s', 'now')
    WHERE id = NEW.customer_id;
END;

-- Trigger: Update customer balance after DELETE on transactions
CREATE TRIGGER IF NOT EXISTS update_customer_balance_delete
AFTER DELETE ON transactions
WHEN OLD.is_deleted = 0
BEGIN
    UPDATE customers
    SET current_balance = current_balance +
        CASE
            WHEN OLD.transaction_type = 'CREDIT' THEN -OLD.amount
            WHEN OLD.transaction_type = 'DEBIT' THEN OLD.amount
        END,
        updated_at = strftime('%s', 'now')
    WHERE id = OLD.customer_id;
END;

-- Trigger: Initialize customer balance with opening balance
CREATE TRIGGER IF NOT EXISTS init_customer_balance
AFTER INSERT ON customers
BEGIN
    UPDATE customers
    SET current_balance =
        CASE
            WHEN NEW.opening_balance_type = 'CREDIT' THEN NEW.opening_balance
            WHEN NEW.opening_balance_type = 'DEBIT' THEN -NEW.opening_balance
            ELSE 0
        END
    WHERE id = NEW.id;
END;

-- Trigger: Update invoice balance amount
CREATE TRIGGER IF NOT EXISTS update_invoice_balance
AFTER UPDATE OF paid_amount ON invoices
BEGIN
    UPDATE invoices
    SET balance_amount = total_amount - NEW.paid_amount,
        status = CASE
            WHEN NEW.paid_amount >= total_amount THEN 'PAID'
            WHEN NEW.paid_amount > 0 THEN 'PARTIAL'
            ELSE 'UNPAID'
        END,
        updated_at = strftime('%s', 'now')
    WHERE id = NEW.id;
END;

-- ============================================================================
-- VIEWS FOR COMMON QUERIES
-- ============================================================================

-- View: Customer Summary with Balance
CREATE VIEW IF NOT EXISTS v_customer_summary AS
SELECT
    c.id,
    c.business_id,
    c.name,
    c.phone,
    c.email,
    c.current_balance,
    CASE
        WHEN c.current_balance > 0 THEN 'TO_RECEIVE'
        WHEN c.current_balance < 0 THEN 'TO_PAY'
        ELSE 'SETTLED'
    END as balance_status,
    COUNT(DISTINCT t.id) as total_transactions,
    MAX(t.transaction_date) as last_transaction_date,
    c.created_at,
    c.updated_at
FROM customers c
LEFT JOIN transactions t ON c.id = t.customer_id AND t.is_deleted = 0
WHERE c.is_active = 1
GROUP BY c.id;

-- View: Recent Transactions
CREATE VIEW IF NOT EXISTS v_recent_transactions AS
SELECT
    t.id,
    t.business_id,
    t.customer_id,
    c.name as customer_name,
    c.phone as customer_phone,
    t.transaction_type,
    t.amount,
    t.description,
    t.transaction_date,
    t.payment_mode,
    t.created_at
FROM transactions t
INNER JOIN customers c ON t.customer_id = c.id
WHERE t.is_deleted = 0
ORDER BY t.transaction_date DESC, t.created_at DESC;

-- View: Pending Invoices
CREATE VIEW IF NOT EXISTS v_pending_invoices AS
SELECT
    i.id,
    i.business_id,
    i.invoice_number,
    i.customer_id,
    c.name as customer_name,
    c.phone as customer_phone,
    i.invoice_date,
    i.due_date,
    i.total_amount,
    i.paid_amount,
    i.balance_amount,
    i.status,
    CASE
        WHEN i.due_date < strftime('%s', 'now') THEN 1
        ELSE 0
    END as is_overdue
FROM invoices i
INNER JOIN customers c ON i.customer_id = c.id
WHERE i.status IN ('UNPAID', 'PARTIAL') AND i.is_deleted = 0
ORDER BY i.due_date ASC;

-- View: Business Performance Summary
CREATE VIEW IF NOT EXISTS v_business_summary AS
SELECT
    b.id as business_id,
    b.name as business_name,
    COUNT(DISTINCT c.id) as total_customers,
    COUNT(DISTINCT CASE WHEN c.current_balance > 0 THEN c.id END) as customers_to_receive,
    COUNT(DISTINCT CASE WHEN c.current_balance < 0 THEN c.id END) as customers_to_pay,
    SUM(CASE WHEN c.current_balance > 0 THEN c.current_balance ELSE 0 END) as total_receivable,
    SUM(CASE WHEN c.current_balance < 0 THEN ABS(c.current_balance) ELSE 0 END) as total_payable,
    COUNT(DISTINCT t.id) as total_transactions,
    COUNT(DISTINCT i.id) as total_invoices
FROM businesses b
LEFT JOIN customers c ON b.id = c.business_id AND c.is_active = 1
LEFT JOIN transactions t ON b.id = t.business_id AND t.is_deleted = 0
LEFT JOIN invoices i ON b.id = i.business_id AND i.is_deleted = 0
WHERE b.is_active = 1
GROUP BY b.id;

-- ============================================================================
-- INITIAL DATA / DEFAULT VALUES
-- ============================================================================

-- Insert default app settings
INSERT OR IGNORE INTO settings (business_id, key, value, data_type, updated_at) VALUES
(NULL, 'app_language', 'en', 'STRING', strftime('%s', 'now')),
(NULL, 'currency_symbol', '₹', 'STRING', strftime('%s', 'now')),
(NULL, 'date_format', 'dd/MM/yyyy', 'STRING', strftime('%s', 'now')),
(NULL, 'enable_pin_lock', '0', 'BOOLEAN', strftime('%s', 'now')),
(NULL, 'enable_biometric', '0', 'BOOLEAN', strftime('%s', 'now')),
(NULL, 'auto_backup_enabled', '1', 'BOOLEAN', strftime('%s', 'now')),
(NULL, 'backup_frequency', 'DAILY', 'STRING', strftime('%s', 'now')),
(NULL, 'theme_mode', 'SYSTEM', 'STRING', strftime('%s', 'now')),
(NULL, 'notification_enabled', '1', 'BOOLEAN', strftime('%s', 'now')),
(NULL, 'first_time_setup_completed', '0', 'BOOLEAN', strftime('%s', 'now'));

-- ============================================================================
-- END OF SCHEMA
-- ============================================================================
