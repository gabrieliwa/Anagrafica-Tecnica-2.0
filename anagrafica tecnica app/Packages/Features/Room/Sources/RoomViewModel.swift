import Core
import CoreData
import Foundation

@MainActor
final class RoomViewModel: ObservableObject {
    @Published var items: [RoomItem] = []
    @Published var roomGeometry: RoomGeometry?
    @Published var errorMessage: String?

    let levelName: String
    let roomNumber: String
    let roomName: String?

    private let context: NSManagedObjectContext
    private let decoder = JSONCoding.makeDecoder()

    init(context: NSManagedObjectContext, levelName: String, roomNumber: String, roomName: String?) {
        self.context = context
        self.levelName = levelName
        self.roomNumber = roomNumber
        self.roomName = roomName
        reload()
    }

    var titleText: String {
        "Level \(levelName) - Room \(roomNumber)"
    }

    var roomLabel: String {
        if let roomName, !roomName.isEmpty {
            return "Room \(roomNumber) - \(roomName)"
        }
        return "Room \(roomNumber)"
    }

    func reload() {
        do {
            guard let roomObject = try fetchRoom() else {
                errorMessage = "Room not found."
                items = []
                return
            }
            errorMessage = nil
            roomGeometry = try decodeGeometry(from: roomObject)
            items = try buildItems(roomObject: roomObject)
        } catch {
            errorMessage = "Failed to load room: \(error.localizedDescription)"
            items = []
        }
    }

    private func fetchRoom() throws -> NSManagedObject? {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Room")
        request.predicate = NSPredicate(format: "number == %@ AND level.name == %@", roomNumber, levelName)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    private func buildItems(roomObject: NSManagedObject) throws -> [RoomItem] {
        let assets = try fetchAssetInstances(roomObject: roomObject)
        let notes = try fetchRoomNotes(roomObject: roomObject)

        var combined: [RoomItem] = []
        for asset in assets {
            if let snapshot = makeAssetSnapshot(from: asset) {
                combined.append(RoomItem(kind: .asset(snapshot)))
            }
        }
        for note in notes {
            if let snapshot = makeRoomNoteSnapshot(from: note) {
                combined.append(RoomItem(kind: .roomNote(snapshot)))
            }
        }
        return combined.sorted { $0.sortKey < $1.sortKey }
    }

    private func fetchAssetInstances(roomObject: NSManagedObject) throws -> [NSManagedObject] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "AssetInstance")
        request.predicate = NSPredicate(format: "room == %@", roomObject)
        return try context.fetch(request)
    }

    private func fetchRoomNotes(roomObject: NSManagedObject) throws -> [NSManagedObject] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "RoomNote")
        request.predicate = NSPredicate(format: "room == %@", roomObject)
        return try context.fetch(request)
    }

    private func makeAssetSnapshot(from instance: NSManagedObject) -> AssetSnapshot? {
        guard let id = instance.value(forKey: "id") as? UUID else { return nil }
        let createdAt = instance.value(forKey: "createdAt") as? Date
        let instancePhotoIds = decodeUUIDs(from: instance.value(forKey: "instancePhotoIds") as? Data)

        let typeObject = instance.value(forKey: "type") as? NSManagedObject
        let typeName = typeObject?.value(forKey: "name") as? String ?? "Type"
        let typePhotoId = typeObject?.value(forKey: "typePhotoId") as? UUID
        let typeEntries = decodeEntries(from: typeObject?.value(forKey: "parametersData") as? Data)

        let familyObject = typeObject?.value(forKey: "family") as? NSManagedObject
        let familyName = familyObject?.value(forKey: "name") as? String ?? "Family"
        let definitions = decodeDefinitions(from: familyObject?.value(forKey: "parametersData") as? Data)

        let instanceEntries = decodeEntries(from: instance.value(forKey: "parametersData") as? Data)
        let typeFields = parameterRows(definitions: definitions, entries: typeEntries, scope: .type)
        let instanceFields = parameterRows(definitions: definitions, entries: instanceEntries, scope: .instance)

        return AssetSnapshot(
            id: id,
            typeName: typeName,
            familyName: familyName,
            createdAt: createdAt,
            typePhotoId: typePhotoId,
            instancePhotoIds: instancePhotoIds,
            typeFields: typeFields,
            instanceFields: instanceFields
        )
    }

    private func makeRoomNoteSnapshot(from note: NSManagedObject) -> RoomNoteSnapshot? {
        guard let id = note.value(forKey: "id") as? UUID else { return nil }
        let createdAt = note.value(forKey: "createdAt") as? Date
        let emptyRoom = note.value(forKey: "emptyRoom") as? Bool ?? false
        let roomIsBlocked = note.value(forKey: "roomIsBlocked") as? Bool ?? false
        let description = note.value(forKey: "noteDescription") as? String
        let mainPhotoId = note.value(forKey: "mainPhotoId") as? UUID
        let extraPhotoIds = decodeUUIDs(from: note.value(forKey: "extraPhotoIds") as? Data)

        return RoomNoteSnapshot(
            id: id,
            createdAt: createdAt,
            emptyRoom: emptyRoom,
            roomIsBlocked: roomIsBlocked,
            noteDescription: description,
            mainPhotoId: mainPhotoId,
            extraPhotoIds: extraPhotoIds
        )
    }

    private func decodeGeometry(from roomObject: NSManagedObject) throws -> RoomGeometry? {
        guard let data = roomObject.value(forKey: "geometryData") as? Data else { return nil }
        return try decoder.decode(RoomGeometry.self, from: data)
    }

    private func decodeDefinitions(from data: Data?) -> [ParameterDefinition] {
        guard let data else { return [] }
        do {
            return try decoder.decode([ParameterDefinition].self, from: data)
        } catch {
            print("RoomView: Failed to decode ParameterDefinition: \(error)")
            return []
        }
    }

    private func decodeEntries(from data: Data?) -> [ParameterValueEntry] {
        guard let data else { return [] }
        do {
            return try decoder.decode([ParameterValueEntry].self, from: data)
        } catch {
            print("RoomView: Failed to decode ParameterValueEntry: \(error)")
            return []
        }
    }

    private func decodeUUIDs(from data: Data?) -> [UUID] {
        guard let data else { return [] }
        do {
            return try decoder.decode([UUID].self, from: data)
        } catch {
            print("RoomView: Failed to decode UUID list: \(error)")
            return []
        }
    }

    private func parameterRows(
        definitions: [ParameterDefinition],
        entries: [ParameterValueEntry],
        scope: ParameterScope
    ) -> [ParameterDisplayRow] {
        let values = Dictionary(uniqueKeysWithValues: entries.map { ($0.parameterId, $0.value) })
        return definitions.filter { $0.scope == scope }.map { definition in
            let value = values[definition.id]
            return ParameterDisplayRow(
                id: definition.id,
                name: definition.name,
                value: formatValue(value, unit: definition.unit),
                isMissing: value == nil
            )
        }
    }

    private func formatValue(_ value: ParameterValue?, unit: String?) -> String {
        guard let value else { return "-" }
        let base: String
        switch value {
        case .text(let text):
            base = text
        case .number(let number):
            base = Self.numberFormatter.string(from: NSNumber(value: number)) ?? String(format: "%.2f", number)
        case .bool(let flag):
            base = flag ? "Yes" : "No"
        case .date(let date):
            base = Self.dateFormatter.string(from: date)
        case .option(let option):
            base = option
        }
        if let unit, !unit.isEmpty {
            return "\(base) \(unit)"
        }
        return base
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    private static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}

public struct RoomItem: Identifiable {
    public let id: UUID
    public let kind: RoomItemKind
    let sortKey: RoomItemSortKey

    init(kind: RoomItemKind) {
        self.kind = kind
        self.id = kind.id
        self.sortKey = RoomItemSortKey(kind: kind)
    }
}

public enum RoomItemKind {
    case asset(AssetSnapshot)
    case roomNote(RoomNoteSnapshot)

    var id: UUID {
        switch self {
        case .asset(let snapshot):
            return snapshot.id
        case .roomNote(let snapshot):
            return snapshot.id
        }
    }

    var createdAt: Date? {
        switch self {
        case .asset(let snapshot):
            return snapshot.createdAt
        case .roomNote(let snapshot):
            return snapshot.createdAt
        }
    }

    var displayTitle: String {
        switch self {
        case .asset(let snapshot):
            return snapshot.typeName
        case .roomNote:
            return "Room Note"
        }
    }

    var displaySubtitle: String {
        switch self {
        case .asset(let snapshot):
            return snapshot.familyName
        case .roomNote(let snapshot):
            if snapshot.roomIsBlocked {
                return "Room is blocked"
            }
            if snapshot.emptyRoom {
                return "Empty room"
            }
            return snapshot.noteDescription?.isEmpty == false ? snapshot.noteDescription! : "Note"
        }
    }
}

struct RoomItemSortKey: Comparable {
    let familyName: String
    let typeName: String
    let createdAt: Date

    init(kind: RoomItemKind) {
        switch kind {
        case .asset(let snapshot):
            familyName = snapshot.familyName.lowercased()
            typeName = snapshot.typeName.lowercased()
            createdAt = snapshot.createdAt ?? .distantPast
        case .roomNote(let snapshot):
            familyName = "room note"
            typeName = "room note"
            createdAt = snapshot.createdAt ?? .distantPast
        }
    }

    static func < (lhs: RoomItemSortKey, rhs: RoomItemSortKey) -> Bool {
        if lhs.familyName != rhs.familyName {
            return lhs.familyName < rhs.familyName
        }
        if lhs.typeName != rhs.typeName {
            return lhs.typeName < rhs.typeName
        }
        return lhs.createdAt < rhs.createdAt
    }
}

public struct AssetSnapshot: Identifiable {
    public let id: UUID
    let typeName: String
    let familyName: String
    let createdAt: Date?
    let typePhotoId: UUID?
    let instancePhotoIds: [UUID]
    let typeFields: [ParameterDisplayRow]
    let instanceFields: [ParameterDisplayRow]
}

public struct RoomNoteSnapshot: Identifiable {
    public let id: UUID
    let createdAt: Date?
    let emptyRoom: Bool
    let roomIsBlocked: Bool
    let noteDescription: String?
    let mainPhotoId: UUID?
    let extraPhotoIds: [UUID]
}

struct ParameterDisplayRow: Identifiable {
    let id: UUID
    let name: String
    let value: String
    let isMissing: Bool
}
