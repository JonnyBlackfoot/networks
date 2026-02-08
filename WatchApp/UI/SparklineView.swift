import SwiftUI

public struct SparklineView: View {
    public let values: [Double]
    public let color: Color

    public init(values: [Double], color: Color = DesignTokens.accentPositive) {
        self.values = values
        self.color = color
    }

    public var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let minValue = values.min() ?? 0
            let maxValue = values.max() ?? 1
            let range = max(maxValue - minValue, 0.0001)

            Path { path in
                guard values.count > 1 else { return }
                for (index, value) in values.enumerated() {
                    let x = size.width * CGFloat(index) / CGFloat(values.count - 1)
                    let normalized = (value - minValue) / range
                    let y = size.height * (1 - CGFloat(normalized))
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(color, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
        }
        .accessibilityHidden(true)
    }
}
