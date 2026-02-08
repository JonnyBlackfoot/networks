import Foundation
import SwiftUI
import UIKit

public struct CachedImage: Identifiable, Sendable {
    public let id: UUID
    public let filename: String
    public let thumbnailFilename: String
    public let capturedAt: Date
    public let location: String?

    public init(id: UUID = UUID(), filename: String, thumbnailFilename: String, capturedAt: Date, location: String?) {
        self.id = id
        self.filename = filename
        self.thumbnailFilename = thumbnailFilename
        self.capturedAt = capturedAt
        self.location = location
    }
}

public actor ImageCache {
    private let fileManager: FileManager
    private let cacheDirectory: URL
    private let maxItems: Int

    public init(
        fileManager: FileManager = .default,
        cacheDirectory: URL,
        maxItems: Int = 50
    ) {
        self.fileManager = fileManager
        self.cacheDirectory = cacheDirectory
        self.maxItems = maxItems
    }

    public func storeImageData(_ data: Data, thumbnail: Data, metadata: CachedImage) throws {
        try createDirectoryIfNeeded()
        let fullURL = cacheDirectory.appendingPathComponent(metadata.filename)
        let thumbURL = cacheDirectory.appendingPathComponent(metadata.thumbnailFilename)
        try data.write(to: fullURL, options: [.atomic])
        try thumbnail.write(to: thumbURL, options: [.atomic])
        try evictIfNeeded()
    }

    public func loadImage(named filename: String) -> Image? {
        let url = cacheDirectory.appendingPathComponent(filename)
        guard let data = try? Data(contentsOf: url), let uiImage = UIImage(data: data) else {
            return nil
        }
        return Image(uiImage: uiImage)
    }

    public func clearAll() throws {
        guard fileManager.fileExists(atPath: cacheDirectory.path) else { return }
        let contents = try fileManager.contentsOfDirectory(atPath: cacheDirectory.path)
        for item in contents {
            let url = cacheDirectory.appendingPathComponent(item)
            try fileManager.removeItem(at: url)
        }
    }

    private func createDirectoryIfNeeded() throws {
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }

    private func evictIfNeeded() throws {
        let files = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.contentModificationDateKey], options: [.skipsHiddenFiles])
        guard files.count > maxItems * 2 else { return }

        let sorted = files.sorted { first, second in
            let firstDate = (try? first.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
            let secondDate = (try? second.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
            return firstDate < secondDate
        }

        let removeCount = sorted.count - maxItems * 2
        for url in sorted.prefix(removeCount) {
            try fileManager.removeItem(at: url)
        }
    }
}
