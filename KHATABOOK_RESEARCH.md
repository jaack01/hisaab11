# Khatabook App - Comprehensive Research & Feature Analysis

## Executive Summary

Khatabook is India's leading digital accounting ledger app designed for small and medium-sized businesses (SMEs). Founded by four IIT-Bombay graduates in January 2019, it has become the digital replacement for traditional paper accounting ledgers ("khata"). The app focuses on simplicity, multilingual support, and offline-first functionality.

---

## Core Features & Functionality

### 1. **Customer & Ledger Management**

#### Customer Registration
- Add customer details with contact information (name, phone number)
- Individual customer pages with complete transaction history
- Multiple customer management in one place
- Customer search and filtering capabilities

#### Ledger System
- **You Gave (Credit)**: Record money given to customers/suppliers
- **You Got (Debit)**: Record money received from customers
- Automatic balance calculation (net balance per customer)
- Real-time ledger updates
- Color-coded entries (typically red for credit, green for debit)

#### Transaction Recording
- Date and timestamp for each entry
- Amount field with currency support (₹)
- Optional description/notes for each transaction
- Automatic date capture with manual override option
- Transaction history with chronological ordering

### 2. **Payment Collection & Digital Integration**

#### Payment Methods
- UPI payment requests
- QR Code generation for instant payments
- Payment links shareable via WhatsApp/SMS
- Multiple payment modes: UPI, cards, wallets
- Direct bank account integration

#### Payment Features
- "Request Payment" button on customer pages
- Quick transfer options
- Payment confirmation tracking
- Payment history per customer

### 3. **Reminder & Communication System**

#### Automated Reminders
- Schedule reminders for specific dates
- SMS reminders from merchant's phone number
- WhatsApp message integration
- Customizable reminder messages
- Bulk reminder sending capability

#### Communication Features
- Send payment links on WhatsApp
- Share transaction reports via WhatsApp/SMS
- Customer notification system
- Payment request notifications

### 4. **Reports & Analytics**

#### Report Types
- **Ledger Reports**: Complete transaction history
- **PDF Reports**: Downloadable with net balance and transaction details
- **Profit & Loss Statements**
- **Balance Sheets**
- **Daybook**: Daily transaction summary
- **Item-wise Profit Reports**
- **Sales Reports**: Daily, monthly, yearly
- **Purchase Reports**: Daily, monthly, yearly
- **Expense Reports**: Daily, monthly, yearly
- **Cash Book**: Day-wise cash flow reports

#### Report Features
- Customizable date range filters
- Export to PDF format
- Shareable reports
- Print-ready format
- Business analytics and insights

### 5. **Invoicing & GST**

#### Invoice Generation
- Professional GST invoices
- Non-GST invoice option
- Customizable invoice fields
- Company logo and branding
- Item-wise billing

#### GST Features
- GST calculation and inclusion
- GST reports for compliance
- Tax summary generation
- GSTIN registration support

### 6. **Inventory Management**

#### Stock Tracking
- Real-time inventory monitoring
- Low stock alerts
- Item-wise reports
- Stock movement tracking
- Product catalog management

#### Features
- Add/edit/delete items
- Quantity tracking
- Price management
- Export item-wise reports

### 7. **Business Management**

#### Multiple Business Books
- Separate accounting books for different businesses
- Business-wise segregation
- Independent ledger management
- Consolidated view option

#### Business Tools
- Professional business card generation (11 design templates)
- QR code for business
- Digital business identity
- Marketing materials

### 8. **Security & Data Management**

#### Security Features
- App-level PIN/Password protection
- Biometric authentication option
- Transaction PIN for sensitive operations
- Secure data encryption

#### Data Backup & Sync
- Automatic cloud backup
- Cross-device synchronization
- Data recovery options
- Access from multiple devices with same phone number
- No data loss on phone damage/loss

### 9. **User Experience Features**

#### Multilingual Support
- 11 Indian languages supported
- Regional language preference
- Language-specific number formats
- Localized content

#### Offline Functionality
- Core features work offline
- Auto-sync when online
- Local data storage
- Reliable in low-connectivity areas

#### Interface Design
- Intuitive, simple navigation
- Minimal technical expertise required
- Quick access to frequent actions
- Dashboard with key metrics
- Color-coded transactions

### 10. **Additional Features**

#### Support System
- In-app chat support
- Call support
- WhatsApp support
- Help documentation
- FAQ section

#### Referral & Rewards
- Referral rewards program
- User acquisition incentives
- Promotional campaigns

#### Notifications
- Transaction alerts
- Payment reminders
- Low stock notifications
- Backup completion alerts

---

## User Interface & Design Patterns

### Dashboard/Home Screen
- **Summary Cards**: Total receivable (money to get), total payable (money to give)
- **Quick Actions**: Add customer, record transaction, view reports
- **Recent Transactions**: Chronological list with customer names
- **Search Bar**: Quick customer/transaction search
- **Navigation Tabs**: Customers, Reports, More/Settings

### Customer List Screen
- **List View**: Customers with outstanding balances
- **Sort Options**: By name, balance amount, last transaction date
- **Filter Options**: Customers who owe money, customers you owe
- **Search**: Real-time customer search
- **Add Customer Button**: Floating action button (FAB)
- **Balance Display**: Color-coded (red/green) based on credit/debit

### Customer Detail Screen
- **Customer Header**: Name, phone, total balance (prominent)
- **Quick Actions Bar**:
  - Add Transaction
  - Request Payment
  - Send Reminder
  - View Report
- **Transaction List**: Chronological with date, amount, description
- **Transaction Type Indicator**: "You Gave" vs "You Got"
- **Running Balance**: After each transaction

### Add Transaction Screen
- **Transaction Type Toggle**: "You Gave" / "You Got" buttons
- **Amount Input**: Large, prominent number pad
- **Date Picker**: Default to today with calendar option
- **Description Field**: Optional text input
- **Save Button**: Prominent CTA
- **Attachment Option**: Photo/bill attachment

### Reports Screen
- **Report Type Selection**: Dropdown or tabs
- **Date Range Selector**: Custom date picker
- **Filter Options**: Customer, transaction type, amount range
- **Preview**: Quick report preview
- **Export Options**: PDF, WhatsApp, SMS share buttons
- **Print Option**: Generate printable version

### Settings Screen
- **Profile Section**: Business details, logo
- **Security**: PIN/Password setup, backup settings
- **Language**: Language preference selector
- **Notifications**: Notification preferences
- **Data Management**: Backup & restore, export data
- **Support**: Help, contact support, FAQs
- **About**: App version, terms, privacy policy

---

## Technical Architecture Recommendations

### Technology Stack
- **Framework**: Flutter 3.x
- **UI Library**: Material Design 3 (Material You)
- **Database**: SQLite3 (sqflite or drift package)
- **State Management**: Riverpod or Bloc
- **Local Storage**: SharedPreferences for settings
- **PDF Generation**: pdf package
- **Date Handling**: intl package
- **Architecture**: Clean Architecture with Repository Pattern

### Key Packages Needed
```yaml
dependencies:
  flutter_localizations: # Multi-language support
  intl: # Date formatting, currency
  sqflite: # SQLite database
  path_provider: # Database file path
  pdf: # PDF generation
  share_plus: # Share functionality
  url_launcher: # WhatsApp/SMS integration
  fl_chart: # Charts for analytics
  image_picker: # Bill/receipt photos
  permission_handler: # SMS/Contacts permissions
  local_auth: # Biometric authentication
  shared_preferences: # App settings
  provider / riverpod / bloc: # State management
```

---

## Database Schema (SQLite3)

### Core Tables

#### 1. Customers Table
```sql
CREATE TABLE customers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    phone TEXT UNIQUE,
    email TEXT,
    address TEXT,
    gstin TEXT,
    opening_balance REAL DEFAULT 0,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    is_active INTEGER DEFAULT 1
);
```

#### 2. Transactions Table
```sql
CREATE TABLE transactions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER NOT NULL,
    transaction_type TEXT NOT NULL, -- 'CREDIT' or 'DEBIT'
    amount REAL NOT NULL,
    description TEXT,
    transaction_date INTEGER NOT NULL,
    created_at INTEGER NOT NULL,
    attachment_path TEXT,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE
);
```

#### 3. Reminders Table
```sql
CREATE TABLE reminders (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER NOT NULL,
    reminder_date INTEGER NOT NULL,
    message TEXT,
    is_sent INTEGER DEFAULT 0,
    sent_at INTEGER,
    created_at INTEGER NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE
);
```

#### 4. Items/Products Table (for inventory)
```sql
CREATE TABLE items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    unit TEXT,
    price REAL,
    stock_quantity REAL DEFAULT 0,
    low_stock_threshold REAL DEFAULT 10,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
);
```

#### 5. Invoices Table
```sql
CREATE TABLE invoices (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    invoice_number TEXT UNIQUE NOT NULL,
    customer_id INTEGER NOT NULL,
    invoice_date INTEGER NOT NULL,
    total_amount REAL NOT NULL,
    tax_amount REAL DEFAULT 0,
    discount_amount REAL DEFAULT 0,
    net_amount REAL NOT NULL,
    status TEXT DEFAULT 'UNPAID', -- PAID, UNPAID, PARTIAL
    notes TEXT,
    created_at INTEGER NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);
```

#### 6. Invoice Items Table
```sql
CREATE TABLE invoice_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    invoice_id INTEGER NOT NULL,
    item_id INTEGER,
    item_name TEXT NOT NULL,
    quantity REAL NOT NULL,
    rate REAL NOT NULL,
    amount REAL NOT NULL,
    FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES items(id)
);
```

#### 7. Businesses Table (for multiple business books)
```sql
CREATE TABLE businesses (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    owner_name TEXT,
    phone TEXT,
    email TEXT,
    address TEXT,
    gstin TEXT,
    logo_path TEXT,
    is_active INTEGER DEFAULT 1,
    created_at INTEGER NOT NULL
);
```

#### 8. Settings Table
```sql
CREATE TABLE settings (
    key TEXT PRIMARY KEY,
    value TEXT,
    updated_at INTEGER NOT NULL
);
```

---

## Color Scheme & UI Guidelines (Material 3)

### Primary Colors
- **Primary**: Deep Blue (#1976D2) or Brand-specific color
- **Secondary**: Teal (#00897B) for accents
- **Success/Credit (You Got)**: Green (#4CAF50)
- **Error/Debit (You Gave)**: Red (#F44336)
- **Warning**: Orange (#FF9800)
- **Info**: Light Blue (#03A9F4)

### Typography
- **Headings**: Roboto Bold
- **Body**: Roboto Regular
- **Numbers**: Roboto Medium (tabular numbers)
- **Currency**: Large, bold display for amounts

### Material 3 Components to Use
- **Cards**: For customer list items, summary cards
- **FAB (Floating Action Button)**: Add customer/transaction
- **Bottom Navigation**: Main app navigation
- **App Bar**: With search, actions
- **Dialogs**: Confirmations, forms
- **Snackbars**: Success/error messages
- **Chips**: Filters, tags
- **Lists**: Transaction history, customers

---

## Key User Flows

### 1. Add Customer Flow
1. Tap "Add Customer" FAB
2. Enter customer name (required)
3. Enter phone number (optional but recommended)
4. Enter opening balance if any
5. Save → Navigate to customer detail screen

### 2. Record Transaction Flow
1. Select customer from list OR from customer detail screen
2. Tap "Add Transaction"
3. Select type: "You Gave" or "You Got"
4. Enter amount
5. Add description (optional)
6. Select date (default: today)
7. Add attachment if needed
8. Save → Update balance, show confirmation

### 3. Send Payment Reminder Flow
1. Navigate to customer detail
2. Tap "Send Reminder"
3. Preview message
4. Select channel: WhatsApp or SMS
5. Optionally schedule for later
6. Send → Confirmation

### 4. Generate Report Flow
1. Navigate to Reports section
2. Select report type
3. Choose date range
4. Apply filters (optional)
5. Preview report
6. Export as PDF or share via WhatsApp/SMS

### 5. Create Invoice Flow
1. Tap "Create Invoice"
2. Select customer
3. Add items/services with quantities and rates
4. Apply GST if applicable
5. Add discount if any
6. Preview invoice
7. Save and/or share with customer

---

## Competitive Advantages to Implement

1. **Offline-First Architecture**: Core features must work without internet
2. **Simplified UI**: Even non-tech-savvy users should navigate easily
3. **Quick Transaction Entry**: Minimize taps to record a transaction
4. **Automatic Calculations**: Real-time balance updates
5. **Multi-language Support**: At least Hindi, English initially
6. **Data Security**: Local encryption, secure backup
7. **WhatsApp Integration**: Leverage India's most popular messaging app
8. **Voice Input**: Consider voice-based transaction entry
9. **Smart Reminders**: AI-based optimal reminder timing
10. **Analytics Dashboard**: Visual insights into business health

---

## Development Phases (Recommended)

### Phase 1: MVP (Minimum Viable Product)
- Customer management (add, edit, view, delete)
- Basic transaction recording (You Gave/You Got)
- Balance calculation and display
- Transaction history per customer
- Basic PDF report generation
- SQLite database setup
- Material 3 UI implementation
- English language support

### Phase 2: Core Features
- Multiple business books
- Reminder system (WhatsApp/SMS)
- Advanced reports (P&L, Balance Sheet)
- Date range filters
- Search functionality
- Data backup and restore
- PIN/Password security
- Hindi language support

### Phase 3: Advanced Features
- Invoice generation with GST
- Inventory management
- Payment collection (UPI, QR codes)
- Business card generation
- Analytics dashboard
- Charts and graphs
- Photo attachments
- Additional language support

### Phase 4: Premium Features
- Cloud sync across devices
- Multi-user access
- Advanced analytics
- Automated payment reminders
- Integration with accounting software
- Expense tracking
- Staff/employee management

---

## Success Metrics

- **Usability**: Transaction entry within 10 seconds
- **Performance**: App launch under 2 seconds
- **Reliability**: Offline mode with 100% data integrity
- **Security**: Encrypted local storage
- **Accessibility**: Support for multiple languages
- **Data Safety**: Automatic backup mechanism

---

## References & Resources

- Khatabook Official: https://khatabook.com/
- Play Store: https://play.google.com/store/apps/details?id=com.vaibhavkalpe.android.khatabook
- Flutter Documentation: https://docs.flutter.dev/
- Material Design 3: https://m3.material.io/
- SQLite Best Practices: https://www.sqlite.org/bestpractice.html

---

**Document Version**: 1.0
**Last Updated**: November 15, 2025
**Research Compiled By**: Claude Code
**Target Platform**: Android (Flutter)
**Database**: SQLite3
**UI Framework**: Material Design 3
