import Foundation
import WatchConnectivity

public enum WatchSyncServiceError: Error {
    case notReachable
}

public protocol WatchSyncServiceProtocol {
    func activate()
    func sendImages(_ images: [GlassesImage]) async throws
}

public final class WatchSyncService: NSObject, WatchSyncServiceProtocol {
    private let session: WCSession

    public init(session: WCSession = .default) {
        self.session = session
        super.init()
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
    }

    public func activate() {
        session.activate()
    }

    public func sendImages(_ images: [GlassesImage]) async throws {
        guard session.isReachable else { throw WatchSyncServiceError.notReachable }
        for image in images {
            // TODO: Serialize metadata + transfer file URLs via WCSession.transferFile
            let metadata: [String: Any] = [
                "id": image.id,
                "capturedAt": image.capturedAt.timeIntervalSince1970
            ]
            session.sendMessage(["image": metadata], replyHandler: nil, errorHandler: nil)
        }
    }
}

extension WatchSyncService: WCSessionDelegate {
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}

    public func sessionDidBecomeInactive(_ session: WCSession) {}

    public func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }

    public func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // TODO: handle sync requests from Watch
    }
}
