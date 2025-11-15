# Hisaab - Khatabook Clone

> A production-grade digital accounting ledger app for small and medium businesses, built with Flutter, SQLite3, and Material Design 3.

[![Flutter](https://img.shields.io/badge/Flutter-3.24+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.5+-0175C2?logo=dart)](https://dart.dev)
[![SQLite](https://img.shields.io/badge/SQLite-3-003B57?logo=sqlite)](https://www.sqlite.org/)
[![Material Design 3](https://img.shields.io/badge/Material-Design%203-757575?logo=material-design)](https://m3.material.io/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## 📋 Table of Contents

- [About](#about)
- [Features](#features)
- [Screenshots](#screenshots)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Getting Started](#getting-started)
- [Documentation](#documentation)
- [Development Roadmap](#development-roadmap)
- [Contributing](#contributing)
- [License](#license)

---

## 🎯 About

**Hisaab** is a comprehensive digital accounting solution inspired by India's popular Khatabook app. It helps small business owners, shopkeepers, and merchants manage their day-to-day transactions, customer ledgers, invoices, and business finances - all in one app.

### Why Hisaab?

- **100% Offline**: Works completely offline with local SQLite database
- **Simple & Intuitive**: Designed for users with minimal technical knowledge
- **Multi-language**: Support for English, Hindi, and other Indian languages
- **Production Ready**: Built with clean architecture and best practices
- **Secure**: PIN/Biometric authentication and encrypted storage
- **Free & Open Source**: No subscriptions, no hidden costs

---

## ✨ Features

### Core Features (MVP)

- ✅ **Customer Management**
  - Add, edit, and delete customers
  - Search and filter customers
  - View customer details and transaction history
  - Track outstanding balances

- ✅ **Transaction Tracking**
  - Quick transaction entry (Credit/Debit)
  - Automatic balance calculation
  - Transaction history with filters
  - Attach bills/receipts (photos)
  - Multiple payment modes (Cash, UPI, Card, etc.)

- ✅ **Home Dashboard**
  - Total receivable and payable summary
  - Recent transactions
  - Quick actions (Add customer, Record transaction)
  - Business health overview

### Advanced Features

- 📊 **Reports & Analytics**
  - Ledger reports (customer-wise)
  - Profit & Loss statement
  - Balance sheet
  - Daybook
  - Sales, Purchase, Expense reports
  - Export to PDF

- 🧾 **Invoicing & Billing**
  - Create GST/Non-GST invoices
  - Professional invoice templates
  - Item-wise billing
  - Automatic GST calculation
  - Share invoices via WhatsApp/Email

- 📦 **Inventory Management**
  - Add and manage items/products
  - Track stock levels
  - Low stock alerts
  - Item-wise profit tracking

- 🔔 **Reminders**
  - Schedule payment reminders
  - Send via WhatsApp/SMS
  - Recurring reminders
  - Automatic follow-ups

- 💼 **Multiple Business Books**
  - Manage multiple businesses
  - Switch between books
  - Business-wise data isolation

- 💰 **Expense Tracking**
  - Record business expenses
  - Categorize expenses
  - Expense reports
  - Expense analytics

- 🔒 **Security & Privacy**
  - PIN/Password protection
  - Biometric authentication (Fingerprint/Face)
  - Encrypted local storage
  - Auto-lock on minimize

- 💾 **Backup & Restore**
  - Automatic daily backup
  - Manual backup to local storage
  - Easy data restore
  - Export all data

- 🌍 **Localization**
  - Multi-language support (English, Hindi, etc.)
  - Regional date/currency formats
  - RTL support (future)

---

## 📱 Screenshots

> Coming soon

---

## 🛠 Tech Stack

### Framework & Language
- **Flutter** 3.24+ - Cross-platform UI framework
- **Dart** 3.5+ - Programming language

### Database
- **SQLite3** (via sqflite) - Local database
- **SharedPreferences** - Simple key-value storage
- **FlutterSecureStorage** - Secure credential storage

### State Management
- **Riverpod** - Reactive state management

### UI/UX
- **Material Design 3** - Modern UI components
- **Google Fonts** - Typography
- **FL Chart** - Data visualization

### PDF & Sharing
- **pdf** - PDF generation
- **printing** - PDF printing
- **share_plus** - Share functionality

### Security
- **local_auth** - Biometric authentication
- **encrypt** - Data encryption

### Utilities
- **intl** - Internationalization & date formatting
- **path_provider** - File system access
- **image_picker** - Camera/Gallery integration
- **url_launcher** - WhatsApp/SMS/Email integration

---

## 🏗 Architecture

This project follows **Clean Architecture** principles with clear separation of concerns:

```
┌─────────────────────────────────────┐
│     Presentation Layer              │
│  (UI, Widgets, State Management)    │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│     Domain Layer                    │
│  (Entities, Use Cases, Interfaces)  │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│     Data Layer                      │
│  (Repository Impl, Data Sources)    │
└─────────────────────────────────────┘
```

### Key Design Patterns

- **Repository Pattern**: Abstraction over data sources
- **Provider Pattern**: State management (Riverpod)
- **MVVM**: Model-View-ViewModel for UI
- **Dependency Injection**: Loose coupling
- **Factory Pattern**: Object creation
- **Observer Pattern**: State notifications

### Project Structure

```
lib/
├── core/               # Shared utilities, constants, theme
├── data/               # Models, DAOs, Repository implementations
├── domain/             # Entities, Use cases, Repository interfaces
├── presentation/       # UI screens, widgets, providers
└── l10n/               # Localization files
```

For detailed architecture, see [PROJECT_ARCHITECTURE.md](PROJECT_ARCHITECTURE.md)

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.24 or higher
- Dart SDK 3.5 or higher
- Android Studio / VS Code
- Android SDK (API 24+)
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/hisaab11.git
   cd hisaab11
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Check Flutter setup**
   ```bash
   flutter doctor
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Build for Release

**Build APK:**
```bash
flutter build apk --release
```

**Build App Bundle:**
```bash
flutter build appbundle --release
```

---

## 📚 Documentation

This project includes comprehensive documentation:

1. **[KHATABOOK_RESEARCH.md](KHATABOOK_RESEARCH.md)** - In-depth research on Khatabook app features, UI patterns, and functionality

2. **[DATABASE_SCHEMA.sql](DATABASE_SCHEMA.sql)** - Complete SQLite database schema with tables, indexes, triggers, and views

3. **[PROJECT_ARCHITECTURE.md](PROJECT_ARCHITECTURE.md)** - Detailed architecture guide, layer structure, state management, and best practices

4. **[IMPLEMENTATION_ROADMAP.md](IMPLEMENTATION_ROADMAP.md)** - Step-by-step implementation plan with phases, tasks, and timelines

### Quick Links

- **Features Overview**: [KHATABOOK_RESEARCH.md](KHATABOOK_RESEARCH.md#core-features--functionality)
- **Database Design**: [DATABASE_SCHEMA.sql](DATABASE_SCHEMA.sql)
- **UI/UX Guidelines**: [PROJECT_ARCHITECTURE.md](PROJECT_ARCHITECTURE.md#uiux-guidelines)
- **Development Phases**: [IMPLEMENTATION_ROADMAP.md](IMPLEMENTATION_ROADMAP.md#timeline-summary)

---

## 🗓 Development Roadmap

### Current Status: 📝 Planning & Research Phase

### Upcoming Milestones

- [ ] **Phase 1**: Project Setup & Foundation (Week 1)
- [ ] **Phase 2**: MVP - Customer & Transaction Management (Week 2-3)
- [ ] **Phase 3**: Reports & PDF Generation (Week 4)
- [ ] **Phase 4**: Invoice & Billing (Week 5)
- [ ] **Phase 5**: Advanced Features (Week 6)
- [ ] **Phase 6**: Settings & Security (Week 7)
- [ ] **Phase 7**: Localization & Polish (Week 8)
- [ ] **Phase 8**: Testing & QA (Week 9)
- [ ] **Phase 9**: Deployment Prep (Week 10)
- [ ] **Phase 10**: Launch (Week 11+)

**Estimated Timeline**: 10-12 weeks to production-ready v1.0

For detailed roadmap, see [IMPLEMENTATION_ROADMAP.md](IMPLEMENTATION_ROADMAP.md)

---

## 🧪 Testing

### Run Tests

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test

# Test coverage
flutter test --coverage
```

### Test Strategy

- **Unit Tests**: Business logic, use cases, repositories
- **Widget Tests**: UI components, user interactions
- **Integration Tests**: Complete user flows
- **Manual Testing**: Cross-device, cross-OS testing

Target: **>80% code coverage**

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Coding Standards

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `flutter analyze` before committing
- Write unit tests for new features
- Update documentation as needed

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- Inspired by [Khatabook](https://khatabook.com/) - India's leading digital accounting app
- Built with [Flutter](https://flutter.dev/) - Google's UI toolkit
- Uses [Material Design 3](https://m3.material.io/) - Latest Material Design system
- Database powered by [SQLite](https://www.sqlite.org/) - World's most used database engine

---

## 📞 Support

For questions, issues, or feature requests:

- **Issues**: [GitHub Issues](https://github.com/yourusername/hisaab11/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/hisaab11/discussions)
- **Email**: your.email@example.com

---

## 🌟 Star History

If you find this project useful, please consider giving it a star! ⭐

---

## 📊 Project Stats

- **Language**: Dart
- **Framework**: Flutter
- **Database**: SQLite3
- **Architecture**: Clean Architecture
- **State Management**: Riverpod
- **UI System**: Material Design 3
- **Target Platform**: Android (expandable to iOS)

---

**Made with ❤️ for small businesses across India**

---

## 🔮 Future Enhancements (Post v1.0)

- [ ] Cloud sync across devices
- [ ] iOS version
- [ ] Web dashboard
- [ ] API integration for online payments
- [ ] Advanced analytics with ML insights
- [ ] Multi-currency support
- [ ] Staff/employee management
- [ ] Integration with accounting software (Tally, etc.)
- [ ] Voice-based transaction entry
- [ ] OCR for bill scanning
- [ ] Barcode/QR code scanner for inventory

---

## 📈 Why This Project?

This project serves as:

1. **Learning Resource**: Demonstrates production-grade Flutter app development
2. **Portfolio Project**: Showcases clean architecture and best practices
3. **Business Solution**: Solves real-world accounting problems
4. **Open Source Contribution**: Helps other developers learn and contribute
5. **Community Impact**: Empowers small businesses with free accounting tools

---

**Current Version**: 0.1.0 (Planning Phase)
**Last Updated**: November 15, 2025
**Status**: 🚧 Under Active Development

---

