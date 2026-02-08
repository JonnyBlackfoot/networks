import Foundation
import WatchConnectivity

public enum WatchSyncError: Error {
    case notReachable
    case invalidPayload
}

public struct SyncStatus: Sendable {
    public var lastSync: Date?
    public var isSyncing: Bool

    public init(lastSync: Date? = nil, isSyncing: Bool = false) {
        self.lastSync = lastSync
        self.isSyncing = isSyncing
    }
}

public protocol WatchSyncClientProtocol: AnyObject {
    var status: SyncStatus { get }
    func requestLatestImages() async throws
}

public final class WatchSyncClient: NSObject, WatchSyncClientProtocol {
    private let session: WCSession
    public private(set) var status = SyncStatus()

    public init(session: WCSession = .default) {
        self.session = session
        super.init()
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
    }

    public func requestLatestImages() async throws {
        guard session.isReachable else { throw WatchSyncError.notReachable }
        status.isSyncing = true
        try await withCheckedThrowingContinuation { continuation in
            session.sendMessage(["command": "syncLatestImages"], replyHandler: { _ in
                self.status.lastSync = Date()
                self.status.isSyncing = false
                continuation.resume()
            }, errorHandler: { error in
                self.status.isSyncing = false
                continuation.resume(throwing: error)
            })
        }
    }
}

extension WatchSyncClient: WCSessionDelegate {
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}

    public func sessionReachabilityDidChange(_ session: WCSession) {
        // TODO: surface reachability changes to UI
    }

    public func session(_ session: WCSession, didReceive file: WCSessionFile) {
        // TODO: forward file to ImageCache
    }

    public func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // TODO: handle metadata updates
    }
}
