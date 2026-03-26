# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

iFinance is a personal finance management app with a gamification system (XP, levels, streaks, achievements). The UI is entirely in Traditional Chinese (Taiwan). It consists of an iOS SwiftUI app and a .NET backend API.

## Build & Run Commands

### iOS App
- **Build**: `xcodebuild -project iFinance.xcodeproj -scheme iFinance -sdk iphonesimulator build`
- **Run tests**: `xcodebuild -project iFinance.xcodeproj -scheme iFinance -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16' test`
- **Run single test**: `xcodebuild test -project iFinance.xcodeproj -scheme iFinance -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:iFinanceTests/TestClassName/testMethodName`

### .NET Server (in `server/`)
- **Run**: `cd server && dotnet run`
- **Build**: `cd server && dotnet build`
- Server runs on `http://localhost:5145` with SQLite database (`ifinance.db`, auto-created)

## Architecture

### iOS App (SwiftUI, iOS 17+)

**State management**: Single `AppStore` class using `@Observable` macro. Persists all data to UserDefaults as JSON. No external dependencies.

**Key flow**: `iFinanceApp` → `ContentView` (TabView) → three tabs:
- `HomeView` – transaction list, summary card, pony mascot (`PonyBuddyView`)
- `StatsView` – budget tracking with Charts framework pie chart
- `AchievementsView` – level/XP progression, achievement badges

**Data model** (`Models.swift`):
- `Transaction` – id, amount, type (income/expense), category, date, note
- `Category` – 13 expense + 3 income categories, each with icon and color
- `AchievementDef` – 11 achievements unlocked by milestones (transaction count, streaks, balance, level)

**Gamification** (`AppStore.swift`): Adding a transaction grants XP, updates streaks (consecutive-day tracking), checks level-up thresholds, and evaluates achievement unlock conditions.

### .NET Server (`server/`)

ASP.NET Core minimal API with Entity Framework Core + SQLite. Endpoints:
- `GET/POST /api/transactions` – list (with optional `?month=YYYY-MM` filter) and create
- `GET/PUT/DELETE /api/transactions/{id}` – single transaction CRUD
- `GET /api/summary` – monthly income/expense/balance stats

Models in `server/Models/Transaction.cs`, DB context in `server/Data/AppDbContext.cs`, all routes in `server/Program.cs`.

## Important Patterns

- The iOS app is currently offline-first with local persistence only; the server exists for future sync capability
- All user-facing strings are hardcoded in Traditional Chinese — maintain this when adding UI text
- `PonyBuddyView` is an animated mascot with context-aware messages based on financial state
- `CelebrationView` provides confetti animation triggered on transaction addition
- Test files exist but have only placeholder implementations
