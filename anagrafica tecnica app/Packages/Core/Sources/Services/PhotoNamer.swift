import Foundation

public enum PhotoNamer {
    public static func makeFilename(
        scope: PhotoScope,
        ownerId: UUID,
        role: PhotoRole,
        fileExtension: String = "jpg",
        date: Date = Date()
    ) -> String {
        let ext = fileExtension.hasPrefix(".") ? String(fileExtension.dropFirst()) : fileExtension
        let timestamp = format(date: date)
        return "\(scope.rawValue.lowercased())_\(ownerId.uuidString)_\(role.rawValue.lowercased())_\(timestamp).\(ext)"
    }

    private static func format(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        return formatter.string(from: date)
    }
}
