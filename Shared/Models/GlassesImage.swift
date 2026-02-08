import Foundation
import CoreLocation

public struct GlassesImage: Identifiable, Sendable {
    public let id: String
    public let capturedAt: Date
    public let location: CLLocationCoordinate2D?
    public let thumbnailURL: URL?
    public let fullResURL: URL?
    public let caption: String?
    public let tags: [String]

    public init(
        id: String,
        capturedAt: Date,
        location: CLLocationCoordinate2D?,
        thumbnailURL: URL?,
        fullResURL: URL?,
        caption: String? = nil,
        tags: [String] = []
    ) {
        self.id = id
        self.capturedAt = capturedAt
        self.location = location
        self.thumbnailURL = thumbnailURL
        self.fullResURL = fullResURL
        self.caption = caption
        self.tags = tags
    }
}
