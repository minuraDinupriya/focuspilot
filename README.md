# FocusPilot 🚀

[![Flutter CI](https://github.com/minuraDinupriya/focuspilot/actions/workflows/flutter_ci.yml/badge.svg)](https://github.com/minuraDinupriya/focuspilot/actions/workflows/flutter_ci.yml)
[![Flutter CD](https://github.com/minuraDinupriya/focuspilot/actions/workflows/flutter_cd.yml/badge.svg)](https://github.com/minuraDinupriya/focuspilot/actions/workflows/flutter_cd.yml)
[![Latest Release](https://img.shields.io/github/v/release/minuraDinupriya/focuspilot?color=2E7D32&label=Release&logo=github)](https://github.com/minuraDinupriya/focuspilot/releases)
[![Flutter](https://img.shields.io/badge/Flutter-3.47.9-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13.7-0175C2?logo=dart)](https://dart.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Feature--First%20Clean%20Architecture-blueviolet)]()
[![Persistence](https://img.shields.io/badge/Storage-Drift%20SQLite%20(Offline--First)-4479A1?logo=sqlite)](https://drift.simonbinder.eu/)
[![Tests](https://img.shields.io/badge/Tests-54%20Passing%20(100%25)-success?logo=checkmarx)]()

FocusPilot is a production-grade, **offline-first productivity and focus management mobile application** built with Flutter and Dart. Designed with Material 3 design principles and enterprise software engineering patterns, it empowers knowledge workers, students, and professionals to organize workloads, track high-priority tasks, enter deep focus sessions, and visualize productivity trends — completely offline with zero tracking or account mandates.

---

## 🌟 Key Features

* **🎯 Today Productivity Dashboard**
  * **Daily Goal Ring:** Visualizes progress toward daily focus targets with dynamic percentage completion.
  * **Summary Metrics:** Live counters for focus minutes, completed sessions, and daily task throughput.
  * **Weekly Analytics Chart:** 7-day focus distribution bar chart highlighting productivity trends and current streak.
  * **Direct Task Execution Bridge:** Tap any high-priority task from the dashboard to launch directly into a dedicated focus session.

* **⏱️ Pomodoro Focus Engine**
  * **Countdown & State Machine:** Robust timer state machine (`Work`, `Short Break`, `Long Break`) with pause, resume, and skip controls.
  * **Task Linking:** Bind any pending task directly to an active timer session for targeted deep work.
  * **Audio & Haptic Feedback:** High-fidelity tactile haptics and completion chime on session wrap-up.
  * **Session Persistence:** Completed sessions are saved directly into SQLite for historical analytics.

* **📋 Task Management System**
  * **Priority Matrix:** Filter and organize tasks by priority (`High`, `Medium`, `Low`).
  * **Status Lifecycle:** Seamlessly toggle between pending and completed states with instant reactive UI updates.
  * **Bottom Sheet Creation:** Fast, ergonomic task entry with title, description, and priority tags.

* **⚙️ User Settings & Customization**
  * Configurable work durations (15 to 60 minutes).
  * Customizable short and long break intervals.
  * Persistent user preferences via settings repository.

* **🛡️ Enterprise Observability & Resilience**
  * **Bloc State Observer:** Centralized logging of all BLoC/Cubit state transitions and error events.
  * **Global Error Boundary:** Polite fallback view preventing white screens or unexpected app crashes.
  * **Platform Dispatcher Hook:** Catches asynchronous unhandled Dart errors gracefully.

---

## 🏛 Clean Architecture Overview

FocusPilot is organized using **Feature-First Clean Architecture** principles to ensure strict separation of concerns, high testability, and long-term scalability.

```
lib/
├── app/                              # Global application scaffolding & setup
│   ├── app.dart                     # Dependency Injection: MultiRepositoryProvider & MultiBlocProvider
│   ├── app_shell.dart               # Material 3 NavigationBar & top app bar
│   ├── app_bloc_observer.dart       # Observability: Logs state transitions and unhandled bloc errors
│   └── global_error_view.dart       # UI Error Boundary fallback screen
├── features/
│   ├── today/                       # Daily Dashboard & Analytics Feature Module
│   │   ├── presentation/
│   │   │   ├── controllers/         # TodayCubit & TodayState
│   │   │   ├── widgets/             # DailyGoalRing, WeeklyAnalyticsChart, MetricCardsRow, QuickStartCard
│   │   │   └── today_screen.dart    # Dashboard root view
│   ├── focus/                       # Pomodoro Focus Timer Feature Module
│   │   ├── domain/                  # Pure Dart models (FocusSession, FocusMode, Ticker) & Repository contracts
│   │   ├── data/                    # Drift SQLite FocusSessions table & FocusSessionRepositoryImpl
│   │   └── presentation/            # FocusBloc, FocusTimerDisplay, ModeSelector, TaskLinkerSheet
│   ├── tasks/                       # Task Management Feature Module
│   │   ├── domain/                  # Task entity, TaskPriority enum, TaskRepository contract
│   │   ├── data/                    # Drift SQLite Tasks table & TaskRepositoryImpl
│   │   └── presentation/            # TasksCubit, TaskItemTile, AddTaskBottomSheet, TaskFilterBar
│   └── settings/                    # User Configuration Feature Module
│       ├── domain/                  # UserSettings entity & SettingsRepository contract
│       ├── data/                    # InMemorySettingsRepository
│       └── presentation/            # SettingsCubit & SettingsSheet modal
```

### Architectural Principles Applied

* **Dependency Inversion Principle (DIP):** Presentation and Domain layers depend only on abstract repository interfaces (`TaskRepository`, `FocusSessionRepository`, `SettingsRepository`), never concrete database drivers.
* **Unidirectional Data Flow:** User actions trigger Cubit/Bloc events $\rightarrow$ Repository executes SQLite operations $\rightarrow$ Drift reactive streams emit updated datasets $\rightarrow$ UI re-renders predictably.
* **Hermetic Test Isolation:** Database tests run against in-memory SQLite instances (`NativeDatabase.memory()`), ensuring zero disk pollution, instant execution, and zero flakiness.

---

## 🛠 Technology Stack

| Layer | Technology | Engineering Purpose |
|---|---|---|
| **Framework** | **Flutter 3 (Material 3)** | Cross-platform native mobile performance with Material You dynamic color styling. |
| **State Management** | **`flutter_bloc` (BLoC & Cubit)** | Predictable, event-driven state machine for the timer; lightweight Cubits for CRUD features. |
| **Local Database** | **`drift` (SQLite)** | Compile-time type-safe relational SQL queries with reactive stream listeners. |
| **Value Equality** | **`equatable`** | Structural equality comparisons for states and domain entities without code generation. |
| **Feedback Engine** | **`audioplayers` & `HapticFeedback`** | Tactile and audible reinforcement when focus intervals complete. |
| **Client Identifiers** | **`uuid`** | Generates v4 UUIDs client-side, enabling conflict-free offline item creation. |
| **CI / CD Pipeline** | **GitHub Actions** | Automated formatting, static analysis, coverage generation, and cloud APK release compilation. |

---

## 🧪 Testing & Quality Standards

FocusPilot adheres to strict production test standards verified both locally and via automated CI:

* **Unit Tests:** Pure Dart tests validating business logic, ticker countdown streams, repository contracts, and state transitions.
* **Database Integration Tests:** In-memory SQLite tests validating schema constraints, queries, and stream updates.
* **Widget & Navigation Tests:** Full widget rendering, bottom sheet interactions, tap gestures, and screen navigation.

```bash
# 1. Verify strict Dart formatting
dart format --output=none --set-exit-if-changed lib test

# 2. Run static code analyzer
flutter analyze

# 3. Run full automated test suite with code coverage export
flutter test --coverage
```

---

## 🚀 Getting Started

### Prerequisites

* [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.24.0+ or compatible)
* [Dart SDK](https://dart.dev/get-dart) (v3.5.0+ or compatible)
* Android Studio / Android SDK with USB Debugging enabled (for running on physical hardware)

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

3. **Generate Drift SQLite code (if modifying database schemas):**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run on connected device / emulator:**
   ```bash
   flutter run
   ```

---

## 🔄 DevOps, CI & Automated Continuous Delivery (CD)

FocusPilot follows modern Agile / Scrum engineering practices:

* **Trunk-Based Git Workflow:** Short-lived feature branches (`feature/FOC-<id>-<description>`) merged into `main` via Pull Requests.
* **Automated CI Quality Gate (`.github/workflows/flutter_ci.yml`):**
  * Enforces `dart format` compliance.
  * Enforces zero-warning `flutter analyze`.
  * Runs all 54 tests and generates `lcov.info` code coverage artifact.
* **Automated CD Release Pipeline (`.github/workflows/flutter_cd.yml`):**
  * Pushing a semver tag (e.g. `git tag v1.0.0 && git push origin v1.0.0`) automatically compiles a release APK on Ubuntu runners and publishes it as a downloadable GitHub Release asset.
* **PR Templates:** Structured checklist requiring Jira ticket links, manual testing verification, and test coverage validation prior to merging.
