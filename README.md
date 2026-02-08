# Apple Watch–First Fitness + Media Companion (Ray-Ban Meta)

## Feasibility + Constraints (Reality Checks)
- **Watch-only**: workout tracking, HealthKit metrics, local image gallery, and playback controls (via now-playing APIs) are feasible directly on watchOS.
- **Requires iPhone bridge**: Ray-Ban Meta glasses access must be done through iOS using Meta’s Wearables Device Access Toolkit (DAT) or Meta AI app import flows. watchOS cannot pair directly with the glasses using official SDKs.
- **Spotify**: playback control is feasible through Spotify Connect/Web API via iPhone OAuth. Offline downloads **must** be handled by Spotify’s own app. This app can only deep link and guide the user.
- **Privacy**: explicit permissions required for HealthKit, Location, Photos, Bluetooth, and Networking. Secrets live in Keychain (iOS), never in watchOS bundle.

## Architecture + Data Flow
```
[Ray-Ban Meta Glasses]
        |
        |  (Bluetooth + Meta DAT)
        v
[iPhone Companion App]
  - MetaBridgeService (DAT)
  - PhotoIngestService (PhotoKit fallback)
  - WatchSyncService (WCSession)
  - SpotifyAuthService (OAuth + Connect)
        |
        |  (WCSession messages/files)
        v
[Apple Watch App]
  - WorkoutEngine (HealthKit)
  - ImageCache (disk/memory)
  - SyncClient (WCSession)
  - UI (Glasses, Workouts, Music)

Optional Cloud Path (if watch is away from phone)
[iPhone] -> [CloudKit/Backend] -> [Watch]
```

## File Tree
```
.
├── README.md
├── docs
│   └── Permissions.md
├── Shared
│   ├── Models
│   │   └── GlassesImage.swift
│   └── Services
│       └── AI
│           └── CaptioningService.swift
├── WatchApp
│   ├── Images
│   │   └── ImageCache.swift
│   ├── Sync
│   │   └── WatchSyncClient.swift
│   ├── UI
│   │   ├── AppShellView.swift
│   │   ├── DesignSystem.swift
│   │   ├── GalleryComponents.swift
│   │   ├── GlassesGalleryView.swift
│   │   ├── MetricCard.swift
│   │   ├── SparklineView.swift
│   │   └── WorkoutControlBar.swift
│   └── Workout
│       └── WorkoutEngine.swift
└── iOSApp
    ├── Meta
    │   └── MetaBridgeService.swift
    ├── Photos
    │   └── PhotoIngestService.swift
    ├── Spotify
    │   └── SpotifyAuthService.swift
    └── Sync
        └── WatchSyncService.swift
```

## Design Tokens (Watch UI)
| Token | Value |
| --- | --- |
| background | #000000 |
| surface | #1F1F1F |
| textPrimary | #FFFFFF |
| textSecondary | #B3B3B3 |
| accentPositive | #33FF66 |
| accentWarning | #FFB233 |
| accentError | #FF594C |
| cornerRadius | 14 |
| spacing scale | 4 / 8 / 12 / 16 |
| shadow | black @ 30% opacity |

## SwiftUI Examples (Watch-first, Dark Mode)
### MetricCard + Sparkline
```swift
MetricCard(
    title: "Heart Rate",
    value: "152",
    unit: "BPM",
    deltaText: "+3%",
    deltaIsPositive: true,
    sparklineValues: [140, 144, 147, 150, 152]
)
```

### Tab Layout (Workout / Glasses / Music)
```swift
TabView {
    WorkoutTabView().tabItem { Label("Workout", systemImage: "figure.run") }
    GlassesTabView().tabItem { Label("Glasses", systemImage: "photo.on.rectangle") }
    MusicTabView().tabItem { Label("Music", systemImage: "music.note") }
}
.tint(DesignTokens.accentPositive)
.preferredColorScheme(.dark)
```

### Dark Mode Default
```swift
AppShellView()
    .preferredColorScheme(.dark)
```

## Key Code Skeletons (Swift)

### watchOS: HealthKit Workout Engine
See `WatchApp/Workout/WorkoutEngine.swift`.

### watchOS: WatchConnectivity Sync Client
See `WatchApp/Sync/WatchSyncClient.swift`.

### watchOS: Image Cache
See `WatchApp/Images/ImageCache.swift`.

### watchOS: Design System + Components
See `WatchApp/UI/DesignSystem.swift`, `WatchApp/UI/MetricCard.swift`, `WatchApp/UI/WorkoutControlBar.swift`, and `WatchApp/UI/SparklineView.swift`.

### iOS: Meta DAT Integration Stub
See `iOSApp/Meta/MetaBridgeService.swift`.

### iOS: PhotoKit Fallback Ingest
See `iOSApp/Photos/PhotoIngestService.swift`.

### iOS: Spotify OAuth + Connect Stub
See `iOSApp/Spotify/SpotifyAuthService.swift`.

### Shared: Models + AI Captioning Interface
See `Shared/Models/GlassesImage.swift` and `Shared/Services/AI/CaptioningService.swift`.

## Required Entitlements + Info.plist Keys
See `docs/Permissions.md` for detailed keys and suggested strings.

## How to Run (Xcode)
1. Open an Xcode workspace and add two targets: watchOS app + iOS companion app.
2. Add the Swift files from this repo to their respective targets.
3. Enable capabilities: HealthKit, Background Modes (workout processing, location updates), App Groups (optional), and iCloud (optional for CloudKit).
4. On iPhone target, configure URL Types for Spotify OAuth redirect.
5. Build and run the iOS app on a real iPhone; then run the watch app on a paired Apple Watch.

## Real-Device Test Plan
- **HealthKit**: start a running workout, verify live metrics and summary.
- **Location**: ensure route points are recorded and displayed in the summary.
- **Glasses sync**: trigger “Sync now” and confirm new images appear on Watch.
- **Offline mode**: open gallery with phone disconnected; verify cache behavior.
- **Spotify**: complete OAuth on iPhone, then verify playback control on Watch.

## Next Iterations
- Live preview thumbnail stream (when DAT supports it).
- GPX export + route overlays in iOS companion.
- On-device AI captioning on iPhone (Core ML), with pluggable providers.
- Advanced workout overlays (grade-adjusted pace, heatmaps).
