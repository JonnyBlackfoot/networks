import SwiftUI

public enum WorkoutControlState {
    case idle
    case running
    case paused
}

public struct WorkoutControlBar: View {
    public let state: WorkoutControlState
    public let onStart: () -> Void
    public let onPause: () -> Void
    public let onResume: () -> Void
    public let onStop: () -> Void

    public init(
        state: WorkoutControlState,
        onStart: @escaping () -> Void,
        onPause: @escaping () -> Void,
        onResume: @escaping () -> Void,
        onStop: @escaping () -> Void
    ) {
        self.state = state
        self.onStart = onStart
        self.onPause = onPause
        self.onResume = onResume
        self.onStop = onStop
    }

    public var body: some View {
        HStack(spacing: DesignTokens.spacingM) {
            switch state {
            case .idle:
                ControlButton(label: "Start", systemImage: "play.fill", color: DesignTokens.accentPositive, action: onStart)
            case .running:
                ControlButton(label: "Pause", systemImage: "pause.fill", color: DesignTokens.accentWarning, action: onPause)
                ControlButton(label: "Stop", systemImage: "stop.fill", color: DesignTokens.accentError, action: onStop, requiresConfirmation: true)
            case .paused:
                ControlButton(label: "Resume", systemImage: "play.fill", color: DesignTokens.accentPositive, action: onResume)
                ControlButton(label: "Stop", systemImage: "stop.fill", color: DesignTokens.accentError, action: onStop, requiresConfirmation: true)
            }
        }
        .buttonStyle(.plain)
        .padding(.vertical, DesignTokens.spacingS)
    }
}

private struct ControlButton: View {
    let label: String
    let systemImage: String
    let color: Color
    let action: () -> Void
    var requiresConfirmation = false

    @State private var showConfirmation = false

    var body: some View {
        Button {
            if requiresConfirmation {
                showConfirmation = true
                WKInterfaceDevice.current().play(.click)
            } else {
                action()
                WKInterfaceDevice.current().play(.success)
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.headline)
                Text(label)
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignTokens.spacingS)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius, style: .continuous))
        }
        .confirmationDialog("End workout?", isPresented: $showConfirmation, titleVisibility: .visible) {
            Button("Stop", role: .destructive) {
                action()
                WKInterfaceDevice.current().play(.failure)
            }
            Button("Cancel", role: .cancel) {}
        }
        .accessibilityHint(requiresConfirmation ? "Requires confirmation" : "")
    }
}
