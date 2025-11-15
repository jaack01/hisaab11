import 'package:sqflite/sqflite.dart';

/// Database Migration Version 1
/// Creates all tables, indexes, triggers, and views
class MigrationV1 {
  static Future<void> execute(Database db) async {
    await db.transaction((txn) async {
      // Create all tables
      await _createBusinessesTable(txn);
      await _createCustomersTable(txn);
      await _createTransactionsTable(txn);
      await _createItemsTable(txn);
      await _createInvoicesTable(txn);
      await _createInvoiceItemsTable(txn);
      await _createRemindersTable(txn);
      await _createExpensesTable(txn);
      await _createPaymentsTable(txn);
      await _createSettingsTable(txn);
      await _createBackupLogTable(txn);
      await _createReportsCacheTable(txn);

      // Create indexes
      await _createIndexes(txn);

      // Create triggers
      await _createTriggers(txn);

      // Create views
      await _createViews(txn);

      // Insert default settings
      await _insertDefaultSettings(txn);
    });
  }

  static Future<void> _createBusinessesTable(Transaction txn) async {
    await txn.execute('''
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
      )
    ''');
  }

  static Future<void> _createCustomersTable(Transaction txn) async {
    await txn.execute('''
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
        opening_balance_type TEXT DEFAULT 'CREDIT',
        current_balance REAL DEFAULT 0,
        profile_image_path TEXT,
        notes TEXT,
        is_active INTEGER DEFAULT 1,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> _createTransactionsTable(Transaction txn) async {
    await txn.execute('''
      CREATE TABLE IF NOT EXISTS transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        business_id INTEGER NOT NULL,
        customer_id INTEGER NOT NULL,
        transaction_type TEXT NOT NULL CHECK(transaction_type IN ('CREDIT', 'DEBIT')),
        amount REAL NOT NULL CHECK(amount > 0),
        description TEXT,
        transaction_date INTEGER NOT NULL,
        attachment_path TEXT,
        payment_mode TEXT,
        reference_number TEXT,
        is_deleted INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
        FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> _createItemsTable(Transaction txn) async {
    await txn.execute('''
      CREATE TABLE IF NOT EXISTS items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        business_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        sku TEXT,
        hsn_code TEXT,
        unit TEXT DEFAULT 'PCS',
        sale_price REAL DEFAULT 0,
        purchase_price REAL DEFAULT 0,
        tax_rate REAL DEFAULT 0,
        stock_quantity REAL DEFAULT 0,
        low_stock_threshold REAL DEFAULT 10,
        image_path TEXT,
        category TEXT,
        is_active INTEGER DEFAULT 1,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> _createInvoicesTable(Transaction txn) async {
    await txn.execute('''
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
        transaction_id INTEGER,
        is_deleted INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
        FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
        FOREIGN KEY (transaction_id) REFERENCES transactions(id)
      )
    ''');
  }

  static Future<void> _createInvoiceItemsTable(Transaction txn) async {
    await txn.execute('''
      CREATE TABLE IF NOT EXISTS invoice_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_id INTEGER NOT NULL,
        item_id INTEGER,
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
      )
    ''');
  }

  static Future<void> _createRemindersTable(Transaction txn) async {
    await txn.execute('''
      CREATE TABLE IF NOT EXISTS reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        business_id INTEGER NOT NULL,
        customer_id INTEGER NOT NULL,
        reminder_type TEXT DEFAULT 'PAYMENT' CHECK(reminder_type IN ('PAYMENT', 'FOLLOWUP', 'CUSTOM')),
        reminder_date INTEGER NOT NULL,
        reminder_time INTEGER,
        message TEXT,
        channel TEXT DEFAULT 'WHATSAPP' CHECK(channel IN ('WHATSAPP', 'SMS', 'BOTH')),
        is_sent INTEGER DEFAULT 0,
        sent_at INTEGER,
        is_recurring INTEGER DEFAULT 0,
        recurrence_pattern TEXT,
        next_reminder_date INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
        FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> _createExpensesTable(Transaction txn) async {
    await txn.execute('''
      CREATE TABLE IF NOT EXISTS expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        business_id INTEGER NOT NULL,
        category TEXT NOT NULL,
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
      )
    ''');
  }

  static Future<void> _createPaymentsTable(Transaction txn) async {
    await txn.execute('''
      CREATE TABLE IF NOT EXISTS payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        business_id INTEGER NOT NULL,
        customer_id INTEGER NOT NULL,
        invoice_id INTEGER,
        amount REAL NOT NULL CHECK(amount > 0),
        payment_date INTEGER NOT NULL,
        payment_mode TEXT NOT NULL,
        reference_number TEXT,
        notes TEXT,
        transaction_id INTEGER,
        is_deleted INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
        FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
        FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE SET NULL,
        FOREIGN KEY (transaction_id) REFERENCES transactions(id)
      )
    ''');
  }

  static Future<void> _createSettingsTable(Transaction txn) async {
    await txn.execute('''
      CREATE TABLE IF NOT EXISTS settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        business_id INTEGER,
        key TEXT NOT NULL,
        value TEXT,
        data_type TEXT DEFAULT 'STRING' CHECK(data_type IN ('STRING', 'INTEGER', 'REAL', 'BOOLEAN', 'JSON')),
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> _createBackupLogTable(Transaction txn) async {
    await txn.execute('''
      CREATE TABLE IF NOT EXISTS backup_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        backup_path TEXT NOT NULL,
        backup_size INTEGER,
        backup_type TEXT DEFAULT 'MANUAL' CHECK(backup_type IN ('MANUAL', 'AUTO', 'SCHEDULED')),
        status TEXT DEFAULT 'SUCCESS' CHECK(status IN ('SUCCESS', 'FAILED', 'IN_PROGRESS')),
        error_message TEXT,
        created_at INTEGER NOT NULL
      )
    ''');
  }

  static Future<void> _createReportsCacheTable(Transaction txn) async {
    await txn.execute('''
      CREATE TABLE IF NOT EXISTS reports_cache (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        business_id INTEGER NOT NULL,
        report_type TEXT NOT NULL,
        report_params TEXT,
        file_path TEXT,
        generated_at INTEGER NOT NULL,
        expires_at INTEGER,
        FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> _createIndexes(Transaction txn) async {
    // Businesses indexes
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_businesses_active ON businesses(is_active)');
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_businesses_default ON businesses(is_default)');

    // Customers indexes
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_customers_business ON customers(business_id)');
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_customers_phone ON customers(phone)');
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_customers_name ON customers(name COLLATE NOCASE)');
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_customers_active ON customers(is_active)');
    await txn.execute('CREATE UNIQUE INDEX IF NOT EXISTS idx_customers_phone_business ON customers(phone, business_id) WHERE phone IS NOT NULL');

    // Transactions indexes
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_transactions_customer ON transactions(customer_id)');
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_transactions_business ON transactions(business_id)');
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_transactions_date ON transactions(transaction_date DESC)');
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_transactions_type ON transactions(transaction_type)');
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_transactions_deleted ON transactions(is_deleted)');

    // Items indexes
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_items_business ON items(business_id)');
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_items_name ON items(name COLLATE NOCASE)');
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_items_sku ON items(sku)');
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_items_active ON items(is_active)');

    // Invoices indexes
    await txn.execute('CREATE UNIQUE INDEX IF NOT EXISTS idx_invoices_number_business ON invoices(invoice_number, business_id)');
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_invoices_customer ON invoices(customer_id)');
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_invoices_business ON invoices(business_id)');
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_invoices_date ON invoices(invoice_date DESC)');
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_invoices_status ON invoices(status)');
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_invoices_deleted ON invoices(is_deleted)');

    // Invoice items indexes
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_invoice_items_invoice ON invoice_items(invoice_id)');
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_invoice_items_item ON invoice_items(item_id)');

    // Reminders indexes
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_reminders_customer ON reminders(customer_id)');
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_reminders_business ON reminders(business_id)');
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_reminders_date ON reminders(reminder_date)');
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_reminders_sent ON reminders(is_sent)');

    // Expenses indexes
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_expenses_business ON expenses(business_id)');
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_expenses_date ON expenses(expense_date DESC)');
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_expenses_category ON expenses(category)');
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_expenses_deleted ON expenses(is_deleted)');

    // Payments indexes
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_payments_customer ON payments(customer_id)');
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_payments_business ON payments(business_id)');
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_payments_invoice ON payments(invoice_id)');
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_payments_date ON payments(payment_date DESC)');
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_payments_deleted ON payments(is_deleted)');

    // Settings indexes
    await txn.execute('CREATE UNIQUE INDEX IF NOT EXISTS idx_settings_key_business ON settings(key, COALESCE(business_id, 0))');

    // Backup log indexes
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_backup_log_date ON backup_log(created_at DESC)');

    // Reports cache indexes
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_reports_cache_business ON reports_cache(business_id)');
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_reports_cache_type ON reports_cache(report_type)');
    await txn.execute('CREATE INDEX IF NOT EXISTS idx_reports_cache_expires ON reports_cache(expires_at)');
  }

  static Future<void> _createTriggers(Transaction txn) async {
    // Trigger: Update customer balance after INSERT on transactions
    await txn.execute('''
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
      END
    ''');

    // Trigger: Update customer balance after UPDATE on transactions
    await txn.execute('''
      CREATE TRIGGER IF NOT EXISTS update_customer_balance_update
      AFTER UPDATE ON transactions
      WHEN NEW.is_deleted = 0 OR OLD.is_deleted = 0
      BEGIN
        UPDATE customers
        SET current_balance = current_balance
          + CASE
              WHEN OLD.is_deleted = 0 AND OLD.transaction_type = 'CREDIT' THEN -OLD.amount
              WHEN OLD.is_deleted = 0 AND OLD.transaction_type = 'DEBIT' THEN OLD.amount
              ELSE 0
            END
          + CASE
              WHEN NEW.is_deleted = 0 AND NEW.transaction_type = 'CREDIT' THEN NEW.amount
              WHEN NEW.is_deleted = 0 AND NEW.transaction_type = 'DEBIT' THEN -NEW.amount
              ELSE 0
            END,
          updated_at = strftime('%s', 'now')
        WHERE id = NEW.customer_id;
      END
    ''');

    // Trigger: Update customer balance after DELETE on transactions
    await txn.execute('''
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
      END
    ''');

    // Trigger: Initialize customer balance with opening balance
    await txn.execute('''
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
      END
    ''');

    // Trigger: Update invoice balance amount
    await txn.execute('''
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
      END
    ''');
  }

  static Future<void> _createViews(Transaction txn) async {
    // View: Customer Summary
    await txn.execute('''
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
      GROUP BY c.id
    ''');

    // View: Recent Transactions
    await txn.execute('''
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
      ORDER BY t.transaction_date DESC, t.created_at DESC
    ''');

    // View: Pending Invoices
    await txn.execute('''
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
      ORDER BY i.due_date ASC
    ''');

    // View: Business Performance Summary
    await txn.execute('''
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
      GROUP BY b.id
    ''');
  }

  static Future<void> _insertDefaultSettings(Transaction txn) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final defaultSettings = [
      {'key': 'app_language', 'value': 'en', 'data_type': 'STRING'},
      {'key': 'currency_symbol', 'value': '₹', 'data_type': 'STRING'},
      {'key': 'date_format', 'value': 'dd/MM/yyyy', 'data_type': 'STRING'},
      {'key': 'enable_pin_lock', 'value': '0', 'data_type': 'BOOLEAN'},
      {'key': 'enable_biometric', 'value': '0', 'data_type': 'BOOLEAN'},
      {'key': 'auto_backup_enabled', 'value': '1', 'data_type': 'BOOLEAN'},
      {'key': 'backup_frequency', 'value': 'DAILY', 'data_type': 'STRING'},
      {'key': 'theme_mode', 'value': 'SYSTEM', 'data_type': 'STRING'},
      {'key': 'notification_enabled', 'value': '1', 'data_type': 'BOOLEAN'},
      {'key': 'first_time_setup_completed', 'value': '0', 'data_type': 'BOOLEAN'},
    ];

    for (final setting in defaultSettings) {
      await txn.insert('settings', {
        'business_id': null,
        'key': setting['key'],
        'value': setting['value'],
        'data_type': setting['data_type'],
        'updated_at': now,
      });
    }
  }
}
