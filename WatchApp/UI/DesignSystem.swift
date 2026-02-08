import SwiftUI

public enum DesignTokens {
    public static let background = Color.black
    public static let surface = Color(white: 0.12)
    public static let textPrimary = Color.white
    public static let textSecondary = Color(white: 0.7)
    public static let accentPositive = Color(red: 0.2, green: 1.0, blue: 0.4)
    public static let accentWarning = Color(red: 1.0, green: 0.7, blue: 0.2)
    public static let accentError = Color(red: 1.0, green: 0.35, blue: 0.3)

    public static let cornerRadius: CGFloat = 14
    public static let spacingXS: CGFloat = 4
    public static let spacingS: CGFloat = 8
    public static let spacingM: CGFloat = 12
    public static let spacingL: CGFloat = 16
    public static let shadow = Color.black.opacity(0.3)
}

public enum StatusLevel {
    case healthy
    case warning
    case error

    public var color: Color {
        switch self {
        case .healthy: return DesignTokens.accentPositive
        case .warning: return DesignTokens.accentWarning
        case .error: return DesignTokens.accentError
        }
    }

    public var iconName: String {
        switch self {
        case .healthy: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .error: return "xmark.octagon.fill"
        }
    }
}

public struct StatusPill: View {
    public let title: String
    public let subtitle: String?
    public let level: StatusLevel

    public init(title: String, subtitle: String?, level: StatusLevel) {
        self.title = title
        self.subtitle = subtitle
        self.level = level
    }

    public var body: some View {
        HStack(spacing: DesignTokens.spacingS) {
            Image(systemName: level.iconName)
                .foregroundStyle(level.color)
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(DesignTokens.textPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(DesignTokens.textSecondary)
                }
            }
        }
        .padding(.vertical, DesignTokens.spacingXS)
        .padding(.horizontal, DesignTokens.spacingM)
        .background(DesignTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius, style: .continuous))
        .shadow(color: DesignTokens.shadow, radius: 2, x: 0, y: 1)
    }
}
