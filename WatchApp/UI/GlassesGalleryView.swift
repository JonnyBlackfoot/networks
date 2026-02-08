import SwiftUI

public struct GlassesGalleryView: View {
    public let images: [CachedImage]
    public let lastSync: Date?
    public let syncAction: () async -> Void

    public init(images: [CachedImage], lastSync: Date?, syncAction: @escaping () async -> Void) {
        self.images = images
        self.lastSync = lastSync
        self.syncAction = syncAction
    }

    public var body: some View {
        List {
            Section {
                Button("Sync Now") {
                    Task { await syncAction() }
                }
                if let lastSync {
                    StatusPill(
                        title: "Synced",
                        subtitle: lastSync.formatted(date: .abbreviated, time: .shortened),
                        level: .healthy
                    )
                } else {
                    StatusPill(title: "Not synced", subtitle: "Connect iPhone", level: .warning)
                }
            }

            Section("Recent") {
                if images.isEmpty {
                    GalleryEmptyState(actionTitle: "Sync from iPhone") {
                        Task { await syncAction() }
                    }
                } else {
                    ForEach(images) { image in
                        NavigationLink {
                            GlassesImageDetailView(image: image)
                        } label: {
                            GalleryListRow(image: image)
                        }
                    }
                }
            }
        }
        .listStyle(.carousel)
        .navigationTitle("Glasses")
        .background(DesignTokens.background)
    }
}

public struct GlassesImageDetailView: View {
    public let image: CachedImage

    public var body: some View {
        VStack(spacing: DesignTokens.spacingM) {
            GlassesImageViewer(image: image, caption: "Summit view", tags: ["trail", "ridge", "sunset"])
                .frame(height: 160)
            Text(image.capturedAt.formatted(date: .abbreviated, time: .shortened))
                .font(.headline)
                .foregroundStyle(DesignTokens.textPrimary)
            if let location = image.location {
                Text(location)
                    .font(.footnote)
                    .foregroundStyle(DesignTokens.textSecondary)
            }
            Spacer()
        }
        .padding()
        .background(DesignTokens.background)
    }
}
