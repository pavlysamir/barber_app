# Barber Management App ✂️

A modern, robust Barber Management System built with Flutter and Firebase. This application follows the **MVVM architecture** with a **feature-based folder structure**, ensuring scalability and maintainability.

## 🚀 Features

### 🔐 Authentication
- **Role-Based Access**: Secure login for Admins and Employees.
- **Firebase Auth**: Robust email/password authentication.
- **Auto-Redirection**: Intelligent routing based on user role and auth state.

### 🧔 Employee Dashboard
- **Real-time Stats**: Daily revenue and customer count tracking.
- **Service Selection (POS)**: Intuitive interface for selecting services and recording transactions.
- **Live Transaction List**: Real-time updates of recent transactions via Firestore Streams.

### 👑 Admin Dashboard
- **Aggregate Reports**: Overview of daily revenue and performance across all employees.
- **Employee Monitoring**: View customer counts and totals per employee.
- **Detailed Audit**: Drill down into specific employee transactions, including services, pricing, and timestamps.
- **Daily Settlement**: "End Day" functionality to calculate totals and clear active lists for a fresh start.

## 🏗️ Technical Architecture

- **State Management**: `flutter_bloc` (Cubit) for predictable state transitions.
- **Dependency Injection**: `get_it` for clean service location.
- **Database**: `Cloud Firestore` for real-time document-based storage.
- **Responsiveness**: `flutter_screenutil` for a consistent experience across all devices.
- **UI/UX**: Modern design with **RTL (Arabic) support**, custom themes (Light/Dark), and Cairo typography.

## 📂 Project Structure

```text
lib/
├── core/               # Shared logic, themes, DI, and utilities
│   ├── di/             # Service locator (get_it)
│   ├── theme/          # App colors and theme data
│   └── utils/          # Constants and reusable widgets
└── features/           # Feature-based modules
    ├── auth/           # Login and session management
    ├── admin/          # Reporting and employee oversight
    └── employee/       # POS and dashboard for barbers
```

## 🛠️ Getting Started

### Prerequisites
- Flutter SDK (latest stable)
- Firebase Account

### Setup
1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   ```
2. **Install dependencies**:
   ```bash
   flutter pub get
   ```
3. **Firebase Configuration**:
   - Create a Firebase project.
   - Add Android/iOS apps.
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) and place them in their respective directories.
   - Or use the FlutterFire CLI:
     ```bash
     flutterfire configure
     ```

### Firestore Requirements
The Admin Dashboard requires a **Composite Index** for optimized queries.
- **Collection**: `transactions`
- **Fields**: `employeeId` (Ascending), `date` (Descending)

## 📄 License
This project is licensed under the MIT License.
# barber_app
