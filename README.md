# 🚗 Parkirin

<div align="center">

![Parkirin Logo](https://s11.gifyu.com/images/SOG6G.png)

[![Flutter Version](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

_Revolutionizing urban parking management with a seamless mobile solution_

[Features](#features) • [Getting Started](#getting-started) • [Architecture](#architecture) • [Contributing](#contributing)

</div>

## 🌟 Overview

Parkirin is a modern parking management application built with Flutter that connects drivers with parking attendants. It streamlines the parking experience through digital ticketing, automated payments, and a reward system.

### 🎯 Key Features

- **Dual User Roles**: Separate interfaces for drivers and parking attendants
- **Smart Authentication**: Phone number/OTP-based login with Google Sign-In option
- **Digital Ticketing**: Paperless parking ticket management
- **Reward System**: Points-based rewards for regular users
- **Offline Support**: Core functionality available without internet
- **Bilingual**: Full support for Indonesian and English
- **Theme Options**: Light and dark mode support

## 🚀 Getting Started

### Prerequisites

- Flutter 3.x
- Dart SDK >=3.0.0
- Android Studio / VS Code
- iOS Simulator / Android Emulator

### Installation

1. Clone the repository:

```bash
git clone https://github.com/muhammadpadanta/parkirin-flutter.git
```

2. Install dependencies:

```bash
cd parkirin
flutter pub get
```

3. Set up environment variables:

```bash
cp .env.example .env
```

4. Run the app:

```bash
flutter run
```

## 🏗️ Architecture

Parkirin follows Clean Architecture principles with a feature-first approach:

```
lib/
├── core/          # Core utilities and services
├── features/      # Feature modules
│   ├── authentication/
│   ├── vehicle_management/
│   ├── ticket_management/
│   └── ...
├── data/          # Data layer implementations
├── domain/        # Business logic and entities
└── presentation/  # UI components
```

### Design Principles

- **SOLID Principles**: Strict adherence to SOLID principles
- **Clean Architecture**: Clear separation of concerns
- **Feature-First**: Modular feature organization
- **Dependency Injection**: Loose coupling between components
- **Repository Pattern**: Abstract data sources
- **BLoC Pattern**: State management

## 🛠️ Tech Stack

- **Framework**: Flutter
- **State Management**: BLoC
- **Dependency Injection**: GetIt
- **Local Storage**: Hive
- **Network**: Dio
- **Authentication**: Firebase Auth
- **Testing**: Flutter Test

## 🔍 Core Features

### For Drivers

- Vehicle management with photo upload
- Digital parking ticket viewing
- Cashless payment options
- Points reward system
- Parking history tracking

### For Parking Attendants

- Quick ticket generation
- Real-time payment tracking
- Offline ticket management
- Location-based operations
- Daily transaction summary

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📱 Screenshots

<div align="center">

| Login Driver                                        | Login Parking Attendant                             | MORE coming soon...                   |
| --------------------------------------------------- | --------------------------------------------------- | ------------------------------------- |
| ![Screen 1](https://s11.gifyu.com/images/SOG8k.png) | ![Screen 2](https://s11.gifyu.com/images/SOG8n.png) | ![Screen 3](/api/placeholder/200/400) |

</div>

---

<div align="center">

Made with ❤️ by the Parkirin Team

</div>
