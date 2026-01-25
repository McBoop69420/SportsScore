# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SportsScore is a native macOS application (SwiftUI, Swift 5.9, macOS 14.0+) that displays live sports scores across 18 leagues in 8 sports. Features both a main window and menu bar widget.

## Build Commands

```bash
# Generate Xcode project from project.yml (uses XCGen)
xcodegen

# Build
xcodebuild -scheme SportsScores build

# Build release
xcodebuild -scheme SportsScores build -configuration Release
```

## Architecture

**MVVM with Service Layer:**

- **ScoresViewModel** (`ViewModels/ScoresViewModel.swift`): Central state management using Combine's `@Published` properties. Handles filtering, auto-refresh scheduling (15s-5m configurable), and league persistence via `@AppStorage`.

- **SportsDataService** (`Services/SportsDataService.swift`): Actor-based singleton for thread-safe ESPN API access. Uses `TaskGroup` to fetch multiple leagues in parallel.

- **Models** (`Models/`): `Game`, `Team`, `GameStatus` enums, `Sport`/`League` enums with ESPN API mappings, `ESPNScoreboardResponse` for API parsing.

- **Views**: Split between `MainWindow/` (NavigationSplitView with sidebar/list/detail) and `MenuBar/` (compact widget).

## Data Flow

1. App launches → `ScoresViewModel.startAutoRefresh()` begins polling
2. `SportsDataService.fetchScores(for: leagues)` hits ESPN API endpoints
3. `ESPNScoreboardResponse.toGames()` transforms API response to `Game` models
4. `@Published games` triggers SwiftUI updates
5. `filteredGames` computed property applies sport/league/search filters

## ESPN API

- **Endpoint pattern**: `https://site.api.espn.com/apis/site/v2/sports/{sport}/{league}/scoreboard`
- **League mappings**: Defined in `League.espnSport` and `League.espnLeague` properties

## Adding a New League

1. Add case to `League` enum in `Models/Sport.swift`
2. Add to parent sport's `leagues` array in `Sport` enum
3. Implement `displayName`, `espnSport`, `espnLeague` in League switch statements
4. Update `sport` computed property to return correct parent sport

## Key Types

- `Game.isLive`, `isUpcoming`, `isCompleted` - status checks used throughout UI
- `GameStatus` - maps ESPN status codes (STATUS_IN_PROGRESS, STATUS_FINAL, etc.)
- `Team.displayColor` - handles dark color detection with automatic fallback
