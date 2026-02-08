import Foundation

public struct ImageCaption: Sendable {
    public let caption: String
    public let tags: [String]
}

public protocol CaptioningServiceProtocol {
    func captionImage(data: Data) async throws -> ImageCaption
}

public enum CaptioningServiceError: Error {
    case unavailable
}

public final class CaptioningService: CaptioningServiceProtocol {
    public init() {}

    public func captionImage(data: Data) async throws -> ImageCaption {
        // TODO: Call pluggable AI provider (e.g., Meta Llama API) from iPhone only.
        // Never store API keys in watchOS. Use Keychain or backend token exchange.
        throw CaptioningServiceError.unavailable
    }
}
