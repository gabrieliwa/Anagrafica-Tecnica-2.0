import Foundation

public enum LocalFileCacheDirectory {
    case applicationSupport
    case caches
}

public enum LocalFileCacheError: Error {
    case missingBaseDirectory
}

public struct LocalFileCache {
    public let baseURL: URL
    private let fileManager: FileManager

    public init(
        baseDirectory: LocalFileCacheDirectory = .applicationSupport,
        folderName: String = "AnagraficaTecnica",
        fileManager: FileManager = .default
    ) throws {
        self.fileManager = fileManager
        let directory: FileManager.SearchPathDirectory = baseDirectory == .applicationSupport
            ? .applicationSupportDirectory
            : .cachesDirectory
        guard let root = fileManager.urls(for: directory, in: .userDomainMask).first else {
            throw LocalFileCacheError.missingBaseDirectory
        }
        baseURL = root.appendingPathComponent(folderName, isDirectory: true)
        try ensureDirectories()
    }

    public var photosURL: URL {
        baseURL.appendingPathComponent("photos", isDirectory: true)
    }

    public var tilesURL: URL {
        baseURL.appendingPathComponent("tiles", isDirectory: true)
    }

    public func ensureDirectories() throws {
        try fileManager.createDirectory(at: baseURL, withIntermediateDirectories: true, attributes: nil)
        try fileManager.createDirectory(at: photosURL, withIntermediateDirectories: true, attributes: nil)
        try fileManager.createDirectory(at: tilesURL, withIntermediateDirectories: true, attributes: nil)
    }

    public func urlForPhoto(filename: String) -> URL {
        photosURL.appendingPathComponent(filename)
    }

    public func urlForTile(path: String) -> URL {
        tilesURL.appendingPathComponent(path)
    }
}
