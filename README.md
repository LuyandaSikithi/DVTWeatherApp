# DVTWeather

An iOS weather application built with SwiftUI demonstrating Clean Architecture, offline-first design, and modern Swift concurrency.

---

## Using the App

### Installation & First Launch

1. Clone the repo and open `WeatherApp.xcodeproj` in Xcode 16+
2. Select an iPhone simulator (iPhone 15 or later recommended) or a physical device
3. Press **⌘R** to build and run
4. On first launch iOS will ask for location permission — tap **Allow While Using App**
5. The Weather tab loads your current location's weather automatically

> **Simulator tip:** set a simulated location via **Features → Location → Apple** (or any city preset) before running, otherwise the location request will time out.

---

### Weather Tab

Displays live weather for your **current GPS location**.

| Element | Description |
|---------|-------------|
| Background image | Changes between forest scenes based on condition (sunny / cloudy / rainy) |
| Temperature | Large centred figure in the top image area |
| Condition name | Uppercase label below the temperature (e.g. SUNNY, CLOUDY, RAINY) |
| Condition icon | Top-right corner of the image area |
| Min / Current / Max | Three-column stats strip below the image |
| 5-day forecast | One row per day showing the day name, condition icon, and high temperature |

**Offline mode:** if the device has no network connection the app loads the last cached response and shows a banner — *"Last updated: 28 May, 14:32"* — at the top of the screen.

---

### Favourites Tab

Displays a list of all locations you have saved, each showing live weather data.

| Action | How |
|--------|-----|
| View weather detail | Tap any row to open a full weather screen for that location |
| Delete a favourite | Swipe the row left → tap **Delete** |
| Search existing favourites | Type in the search bar at the top to filter by city name |

> To **add** a new location use the **Map tab** (see below).

---

### Map Tab — Adding Locations to Favourites

The Map tab is where you search for cities and save them as favourites.

**Step-by-step: adding a location**

1. Tap the **Map** tab (bottom navigation)
2. Type a city name in the **Search city…** bar at the top of the map
3. Tap the **Search** button (or press **Return** on the keyboard)
4. The map animates to the city and drops a **purple pin** on it
5. A card appears at the bottom of the screen showing the city name
6. Tap **Add ★** — the location is saved to your favourites
7. The purple pin becomes an **orange pin** and the card dismisses

**Other map features**

| Element | Description |
|---------|-------------|
| Orange pins | Your saved favourite locations |
| Blue dot | Your current GPS location |
| Tap an orange pin | Shows a callout with the location name, temperature, and condition |
| ✕ on the search card | Dismiss the search result without saving |
| Deleted favourite | Switch to Map tab after deleting — the pin disappears immediately |

---

## Architecture

The app follows **Clean Architecture** layered with **MVVM** in the Presentation tier.

```
DVTWeather/
├── App/              Entry point, DI container, tab root view
├── Core/
│   ├── Network/      URLSession wrapper, OpenWeatherMap API client
│   ├── Location/     CLLocationManager wrapped in async/await
│   ├── Persistence/  CoreData stack (offline cache)
│   └── Extensions/   Date, Double helpers
├── Domain/
│   ├── Models/       Value-type domain models (Sendable structs)
│   ├── Repositories/ Protocol-only boundary definitions
│   └── UseCases/     Single-responsibility business logic units
├── Data/
│   ├── Remote/       API response DTOs + mappers
│   └── (Local)       CoreData NSManagedObject subclasses live in Core/Persistence
└── Presentation/
    ├── Weather/       CCWeatherViewModel + CCWeatherView
    ├── Favourites/    CCFavouritesViewModel + CCFavouritesView
    ├── Map/           CCMapViewModel + CCMapView
    └── Shared/        CCThemeManager, CCOfflineBannerView
```

### Key architectural decisions

**Dependency Inversion (SOLID-D):** Every ViewModel depends on protocol abstractions (`CCWeatherRepositoryProtocol`, `CCFavouritesRepositoryProtocol`), never on concrete implementations. Swapping the remote data source for a mock requires zero changes to the ViewModel.

**Use Cases as Single-Responsibility units:** Each use case wraps exactly one operation (`CCGetCurrentWeatherUseCase`, `CCGetForecastUseCase`, etc.). This makes them trivially testable in isolation with a mock repository.

**Offline-first via CoreData:** `CCWeatherRepository` writes to CoreData after every successful network call. On failure, `CCGetOfflineWeatherUseCase` reads the cached entry and the UI surfaces `CCOfflineBannerView` with a "Last updated" timestamp.

**`@Observable` + singleton ViewModels:** ViewModels are created once via `CCDependencyContainer` and survive tab switches. This prevents Swift's structured concurrency from cancelling in-flight `CheckedContinuation` calls when a view is temporarily removed from the hierarchy.

**`CCLocationService` auth flow:** The service checks `authorizationStatus` before calling `requestLocation()`. If `.notDetermined`, it calls `requestWhenInUseAuthorization()` and suspends on a `CheckedContinuation` until `locationManagerDidChangeAuthorization` fires. This prevents `kCLErrorDenied` caused by calling `requestLocation()` before the user responds to the permission dialog.

### Binding & Observation — no third-party reactive libraries

All ViewModel-to-View binding uses Apple's **Observation framework** (`@Observable` macro, introduced in Swift 5.9 / iOS 17). This is Apple's modern replacement for the older `ObservableObject` + `@Published` + `AnyCancellable` Combine pattern.

| Mechanism | Framework | Third-party? |
|-----------|-----------|--------------|
| `@Observable` on ViewModels | Swift Observation (part of Swift stdlib) | No |
| `@Bindable` for two-way bindings | SwiftUI | No |
| `@State`, `@Environment` | SwiftUI | No |

**Why `@Observable` over Combine:**

- **Less boilerplate:** No `@Published`, no `AnyCancellable` storage, no `sink` subscriptions to manage or cancel.
- **Granular invalidation:** SwiftUI re-renders only the views that access the specific property that changed. `ObservableObject` invalidates the entire view tree on any `@Published` change.
- **Not a third-party tool:** The Observation framework ships as part of Swift itself — it carries zero external dependencies.
- **Combine is available** for composing async event streams when needed; `@Observable` covers all synchronous UI binding in this project.

No RxSwift, ReactiveSwift, Bond, or any other third-party reactive / binding library is used in this project.

---

## Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| Classes / Structs / Enums | `CC` prefix + PascalCase | `CCWeatherViewModel` |
| Instance variables | `m_` prefix + camelCase | `m_temperature`, `m_cityName` |
| Files | PascalCase matching primary type | `CCWeatherView.swift` |
| CoreData entities | `CD` prefix | `CDWeatherCache`, `CDFavouriteLocation` |
| Protocols | `CC` prefix + `Protocol` suffix | `CCWeatherRepositoryProtocol` |

---

## Third-Party Packages

| Package | Source | Purpose |
|---------|--------|---------|
| [Swinject](https://github.com/Swinject/Swinject) `≥ 2.9.0` | SPM (declared) | Dependency Injection container. Declared as an XCRemoteSwiftPackageReference in the project file so it appears in Xcode's Package Dependencies panel. DI is currently handled by the hand-rolled `CCDependencyContainer` — see **Why manual DI** below for the migration path. |
| [SwiftLint](https://github.com/realm/SwiftLint) | Homebrew | Static code analysis. Configured via `.swiftlint.yml` and wired as an Xcode **Run Script build phase** — runs automatically on every build. Install with `brew install swiftlint`. |
| CoreData | Apple built-in | Offline persistence for weather cache and favourite locations. |
| CoreLocation | Apple built-in | Device location access wrapped in Swift async/await via `CheckedContinuation`. |
| MapKit | Apple built-in | Native map view with city search (`MKLocalSearch`), custom annotation pins for favourite locations, and current-location marker. |
| SwiftUI Observation (`@Observable`) | Apple built-in (Swift 5.9) | ViewModel-to-View binding. Ships with Swift — not a third-party dependency. |

> **No third-party UI, reactive, or binding libraries are used.** All views are custom SwiftUI components; all binding is handled by Apple's Observation framework.

---

## Build Instructions

### 1. Prerequisites

| Tool | Version | Notes |
|------|---------|-------|
| Xcode | 16+ (built with 26.0.1) | Download from the Mac App Store |
| iOS SDK | 26+ | Included with Xcode |
| SwiftLint | Any | `brew install swiftlint` — optional, build warns if missing |

### 2. Clone the repository

```bash
git clone <repo-url>
cd WeatherApp
```

### 3. API Key Setup

The app ships with fallback API keys in `App/CCAPIConfig.swift` so it runs out of the box. To use your own keys:

```bash
cp Config/Secrets.xcconfig.example Config/Secrets.xcconfig
```

Then edit `Config/Secrets.xcconfig`:

```
WEATHER_API_KEY = <your OpenWeatherMap key>
PLACES_API_KEY  = <your Google Places key>
```

> `Secrets.xcconfig` is **gitignored** and must never be committed.

### 4. Open in Xcode

```bash
open WeatherApp.xcodeproj
```

### 5. Resolve SPM Packages _(optional)_

`File → Packages → Resolve Package Versions` — fetches the declared Swinject package. The app builds and runs without it since DI is handled by `CCDependencyContainer`.

### 6. Select a target

Choose any **iPhone simulator** (iPhone 15 or later) or a physical device running iOS 17+.

For the simulator, set a location before running:
**Features → Location → Apple** (or any city preset)

### 7. Build & Run

Press **⌘R** or click the Run button.

Grant the **location permission** prompt on first launch — the Weather tab needs it to show your current location's weather.

---

## Branching Strategy

```
main          ← stable, tagged releases only
develop       ← integration branch; all feature PRs target here
feature/*     ← e.g. feature/weather-screen, feature/offline-cache
bugfix/*      ← e.g. bugfix/location-denied-error
release/*     ← e.g. release/1.0.0 — branched from develop, merged to main + develop
```

- Feature branches are opened as PRs against `develop`
- `develop → main` PRs are opened for each release
- `main` is never committed to directly

---

## CI/CD

GitHub Actions (`.github/workflows/ci.yml`) triggers on every push and every PR targeting `main`:

1. Checkout code
2. Select Xcode version
3. Copy `Secrets.xcconfig.example → Secrets.xcconfig` (placeholder keys for CI)
4. `xcodebuild build` — verifies the project compiles
5. `xcodebuild test` — runs the unit test suite with code coverage enabled
6. `swiftlint lint --reporter github-actions-logging` — surfaces lint violations as PR annotations

---

## Testing

```
WeatherAppTests/
├── Mocks/        CCMockWeatherRepository, CCMockFavouritesRepository, stub helpers
├── UseCases/     CCGetCurrentWeatherUseCaseTests, CCGetForecastUseCaseTests, CCFavouritesUseCaseTests
└── ViewModels/   CCWeatherViewModelTests (state machine: idle → loading → loaded / offline / error)
```

All use cases are tested in isolation against mock repositories. ViewModel tests verify full state transitions without touching the network or CoreData.

Target: **80%+ code coverage** measured via Xcode's built-in coverage report.

---

## Additional Notes

### Swift concurrency approach

The project targets Swift 5.9 with `SWIFT_APPROACHABLE_CONCURRENCY = YES` and `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`. This means:

- All types are implicitly `@MainActor`-isolated unless marked `nonisolated` or declared as `actor`
- `URLSession.data(from:)` suspends the main-actor task but does not block the main thread — iOS handles the actual I/O off-thread
- `CLLocationManagerDelegate` methods are marked `nonisolated` and hop back to `@MainActor` via `Task { @MainActor in ... }`
- `CheckedContinuation` is used (not `UnsafeContinuation`) to get runtime leak detection during development

### Why manual DI over Swinject right now

`CCDependencyContainer` mirrors Swinject's registration/resolution pattern (`lazy var` properties act as singletons). Migrating to Swinject requires:

1. Resolving the SPM package
2. Replacing `lazy var m_X = ...` with `container.register(...).inObjectScope(.container)`
3. Replacing `m_container.m_X` call sites with `container.resolve(CCXType.self)`

The architecture is deliberately structured so this migration touches only `CCDependencyContainer.swift`.

### Offline behaviour

`CCWeatherRepository.fetchCurrentWeather` always writes to CoreData after a successful response. On any network error, `CCWeatherViewModel` falls back to `CCGetOfflineWeatherUseCase` which reads `CDWeatherCache`. The cached `timestamp` is surfaced in `CCOfflineBannerView` as "Last updated: 28 May, 14:32".

### Background theming

`CCThemeManager` maps a `CCWeatherCondition` to two values: a background image name (`forest_sunny`, `forest_cloudy`, `forest_rainy`) and a fallback `Color` (`WeatherSunny` #47AB2F, `WeatherCloudy` #54717A, `WeatherRainy` #57575D). The background images and all condition icons (`clear`, `partlysunny`, `rain`) are committed to `Assets.xcassets`. The full-screen layout places the forest image in the top ~45% of the screen with the temperature and condition name centred over it; the stats and forecast rows beneath use the matching theme colour as their background.

### City search — MKLocalSearch over Google Places

Favourite locations are added via the **Map tab** using Apple's `MKLocalSearch` (part of MapKit — no API key required). The search resolves the city name and coordinates from Apple Maps and saves them to CoreData via `CCSaveFavouriteUseCase`. `CCPlacesSearchService` (Google Places Autocomplete) remains in the codebase for the Favourites tab search bar but is not the primary path for adding new locations.

### Map pin sync

`CCMapViewModel.refreshFavourites()` is called on every `onAppear` of the Map tab. This means pins are always in sync with CoreData — adding or deleting a favourite on the Favourites tab is immediately reflected on the map the next time the Map tab is opened, with no app restart required.

---

## Known Limitations

- Swinject is declared as an SPM dependency but not yet imported in Swift code — DI is provided by `CCDependencyContainer` (migration path documented above)
- Hourly forecast detail view not implemented
- Push notifications for weather alerts not implemented
- The simulator requires a simulated location set via **Features → Location → Apple** (or any preset)
