import SwiftUI

public struct MetricCard: View {
    public let title: String
    public let value: String
    public let unit: String?
    public let deltaText: String?
    public let deltaIsPositive: Bool?
    public let sparklineValues: [Double]
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(
        title: String,
        value: String,
        unit: String? = nil,
        deltaText: String? = nil,
        deltaIsPositive: Bool? = nil,
        sparklineValues: [Double] = []
    ) {
        self.title = title
        self.value = value
        self.unit = unit
        self.deltaText = deltaText
        self.deltaIsPositive = deltaIsPositive
        self.sparklineValues = sparklineValues
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.spacingS) {
            HStack(alignment: .firstTextBaseline, spacing: DesignTokens.spacingXS) {
                Text(value)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(DesignTokens.textPrimary)
                if let unit {
                    Text(unit)
                        .font(.caption2)
                        .foregroundStyle(DesignTokens.textSecondary)
                }
                Spacer()
                if let deltaText, let deltaIsPositive {
                    Text(deltaText)
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(deltaIsPositive ? DesignTokens.accentPositive.opacity(0.2) : DesignTokens.accentError.opacity(0.2))
                        .foregroundStyle(deltaIsPositive ? DesignTokens.accentPositive : DesignTokens.accentError)
                        .clipShape(Capsule())
                        .accessibilityLabel(deltaIsPositive ? "Improving" : "Declining")
                }
            }

            Text(title.uppercased())
                .font(.caption2)
                .foregroundStyle(DesignTokens.textSecondary)

            if !sparklineValues.isEmpty {
                SparklineView(values: sparklineValues)
                    .frame(height: 28)
                    .transition(.opacity)
            }
        }
        .padding(DesignTokens.spacingM)
        .background(DesignTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius, style: .continuous))
        .shadow(color: DesignTokens.shadow, radius: 3, x: 0, y: 2)
        .accessibilityElement(children: .combine)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: sparklineValues)
    }
}
