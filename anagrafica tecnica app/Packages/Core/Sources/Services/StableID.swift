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
        let high = fnv1a64("A|\(namespaced)")
        let low = fnv1a64("B|\(namespaced)")
        return uuidFromParts(high: high, low: low)
    }

    private static let fnvOffset: UInt64 = 0xcbf29ce484222325
    private static let fnvPrime: UInt64 = 0x100000001b3

    private static func fnv1a64(_ value: String) -> UInt64 {
        var hash = fnvOffset
        for byte in value.utf8 {
            hash ^= UInt64(byte)
            hash &*= fnvPrime
        }
        return hash
    }

    private static func bytes(from value: UInt64) -> [UInt8] {
        [
            UInt8((value >> 56) & 0xFF),
            UInt8((value >> 48) & 0xFF),
            UInt8((value >> 40) & 0xFF),
            UInt8((value >> 32) & 0xFF),
            UInt8((value >> 24) & 0xFF),
            UInt8((value >> 16) & 0xFF),
            UInt8((value >> 8) & 0xFF),
            UInt8(value & 0xFF)
        ]
    }

    private static func uuidFromParts(high: UInt64, low: UInt64) -> UUID {
        var bytes = bytes(from: high) + bytes(from: low)
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
