import Foundation

public enum SpotifyAuthError: Error {
    case missingClientId
    case authorizationFailed
    case tokenExpired
}

public struct SpotifyToken: Sendable {
    public let accessToken: String
    public let refreshToken: String
    public let expiresAt: Date
}

public protocol SpotifyAuthServiceProtocol {
    func startAuthorization() async throws -> URL
    func handleRedirect(url: URL) async throws -> SpotifyToken
    func refreshIfNeeded(token: SpotifyToken) async throws -> SpotifyToken
    func sendPlaybackCommand(_ command: SpotifyPlaybackCommand) async throws
}

public enum SpotifyPlaybackCommand: String {
    case play
    case pause
    case nextTrack
    case previousTrack
    case setVolume
}

public final class SpotifyAuthService: SpotifyAuthServiceProtocol {
    private let clientId: String
    private let redirectURI: String

    public init(clientId: String, redirectURI: String) {
        self.clientId = clientId
        self.redirectURI = redirectURI
    }

    public func startAuthorization() async throws -> URL {
        guard !clientId.isEmpty else { throw SpotifyAuthError.missingClientId }
        // TODO: Build Spotify OAuth URL with scopes: user-read-playback-state, user-modify-playback-state.
        let urlString = "https://accounts.spotify.com/authorize"
        guard let url = URL(string: urlString) else { throw SpotifyAuthError.authorizationFailed }
        return url
    }

    public func handleRedirect(url: URL) async throws -> SpotifyToken {
        // TODO: Exchange authorization code for token via Spotify Accounts API.
        throw SpotifyAuthError.authorizationFailed
    }

    public func refreshIfNeeded(token: SpotifyToken) async throws -> SpotifyToken {
        if token.expiresAt > Date() { return token }
        // TODO: Refresh token via Spotify Accounts API.
        throw SpotifyAuthError.tokenExpired
    }

    public func sendPlaybackCommand(_ command: SpotifyPlaybackCommand) async throws {
        // TODO: Use Spotify Web API (Connect) to control playback on user-selected device.
        // NOTE: Offline downloads must be handled by the Spotify app. Provide deep links only.
    }
}
