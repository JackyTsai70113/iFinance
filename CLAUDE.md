# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

iFinance is a cross-platform personal finance management app with a gamification system (XP, levels, streaks, achievements). The UI is entirely in Traditional Chinese (Taiwan). It consists of a Flutter mobile app and a Python (FastAPI) backend API.

## Build & Run Commands

### Flutter App
- **Install dependencies**: `flutter pub get`
- **Run on device/emulator**: `flutter run`
- **Build Android APK**: `flutter build apk`
- **Build iOS**: `flutter build ios` (requires Mac + Xcode)
- **Run tests**: `flutter test`
- **Run single test**: `flutter test test/specific_test.dart`
- **Analyze code**: `flutter analyze`

### Python Server (in `server/`)
- **Install dependencies**: `cd server && pip install -r requirements.txt`
- **Run**: `cd server && python main.py` (or `uvicorn main:app --reload`)
- Server runs on `http://localhost:8000` with SQLite database (`ifinance.db`, auto-created)
- API docs available at `http://localhost:8000/docs` (Swagger UI)

## Architecture

### Flutter App (Dart, Material 3)

**State management**: `AppStore` class using `ChangeNotifier` + `Provider`. Persists all data to `SharedPreferences` as JSON. No external backend dependency.

**Structure**:
- `lib/main.dart` – app entry point, `MainScreen` with bottom `NavigationBar` (3 tabs)
- `lib/models/` – data classes: `Transaction`, `CategoryDef`, `AchievementDef`
- `lib/stores/app_store.dart` – centralized state, persistence, business logic
- `lib/views/` – full-screen pages: `HomeView`, `StatsView`, `AchievementsView`, `AddTransactionView`
- `lib/widgets/` – reusable components: `PonyBuddy` (animated mascot with CustomPainter)

**Key dependencies**: `provider`, `shared_preferences`, `fl_chart` (pie chart), `confetti_widget`, `uuid`, `intl`

**Gamification** (`app_store.dart`): Adding a transaction grants +10 XP, updates streaks (consecutive-day tracking), checks level-up thresholds, and evaluates achievement unlock conditions.

### Python Server (`server/`)

FastAPI with SQLAlchemy + SQLite. Endpoints:
- `GET/POST /api/transactions` -- list (with optional `?month=YYYY-MM` filter) and create
- `GET/PUT/DELETE /api/transactions/{id}` -- single transaction CRUD
- `GET /api/summary` -- monthly income/expense/balance stats

SQLAlchemy models in `server/models.py`, DB setup in `server/database.py`, all routes in `server/main.py`.

## Important Patterns

- The Flutter app is offline-first with local persistence only; the server exists for future sync capability
- All user-facing strings are hardcoded in Traditional Chinese — maintain this when adding UI text
- `PonyBuddy` widget uses `CustomPainter` to draw an animated pony mascot with context-aware messages
- Categories: 12 expense + 3 income, defined in `lib/models/category.dart`
- 11 achievements defined in `lib/models/achievement.dart`, unlocked by milestones
