# Khatabook Clone - Project Architecture Document

## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Technology Stack](#technology-stack)
3. [Project Structure](#project-structure)
4. [Layer Architecture](#layer-architecture)
5. [State Management](#state-management)
6. [Database Layer](#database-layer)
7. [Feature Modules](#feature-modules)
8. [UI/UX Guidelines](#uiux-guidelines)
9. [Security Implementation](#security-implementation)
10. [Performance Optimization](#performance-optimization)
11. [Testing Strategy](#testing-strategy)
12. [Build & Deployment](#build--deployment)

---

## Architecture Overview

### Clean Architecture Principles

This project follows **Clean Architecture** pattern with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────┐
│                   Presentation Layer                     │
│   (UI, Widgets, State Management, View Models)          │
└──────────────────┬──────────────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────────────┐
│                   Domain Layer                           │
│   (Entities, Use Cases, Repository Interfaces)          │
└──────────────────┬──────────────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────────────┐
│                   Data Layer                             │
│   (Repository Implementations, Data Sources, Models)    │
└─────────────────────────────────────────────────────────┘
```

### Design Patterns Used

1. **Repository Pattern**: Abstraction layer between data sources and business logic
2. **Provider/Riverpod Pattern**: State management
3. **MVVM**: Model-View-ViewModel for UI layer
4. **Singleton**: Database instance, shared preferences
5. **Factory**: Creating database entities
6. **Observer**: State change notifications
7. **Strategy**: Different report generation strategies
8. **Dependency Injection**: Using GetIt or Riverpod

---

## Technology Stack

### Core Technologies

```yaml
Framework: Flutter 3.24+
Language: Dart 3.5+
Platform: Android (expandable to iOS)
Minimum SDK: Android 7.0 (API 24)
Target SDK: Android 14 (API 34)
```

### Key Packages

```yaml
dependencies:
  # State Management
  flutter_riverpod: ^2.5.1          # State management

  # Database
  sqflite: ^2.3.3                   # SQLite database
  path_provider: ^2.1.4             # File system paths
  path: ^1.9.0                      # Path manipulation

  # UI/UX
  material_design_icons_flutter: ^7.0.7296  # Icons
  google_fonts: ^6.2.1              # Custom fonts
  flutter_svg: ^2.0.10              # SVG support
  cached_network_image: ^3.4.1      # Image caching
  shimmer: ^3.0.0                   # Loading effects

  # Localization
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0                     # Internationalization

  # PDF & Reports
  pdf: ^3.11.1                      # PDF generation
  printing: ^5.13.2                 # PDF printing
  share_plus: ^10.0.3               # Share functionality

  # File & Media
  image_picker: ^1.1.2              # Camera/Gallery
  file_picker: ^8.1.2               # File selection
  permission_handler: ^11.3.1       # Runtime permissions

  # Communication
  url_launcher: ^6.3.1              # Open URLs, phone, SMS

  # Charts & Visualization
  fl_chart: ^0.69.0                 # Charts and graphs
  syncfusion_flutter_charts: ^27.1.58  # Advanced charts

  # Security
  flutter_secure_storage: ^9.2.2    # Secure storage
  local_auth: ^2.3.0                # Biometric auth
  encrypt: ^5.0.3                   # Encryption

  # Utilities
  shared_preferences: ^2.3.2        # Simple key-value storage
  connectivity_plus: ^6.0.5         # Network status
  device_info_plus: ^10.1.2         # Device information
  package_info_plus: ^8.0.2         # App information
  uuid: ^4.5.1                      # Unique ID generation

  # Date & Time
  intl: ^0.19.0                     # Date formatting
  timezone: ^0.9.4                  # Timezone handling

  # Functional Programming
  dartz: ^0.10.1                    # Functional programming (Either, Option)
  equatable: ^2.0.5                 # Value comparison

  # Logging & Debugging
  logger: ^2.4.0                    # Logging utility

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0             # Linting rules
  build_runner: ^2.4.13             # Code generation
  mockito: ^5.4.4                   # Mocking for tests
  integration_test:
    sdk: flutter
```

---

## Project Structure

```
lib/
├── main.dart                       # App entry point
├── app.dart                        # Root app widget
│
├── core/                           # Core utilities & shared code
│   ├── constants/
│   │   ├── app_constants.dart
│   │   ├── db_constants.dart
│   │   └── route_constants.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── colors.dart
│   │   └── text_styles.dart
│   ├── utils/
│   │   ├── date_utils.dart
│   │   ├── currency_utils.dart
│   │   ├── validation_utils.dart
│   │   └── pdf_utils.dart
│   ├── errors/
│   │   ├── failures.dart
│   │   └── exceptions.dart
│   ├── network/
│   │   └── network_info.dart
│   └── di/
│       └── injection.dart          # Dependency injection setup
│
├── data/                           # Data layer
│   ├── models/                     # Data models (JSON serializable)
│   │   ├── customer_model.dart
│   │   ├── transaction_model.dart
│   │   ├── invoice_model.dart
│   │   ├── item_model.dart
│   │   └── ...
│   ├── datasources/
│   │   ├── local/
│   │   │   ├── database/
│   │   │   │   ├── app_database.dart
│   │   │   │   ├── dao/
│   │   │   │   │   ├── customer_dao.dart
│   │   │   │   │   ├── transaction_dao.dart
│   │   │   │   │   ├── invoice_dao.dart
│   │   │   │   │   └── ...
│   │   │   │   └── migrations/
│   │   │   │       └── migration_v1.dart
│   │   │   └── preferences/
│   │   │       └── shared_prefs_service.dart
│   │   └── remote/                 # Future: API integration
│   │       └── api_service.dart
│   └── repositories/               # Repository implementations
│       ├── customer_repository_impl.dart
│       ├── transaction_repository_impl.dart
│       ├── invoice_repository_impl.dart
│       └── ...
│
├── domain/                         # Business logic layer
│   ├── entities/                   # Business entities
│   │   ├── customer.dart
│   │   ├── transaction.dart
│   │   ├── invoice.dart
│   │   ├── item.dart
│   │   └── ...
│   ├── repositories/               # Repository interfaces
│   │   ├── customer_repository.dart
│   │   ├── transaction_repository.dart
│   │   ├── invoice_repository.dart
│   │   └── ...
│   └── usecases/                   # Business use cases
│       ├── customer/
│       │   ├── add_customer.dart
│       │   ├── get_customers.dart
│       │   ├── update_customer.dart
│       │   └── delete_customer.dart
│       ├── transaction/
│       │   ├── add_transaction.dart
│       │   ├── get_transactions.dart
│       │   └── ...
│       ├── invoice/
│       │   ├── create_invoice.dart
│       │   ├── generate_invoice_pdf.dart
│       │   └── ...
│       └── reports/
│           ├── generate_ledger_report.dart
│           ├── generate_profit_loss.dart
│           └── ...
│
├── presentation/                   # UI layer
│   ├── screens/
│   │   ├── splash/
│   │   │   └── splash_screen.dart
│   │   ├── onboarding/
│   │   │   └── onboarding_screen.dart
│   │   ├── auth/
│   │   │   ├── pin_setup_screen.dart
│   │   │   └── pin_verify_screen.dart
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   └── widgets/
│   │   │       ├── summary_card.dart
│   │   │       ├── recent_transactions_list.dart
│   │   │       └── quick_action_buttons.dart
│   │   ├── customers/
│   │   │   ├── customer_list_screen.dart
│   │   │   ├── customer_detail_screen.dart
│   │   │   ├── add_customer_screen.dart
│   │   │   └── widgets/
│   │   ├── transactions/
│   │   │   ├── add_transaction_screen.dart
│   │   │   ├── transaction_detail_screen.dart
│   │   │   └── widgets/
│   │   ├── invoices/
│   │   │   ├── invoice_list_screen.dart
│   │   │   ├── create_invoice_screen.dart
│   │   │   ├── invoice_preview_screen.dart
│   │   │   └── widgets/
│   │   ├── reports/
│   │   │   ├── reports_screen.dart
│   │   │   ├── ledger_report_screen.dart
│   │   │   ├── profit_loss_screen.dart
│   │   │   └── widgets/
│   │   ├── inventory/
│   │   │   ├── items_list_screen.dart
│   │   │   ├── add_item_screen.dart
│   │   │   └── widgets/
│   │   ├── reminders/
│   │   │   ├── reminders_screen.dart
│   │   │   └── widgets/
│   │   ├── settings/
│   │   │   ├── settings_screen.dart
│   │   │   ├── business_settings_screen.dart
│   │   │   ├── backup_restore_screen.dart
│   │   │   └── widgets/
│   │   └── businesses/
│   │       ├── business_list_screen.dart
│   │       └── add_business_screen.dart
│   │
│   ├── providers/                  # Riverpod providers
│   │   ├── customer_provider.dart
│   │   ├── transaction_provider.dart
│   │   ├── invoice_provider.dart
│   │   ├── business_provider.dart
│   │   └── theme_provider.dart
│   │
│   ├── widgets/                    # Shared widgets
│   │   ├── common/
│   │   │   ├── app_button.dart
│   │   │   ├── app_text_field.dart
│   │   │   ├── loading_indicator.dart
│   │   │   ├── empty_state.dart
│   │   │   └── error_widget.dart
│   │   ├── customer/
│   │   │   ├── customer_card.dart
│   │   │   └── customer_avatar.dart
│   │   ├── transaction/
│   │   │   ├── transaction_item.dart
│   │   │   └── transaction_type_toggle.dart
│   │   └── charts/
│   │       ├── balance_chart.dart
│   │       └── transaction_trend_chart.dart
│   │
│   └── routes/
│       ├── app_router.dart
│       └── route_config.dart
│
├── l10n/                           # Localization files
│   ├── app_en.arb                  # English
│   ├── app_hi.arb                  # Hindi
│   └── ...
│
└── assets/                         # Static assets
    ├── images/
    ├── icons/
    └── fonts/
```

---

## Layer Architecture

### 1. Presentation Layer

**Responsibilities:**
- Display UI to user
- Handle user interactions
- Observe state changes
- Navigate between screens

**Components:**
- **Screens**: Full-page widgets
- **Widgets**: Reusable UI components
- **Providers**: State management (Riverpod)

**Example Flow:**
```dart
User Action → Screen → Provider → UseCase → Repository → Database
                ↓
            Update UI
```

### 2. Domain Layer

**Responsibilities:**
- Define business entities
- Implement business logic
- Define repository contracts
- Independent of frameworks

**Components:**
- **Entities**: Pure Dart classes representing business objects
- **Use Cases**: Single-responsibility business operations
- **Repository Interfaces**: Contracts for data access

**Example:**
```dart
// Entity
class Customer extends Equatable {
  final int? id;
  final String name;
  final String? phone;
  final double currentBalance;

  // Constructor, copyWith, props...
}

// Use Case
class AddCustomer {
  final CustomerRepository repository;

  Future<Either<Failure, Customer>> call(Customer customer) async {
    return await repository.addCustomer(customer);
  }
}
```

### 3. Data Layer

**Responsibilities:**
- Implement repository interfaces
- Manage data sources (local/remote)
- Data serialization/deserialization
- Caching strategies

**Components:**
- **Models**: Data transfer objects with JSON serialization
- **DAOs**: Database access objects
- **Repository Implementations**: Concrete implementations

**Example:**
```dart
// Model (extends Entity)
class CustomerModel extends Customer {
  CustomerModel({...}) : super(...);

  factory CustomerModel.fromJson(Map<String, dynamic> json) {...}
  Map<String, dynamic> toJson() {...}
  factory CustomerModel.fromEntity(Customer entity) {...}
}

// Repository Implementation
class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerDao dao;

  @override
  Future<Either<Failure, List<Customer>>> getCustomers() async {
    try {
      final models = await dao.getAllCustomers();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }
}
```

---

## State Management

### Riverpod Approach

**Provider Types:**
1. **Provider**: Immutable, cached values
2. **StateProvider**: Simple state
3. **StateNotifierProvider**: Complex state with immutability
4. **FutureProvider**: Async operations
5. **StreamProvider**: Stream data

**Example:**

```dart
// State Notifier
class CustomerNotifier extends StateNotifier<AsyncValue<List<Customer>>> {
  final GetCustomers _getCustomers;
  final AddCustomer _addCustomer;

  CustomerNotifier(this._getCustomers, this._addCustomer)
    : super(const AsyncValue.loading()) {
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    state = const AsyncValue.loading();
    final result = await _getCustomers();
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (customers) => AsyncValue.data(customers),
    );
  }

  Future<void> addCustomer(Customer customer) async {
    final result = await _addCustomer(customer);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) => loadCustomers(),
    );
  }
}

// Provider
final customerProvider = StateNotifierProvider<CustomerNotifier, AsyncValue<List<Customer>>>((ref) {
  final getCustomers = ref.read(getCustomersUseCaseProvider);
  final addCustomer = ref.read(addCustomerUseCaseProvider);
  return CustomerNotifier(getCustomers, addCustomer);
});

// Usage in Widget
class CustomerListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerState = ref.watch(customerProvider);

    return customerState.when(
      data: (customers) => ListView.builder(...),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => ErrorWidget(error),
    );
  }
}
```

---

## Database Layer

### SQLite Implementation

**Database Helper:**

```dart
class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  static Database? _database;

  factory AppDatabase() => _instance;
  AppDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = await getDatabasePath();
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Execute schema from DATABASE_SCHEMA.sql
    await db.execute(CREATE_BUSINESSES_TABLE);
    await db.execute(CREATE_CUSTOMERS_TABLE);
    // ... other tables
  }
}
```

**DAO Pattern:**

```dart
class CustomerDao {
  final AppDatabase _db;

  CustomerDao(this._db);

  Future<List<CustomerModel>> getAllCustomers({int? businessId}) async {
    final db = await _db.database;
    final maps = await db.query(
      'customers',
      where: businessId != null ? 'business_id = ? AND is_active = 1' : 'is_active = 1',
      whereArgs: businessId != null ? [businessId] : null,
      orderBy: 'name COLLATE NOCASE ASC',
    );
    return maps.map((map) => CustomerModel.fromJson(map)).toList();
  }

  Future<CustomerModel?> getCustomerById(int id) async {
    final db = await _db.database;
    final maps = await db.query(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return CustomerModel.fromJson(maps.first);
  }

  Future<int> insertCustomer(CustomerModel customer) async {
    final db = await _db.database;
    return await db.insert('customers', customer.toJson());
  }

  Future<int> updateCustomer(CustomerModel customer) async {
    final db = await _db.database;
    return await db.update(
      'customers',
      customer.toJson(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<int> deleteCustomer(int id) async {
    final db = await _db.database;
    return await db.update(
      'customers',
      {'is_active': 0, 'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
```

---

## Feature Modules

### Module 1: Customer Management

**Features:**
- Add/Edit/Delete customers
- View customer list with search and filters
- Customer detail with transaction history
- Balance tracking

**Key Screens:**
- `customer_list_screen.dart`
- `customer_detail_screen.dart`
- `add_customer_screen.dart`

### Module 2: Transaction Management

**Features:**
- Quick transaction entry (Credit/Debit)
- Transaction history
- Edit/Delete transactions
- Attachment support

**Key Screens:**
- `add_transaction_screen.dart`
- `transaction_detail_screen.dart`

### Module 3: Invoice & Billing

**Features:**
- Create GST/Non-GST invoices
- Invoice templates
- PDF generation
- Share via WhatsApp/Email

**Key Screens:**
- `create_invoice_screen.dart`
- `invoice_preview_screen.dart`
- `invoice_list_screen.dart`

### Module 4: Reports & Analytics

**Features:**
- Ledger reports
- Profit & Loss statement
- Balance sheet
- Transaction summary
- Charts and graphs

**Key Screens:**
- `reports_screen.dart`
- `ledger_report_screen.dart`
- `profit_loss_screen.dart`

### Module 5: Reminders

**Features:**
- Schedule payment reminders
- WhatsApp/SMS integration
- Recurring reminders
- Reminder history

**Key Screens:**
- `reminders_screen.dart`
- `add_reminder_screen.dart`

### Module 6: Inventory Management

**Features:**
- Add/Edit items/products
- Stock tracking
- Low stock alerts
- Item-wise reports

**Key Screens:**
- `items_list_screen.dart`
- `add_item_screen.dart`

---

## UI/UX Guidelines

### Material Design 3

**Color System:**
```dart
// Using Material 3 dynamic color
final colorScheme = ColorScheme.fromSeed(
  seedColor: const Color(0xFF1976D2), // Primary blue
  brightness: Brightness.light,
);

// Custom semantic colors
const successColor = Color(0xFF4CAF50);
const errorColor = Color(0xFFF44336);
const warningColor = Color(0xFFFF9800);
```

**Typography:**
```dart
final textTheme = Theme.of(context).textTheme;

// Display
displayLarge: GoogleFonts.roboto(fontSize: 57, fontWeight: FontWeight.w400)
displayMedium: GoogleFonts.roboto(fontSize: 45, fontWeight: FontWeight.w400)
displaySmall: GoogleFonts.roboto(fontSize: 36, fontWeight: FontWeight.w400)

// Headline
headlineLarge: GoogleFonts.roboto(fontSize: 32, fontWeight: FontWeight.w400)
headlineMedium: GoogleFonts.roboto(fontSize: 28, fontWeight: FontWeight.w400)
headlineSmall: GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.w400)

// Body
bodyLarge: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w400)
bodyMedium: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w400)
bodySmall: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w400)
```

**Component Usage:**
- **Cards**: Customer cards, summary cards
- **Lists**: Transaction lists, customer lists
- **FAB**: Primary actions (Add Customer, Add Transaction)
- **Bottom Nav**: Main navigation
- **Chips**: Filters, tags
- **Dialogs**: Confirmations, forms
- **Snackbars**: Feedback messages

### Responsive Design

```dart
// Breakpoints
const mobileBreakpoint = 600;
const tabletBreakpoint = 900;
const desktopBreakpoint = 1200;

// Usage
final screenWidth = MediaQuery.of(context).size.width;
final isMobile = screenWidth < mobileBreakpoint;
final isTablet = screenWidth >= mobileBreakpoint && screenWidth < desktopBreakpoint;
final isDesktop = screenWidth >= desktopBreakpoint;
```

---

## Security Implementation

### 1. PIN/Biometric Authentication

```dart
class AuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> authenticateWithBiometrics() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access Khatabook',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyPIN(String pin) async {
    final savedPin = await _getStoredPIN();
    return pin == savedPin;
  }
}
```

### 2. Secure Storage

```dart
class SecureStorageService {
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<void> savePIN(String pin) async {
    // Hash the PIN before storing
    final hashedPin = _hashPIN(pin);
    await _storage.write(key: 'user_pin', value: hashedPin);
  }

  Future<String?> getPIN() async {
    return await _storage.read(key: 'user_pin');
  }
}
```

### 3. Data Encryption

```dart
class EncryptionService {
  final key = Key.fromLength(32);
  final iv = IV.fromLength(16);
  final encrypter = Encrypter(AES(key));

  String encrypt(String plainText) {
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  }

  String decrypt(String encryptedText) {
    final encrypted = Encrypted.fromBase64(encryptedText);
    return encrypter.decrypt(encrypted, iv: iv);
  }
}
```

---

## Performance Optimization

### 1. Database Optimization

- **Indexing**: Index frequently queried columns
- **Batch Operations**: Use batch insert/update for multiple records
- **Pagination**: Load data in chunks
- **Lazy Loading**: Load detailed data only when needed

```dart
// Pagination example
Future<List<CustomerModel>> getCustomers({
  required int page,
  int pageSize = 20,
}) async {
  final db = await _db.database;
  final offset = (page - 1) * pageSize;

  final maps = await db.query(
    'customers',
    limit: pageSize,
    offset: offset,
    orderBy: 'name ASC',
  );

  return maps.map((m) => CustomerModel.fromJson(m)).toList();
}
```

### 2. UI Optimization

- **ListView.builder**: For long lists
- **Cached Network Images**: For profile images
- **Const Constructors**: For static widgets
- **Lazy Loading**: Load images on demand

### 3. State Management Optimization

- **Selective Rebuilds**: Use `select` in Riverpod
- **Memoization**: Cache computed values
- **Debouncing**: For search inputs

---

## Testing Strategy

### 1. Unit Tests

```dart
// Test use case
test('should add customer successfully', () async {
  // Arrange
  final customer = Customer(name: 'John Doe', phone: '9876543210');
  when(mockRepository.addCustomer(any))
      .thenAnswer((_) async => Right(customer));

  // Act
  final result = await addCustomerUseCase(customer);

  // Assert
  expect(result, Right(customer));
  verify(mockRepository.addCustomer(customer));
});
```

### 2. Widget Tests

```dart
testWidgets('CustomerCard displays customer name', (tester) async {
  // Arrange
  final customer = Customer(name: 'John Doe', currentBalance: 1000);

  // Act
  await tester.pumpWidget(
    MaterialApp(home: CustomerCard(customer: customer)),
  );

  // Assert
  expect(find.text('John Doe'), findsOneWidget);
});
```

### 3. Integration Tests

```dart
testWidgets('full customer flow', (tester) async {
  // 1. Open app
  // 2. Navigate to add customer
  // 3. Fill form
  // 4. Save
  // 5. Verify customer appears in list
});
```

---

## Build & Deployment

### Build Configuration

```yaml
# android/app/build.gradle
android {
    compileSdkVersion 34

    defaultConfig {
        applicationId "com.hisaab.khatabook"
        minSdkVersion 24
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### Release Checklist

- [ ] Update version in pubspec.yaml
- [ ] Update version code in build.gradle
- [ ] Run tests: `flutter test`
- [ ] Build APK: `flutter build apk --release`
- [ ] Build App Bundle: `flutter build appbundle --release`
- [ ] Test on multiple devices
- [ ] Update changelog
- [ ] Create Git tag
- [ ] Upload to Play Store

---

## Development Workflow

### Git Workflow

```bash
# Feature branch
git checkout -b feature/customer-management

# Commit
git commit -m "feat: add customer list screen"

# Push
git push origin feature/customer-management
```

### Commit Convention

```
feat: new feature
fix: bug fix
docs: documentation changes
style: code style changes
refactor: code refactoring
test: adding tests
chore: maintenance tasks
```

---

## Conclusion

This architecture provides:
- ✅ Scalability: Easy to add new features
- ✅ Maintainability: Clear separation of concerns
- ✅ Testability: Each layer can be tested independently
- ✅ Flexibility: Easy to swap implementations
- ✅ Performance: Optimized for mobile devices
- ✅ Security: Multiple layers of data protection

Follow this architecture consistently for a production-grade application.

---

**Document Version**: 1.0
**Last Updated**: November 15, 2025
**Author**: Claude Code
