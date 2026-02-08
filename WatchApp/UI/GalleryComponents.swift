import SwiftUI

public struct GalleryListRow: View {
    public let image: CachedImage

    public init(image: CachedImage) {
        self.image = image
    }

    public var body: some View {
        HStack(spacing: DesignTokens.spacingS) {
            RoundedRectangle(cornerRadius: 8)
                .fill(DesignTokens.surface)
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "photo")
                        .foregroundStyle(DesignTokens.textSecondary)
                )
            VStack(alignment: .leading, spacing: 2) {
                Text(image.capturedAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(DesignTokens.textPrimary)
                Text(image.location ?? "Unknown location")
                    .font(.caption2)
                    .foregroundStyle(DesignTokens.textSecondary)
            }
            Spacer()
            Text("NEW")
                .font(.caption2.weight(.bold))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(DesignTokens.accentPositive.opacity(0.2))
                .foregroundStyle(DesignTokens.accentPositive)
                .clipShape(Capsule())
        }
    }
}

public struct GalleryEmptyState: View {
    public let actionTitle: String
    public let action: () -> Void

    public init(actionTitle: String, action: @escaping () -> Void) {
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        VStack(spacing: DesignTokens.spacingM) {
            Image(systemName: "camera.on.rectangle")
                .font(.title2)
                .foregroundStyle(DesignTokens.textSecondary)
            Text("No recent images")
                .font(.headline)
                .foregroundStyle(DesignTokens.textPrimary)
            Text("Sync from iPhone to see your latest glasses captures.")
                .font(.caption2)
                .foregroundStyle(DesignTokens.textSecondary)
                .multilineTextAlignment(.center)
            Button(actionTitle) { action() }
                .buttonStyle(.bordered)
        }
        .padding()
    }
}

public struct GlassesImageViewer: View {
    public let image: CachedImage
    public let caption: String?
    public let tags: [String]

    public init(image: CachedImage, caption: String?, tags: [String]) {
        self.image = image
        self.caption = caption
        self.tags = tags
    }

    public var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 12)
                .fill(DesignTokens.surface)
                .overlay(
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundStyle(DesignTokens.textSecondary)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(image.capturedAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(DesignTokens.textSecondary)
                if let caption {
                    Text(caption)
                        .font(.headline)
                        .foregroundStyle(DesignTokens.textPrimary)
                }
                if !tags.isEmpty {
                    Text(tags.prefix(4).map { "#\($0)" }.joined(separator: " "))
                        .font(.caption2)
                        .foregroundStyle(DesignTokens.textSecondary)
                }
            }
            .padding(DesignTokens.spacingM)
            .background(.black.opacity(0.45))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .padding(DesignTokens.spacingS)
        }
        .accessibilityElement(children: .combine)
    }
}
