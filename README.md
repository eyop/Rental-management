
# Rental Management App 🏠

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-2.19%2B-blue.svg)](https://dart.dev)

A cross-platform mobile application for property management built with Flutter.

<p align="center">
  <img src="demo/app_demo.gif" width="300" alt="App Demo">
  <br>
  <em>Demo of key features</em>
</p>

## 📱 Features

**Property Management:**
- Add/Edit property listings with photos
- Track rental income and expenses
- Manage tenant information
- Lease agreement management
- Maintenance request system

**Tenant Features:**
- Mobile rent payments
- Document storage for contracts
- Maintenance request submission
- Payment history tracking
- Push notifications

**Admin Features:**
- Dashboard with financial overview
- Tenant communication portal
- Rent reminder system
- Expense reporting
- Multi-property support

## 🛠️ Tech Stack

- **Frontend:** Flutter (iOS & Android)
- **State Management:** Provider/Riverpod/Bloc (choose one)
- **Local Database:** Hive/SQFlite
- **Backend:** Firebase/Node.js (specify if applicable)
- **Payment Processing:** Stripe/Razorpay
- **File Storage:** Firebase Storage/Amazon S3

## 📦 Installation

1. **Prerequisites:**
   - Flutter SDK (3.0+)
   - Android Studio/Xcode
   - Dart SDK (2.19+)

2. Clone the repository:
```bash
git clone https://github.com/eyop/Rental-management.git
cd Rental-management
```

3. Install dependencies:
```bash
flutter pub get
```

4. Run the app:
```bash
flutter run
```

## 🚀 Getting Started

### Development Setup
1. Configure your environment variables in `lib/config/app_config.dart`
2. Connect to your backend service (Firebase/etc.)
3. Run in development mode:
```bash
flutter run --debug
```

### Build Releases
**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

## 📂 Project Structure
```
lib/
├── main.dart
├── models/
├── providers/
├── services/
├── utils/
├── views/
│   ├── auth/
│   ├── dashboard/
│   ├── properties/
│   └── tenants/
└── widgets/
```

## 🌐 API Integration (Example)
```dart
// Sample API call
Future<List<Property>> fetchProperties() async {
  final response = await http.get(
    Uri.parse('https://api.example.com/properties'),
    headers: {'Authorization': 'Bearer $token'},
  );
  
  return propertiesFromJson(response.body);
}
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch:
```bash
git checkout -b feature/awesome-feature
```
3. Commit changes:
```bash
git commit -m 'Add awesome feature'
```
4. Push to branch:
```bash
git push origin feature/awesome-feature
```
5. Create Pull Request

## 📄 License

MIT License - see [LICENSE](LICENSE) for details

