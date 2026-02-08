# Permissions, Entitlements, and Privacy Strings

## HealthKit (watchOS + iOS)
- **Capability**: HealthKit
- **Info.plist**:
  - `NSHealthShareUsageDescription`: "Read your heart rate, distance, and workout data to track outdoor activities."
  - `NSHealthUpdateUsageDescription`: "Save completed workouts to Health to keep your training history in one place."

## Location (watchOS + iOS)
- **Capability**: Location updates / Workout processing
- **Info.plist**:
  - `NSLocationWhenInUseUsageDescription`: "Use your location to map routes and calculate distance and pace."
  - `NSLocationAlwaysAndWhenInUseUsageDescription`: "Allow background location during workouts to record routes accurately."

## Photos (iOS fallback ingest)
- **Info.plist**:
  - `NSPhotoLibraryUsageDescription`: "Import recent images from your Meta glasses to show on Apple Watch."
  - `NSPhotoLibraryAddUsageDescription`: "Save annotated images or exports when you choose to share."

## Bluetooth (iOS Meta DAT)
- **Info.plist**:
  - `NSBluetoothAlwaysUsageDescription`: "Connect to your Meta glasses to sync images."

## Local Network / Networking (Optional)
- **Info.plist**:
  - `NSLocalNetworkUsageDescription`: "Discover devices on your network to sync images."
  - `NSAppTransportSecurity` with `NSAllowsArbitraryLoads` set to `false` (default), add exceptions only if required.

## iCloud (Optional CloudKit)
- **Capability**: iCloud with CloudKit container
- **Privacy**: explain that images are uploaded only when the user enables cloud sync.

## Background Modes (iOS)
- **Capabilities**: Background fetch, Remote notifications (optional), Location updates (if required for sync).

## WatchConnectivity
- **No explicit entitlement** required, but ensure both targets are part of the same app group if sharing files.
