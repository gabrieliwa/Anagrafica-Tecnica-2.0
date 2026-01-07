import CryptoKit
import Foundation

public enum StableID {
    public static func uuid() -> UUID {
        UUID()
    }

    public static func fromString(_ value: String, namespace: String) -> UUID {
        if let uuid = UUID(uuidString: value) {
            return uuid
        }
        let namespaced = namespace.isEmpty ? value : "\(namespace):\(value)"
        let digest = SHA256.hash(data: Data(namespaced.utf8))
        return uuidFromDigest(digest)
    }

    private static func uuidFromDigest(_ digest: SHA256.Digest) -> UUID {
        var bytes = Array(digest.prefix(16))
        bytes[6] = (bytes[6] & 0x0F) | 0x50
        bytes[8] = (bytes[8] & 0x3F) | 0x80
        return UUID(uuid: (
            bytes[0], bytes[1], bytes[2], bytes[3],
            bytes[4], bytes[5], bytes[6], bytes[7],
            bytes[8], bytes[9], bytes[10], bytes[11],
            bytes[12], bytes[13], bytes[14], bytes[15]
        ))
    }
}
