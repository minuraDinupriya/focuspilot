# FocusPilot 🚀

[![Flutter CI](https://github.com/minuraDinupriya/focuspilot/actions/workflows/flutter_ci.yml/badge.svg)](https://github.com/minuraDinupriya/focuspilot/actions/workflows/flutter_ci.yml)
[![Flutter](https://img.shields.io/badge/Flutter-3.47.9-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13.7-0175C2?logo=dart)](https://dart.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Feature--First%20Clean%20Architecture-blueviolet)]()
[![Persistence](https://img.shields.io/badge/Storage-Drift%20SQLite%20(Offline--First)-4479A1?logo=sqlite)](https://drift.simonbinder.eu/)

FocusPilot is an **offline-first productivity and focus management mobile application** built with Flutter and Dart. Designed with Material 3 principles and enterprise-grade software architecture, it empowers users to organize daily workloads, track high-priority tasks, and maintain productive flow states without requiring internet connectivity.

---

## 🏛 Architecture Overview

FocusPilot is organized using **Feature-First Clean Architecture** principles to ensure strict separation of concerns, high testability, and long-term scalability.

```
lib/
├── app/                        # Global application scaffolding & dependency injection
│   ├── app.dart               # MultiRepositoryProvider, MultiBlocProvider & MaterialApp
│   └── app_shell.dart         # Material 3 NavigationBar and bottom navigation routing
└── features/
    ├── tasks/                 # Task Management Feature Module
    │   ├── domain/            # Core business logic (Pure Dart — Zero Flutter/DB dependencies)
    │   │   ├── models/        # Task entity (immutable, Equatable, copyWith) & TaskPriority enum
    │   │   └── repositories/  # Abstract TaskRepository interface (Contract)
    │   ├── data/              # Concrete storage and serialization
    │   │   ├── datasources/   # Drift SQLite database definition & generated schema
    │   │   └── repositories/  # TaskRepositoryImpl mapping DB rows to domain entities
    │   └── presentation/      # UI and State Management
    │       ├── controllers/   # TasksCubit and immutable TasksState
    │       ├── widgets/       # TaskItemTile, TaskFilterBar, AddTaskBottomSheet, TaskPriorityChip
    │       └── tasks_screen.dart # Material 3 screen handling Loading, Empty, Failure & Success
    ├── focus/                 # Pomodoro Focus Timer Feature Module
    └── today/                 # Daily Dashboard & Planning Feature Module
```

### Architectural Principles Applied

* **Dependency Inversion Principle (DIP):** The Presentation and Domain layers depend on abstract repository interfaces, not concrete database implementations.
* **Unidirectional Data Flow:** User actions trigger Cubit methods $\rightarrow$ SQLite database updates $\rightarrow$ Drift reactive streams emit fresh data $\rightarrow$ `BlocConsumer` renders updated UI widgets.
* **Test Isolation:** SQLite unit and widget tests use in-memory databases (`NativeDatabase.memory()`) and fake repositories, guaranteeing fast, non-flaky execution without touching physical storage.

---

## 🛠 Technology Stack

| Layer | Technology | Justification |
|---|---|---|
| **Framework** | **Flutter 3 (Material 3)** | Cross-platform native mobile performance with modern Material You dynamic styling. |
| **State Management** | **`flutter_bloc` (Cubit)** | Predictable, immutable state machine without the boilerplate of full Bloc events; ideal for CRUD operations. |
| **Local Database** | **`drift` (SQLite)** | Compile-time type-safe SQL queries with reactive stream listeners (`watchTasks()`) and relational schema support. |
| **Value Equality** | **`equatable`** | Value-based object comparison for states and entities without heavy code generation. |
| **Client Identifiers** | **`uuid`** | Generates v4 UUIDs client-side, enabling conflict-free offline task creation. |
| **CI / CD** | **GitHub Actions** | Automated cloud pipeline running format checks, static code analysis, and widget test suites on every pull request. |

---

## 🧪 Testing & Quality Standards

FocusPilot maintains strict quality gates verified both locally and via automated GitHub Actions CI:

* **Unit Tests:** Pure Dart validation of domain entities, factory constructors, copyWith immutability, and Cubit state transitions.
* **Database Integration Tests:** In-memory Drift SQLite tests verifying CRUD operations, queries, and stream emissions.
* **Widget Tests:** Verification of UI states (loading indicators, empty-state illustrations, task card interactions, and modal bottom sheets).

### Running Tests Locally

```bash
# 1. Check strict Dart formatting
dart format --output=none --set-exit-if-changed lib test

# 2. Run static code analyzer
flutter analyze

# 3. Run automated test suites
flutter test
```

---

## 🚀 Getting Started

### Prerequisites

* [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.47.9 or compatible)
* [Dart SDK](https://dart.dev/get-dart) (v3.13.7 or compatible)
* Android Studio / Android SDK with USB Debugging enabled

### Installation & Run

1. **Clone the repository:**
   ```bash
   git clone https://github.com/minuraDinupriya/focuspilot.git
   cd focuspilot
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate Drift SQLite code (if modifying database tables):**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Launch the application:**
   ```bash
   flutter run
   ```

---

## 📋 Engineering Workflow

* **Branching Strategy:** Feature branches branched from up-to-date `main` (`feature/FOC-<id>-<description>`).
* **Commit Standards:** [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `style:`, `docs:`, `test:`).
* **Code Review Ritual:** Self-review via GitHub diff, automated CI validation, and clean Pull Request squash-merging.
