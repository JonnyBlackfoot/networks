import Foundation
import Photos

public enum PhotoIngestError: Error {
    case authorizationDenied
}

public protocol PhotoIngestServiceProtocol {
    func requestAuthorization() async throws
    func fetchRecentGlassesImages(limit: Int) async throws -> [GlassesImage]
}

public final class PhotoIngestService: PhotoIngestServiceProtocol {
    public init() {}

    public func requestAuthorization() async throws {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        if status == .authorized || status == .limited { return }

        let result = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        guard result == .authorized || result == .limited else {
            throw PhotoIngestError.authorizationDenied
        }
    }

    public func fetchRecentGlassesImages(limit: Int) async throws -> [GlassesImage] {
        let options = PHFetchOptions()
        options.fetchLimit = limit
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        // TODO: Narrow to a dedicated album or metadata marker used by Meta AI import flows.
        let results = PHAsset.fetchAssets(with: .image, options: options)
        var output: [GlassesImage] = []

        results.enumerateObjects { asset, _, _ in
            let image = GlassesImage(
                id: asset.localIdentifier,
                capturedAt: asset.creationDate ?? Date(),
                location: asset.location?.coordinate,
                thumbnailURL: nil,
                fullResURL: nil
            )
            output.append(image)
        }

        return output
    }
}
