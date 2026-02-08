import SwiftUI

public struct AppShellView: View {
    public init() {}

    public var body: some View {
        TabView {
            WorkoutTabView()
                .tabItem { Label("Workout", systemImage: "figure.run") }
            GlassesTabView()
                .tabItem { Label("Glasses", systemImage: "photo.on.rectangle") }
            MusicTabView()
                .tabItem { Label("Music", systemImage: "music.note") }
        }
        .tint(DesignTokens.accentPositive)
        .preferredColorScheme(.dark)
    }
}

private struct WorkoutTabView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: DesignTokens.spacingM) {
                MetricCard(
                    title: "Heart Rate",
                    value: "152",
                    unit: "BPM",
                    deltaText: "+3%",
                    deltaIsPositive: true,
                    sparklineValues: [140, 144, 147, 150, 152]
                )

                WorkoutControlBar(
                    state: .running,
                    onStart: {},
                    onPause: {},
                    onResume: {},
                    onStop: {}
                )
            }
            .padding()
        }
        .background(DesignTokens.background)
        .navigationTitle("Workout")
    }
}

private struct GlassesTabView: View {
    var body: some View {
        VStack(spacing: DesignTokens.spacingM) {
            StatusPill(title: "Synced", subtitle: "2 min ago", level: .healthy)
            GalleryEmptyState(actionTitle: "Sync from iPhone") {}
        }
        .padding()
        .background(DesignTokens.background)
        .navigationTitle("Glasses")
    }
}

private struct MusicTabView: View {
    var body: some View {
        VStack(spacing: DesignTokens.spacingM) {
            MetricCard(title: "Now Playing", value: "Trail Mix", unit: nil)
            StatusPill(title: "Spotify Connected", subtitle: "On iPhone", level: .healthy)
        }
        .padding()
        .background(DesignTokens.background)
        .navigationTitle("Music")
    }
}
