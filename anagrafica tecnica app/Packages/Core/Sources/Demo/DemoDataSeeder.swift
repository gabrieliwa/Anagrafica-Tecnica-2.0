import CoreData
import Foundation

public enum DemoSeedResult: Equatable {
    case seeded(projectId: UUID)
    case skipped
}

public enum DemoSeedError: Error {
    case missingRequiredData(String)
}

public final class DemoDataSeeder {
    public init() {}

    @discardableResult
    public func seedIfNeeded(
        context: NSManagedObjectContext,
        bundle: Bundle = .main,
        projectName: String = "Demo Project"
    ) throws -> DemoSeedResult {
        let loader = try DemoPlanLoader(bundle: bundle)
        let planTemplate = try loader.loadPlanTemplate()
        let schemaVersion = try loader.loadSchemaVersion()

        var result: DemoSeedResult = .skipped
        var thrownError: Error?

        context.performAndWait {
            do {
                if try hasExistingProjects(context: context) {
                    result = .skipped
                    return
                }
                let projectId = try seed(
                    planTemplate: planTemplate,
                    schemaVersion: schemaVersion,
                    context: context,
                    projectName: projectName
                )
                result = .seeded(projectId: projectId)
            } catch {
                thrownError = error
            }
        }

        if let error = thrownError {
            throw error
        }
        return result
    }

    private func hasExistingProjects(context: NSManagedObjectContext) throws -> Bool {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Project")
        request.fetchLimit = 1
        return try context.count(for: request) > 0
    }

    private func seed(
        planTemplate: DemoPlanTemplate,
        schemaVersion: SchemaVersion,
        context: NSManagedObjectContext,
        projectName: String
    ) throws -> UUID {
        let projectId = schemaVersion.projectId
        let project = insert(entityName: "Project", context: context)
        project.setValue(projectId, forKey: "id")
        project.setValue(projectName, forKey: "name")
        project.setValue(ProjectLifecycleState.ready.rawValue, forKey: "stateRaw")
        project.setValue(nil, forKey: "location")
        project.setValue(nil, forKey: "imageURL")

        let totalRooms = planTemplate.levels.reduce(0) { $0 + $1.rooms.count }
        project.setValue(Int64(totalRooms), forKey: "roomCount")
        project.setValue(Int64(0), forKey: "assetCount")

        let schema = insert(entityName: "SchemaVersion", context: context)
        schema.setValue(schemaVersion.id, forKey: "id")
        schema.setValue(schemaVersion.version, forKey: "version")
        schema.setValue(schemaVersion.createdAt, forKey: "createdAt")
        schema.setValue(schemaVersion.isLocked, forKey: "isLocked")
        schema.setValue(project, forKey: "project")

        try seedFamilies(schemaVersion: schemaVersion, schemaObject: schema, context: context)
        try seedLevels(planTemplate: planTemplate, project: project, projectId: projectId, context: context)

        if context.hasChanges {
            try context.save()
        }

        return projectId
    }

    private func seedFamilies(
        schemaVersion: SchemaVersion,
        schemaObject: NSManagedObject,
        context: NSManagedObjectContext
    ) throws {
        let encoder = JSONCoding.makeEncoder()
        for family in schemaVersion.families {
            let familyObject = insert(entityName: "Family", context: context)
            familyObject.setValue(family.id, forKey: "id")
            familyObject.setValue(family.name, forKey: "name")
            familyObject.setValue(family.iconName, forKey: "iconName")
            if let sortOrder = family.sortOrder {
                familyObject.setValue(Int64(sortOrder), forKey: "sortOrder")
            }
            let parametersData = try encoder.encode(family.parameters)
            familyObject.setValue(parametersData, forKey: "parametersData")
            familyObject.setValue(schemaObject, forKey: "schemaVersion")
        }
    }

    private func seedLevels(
        planTemplate: DemoPlanTemplate,
        project: NSManagedObject,
        projectId: UUID,
        context: NSManagedObjectContext
    ) throws {
        let encoder = JSONCoding.makeEncoder()
        for level in planTemplate.levels {
            let levelId = StableID.fromString(level.id, namespace: projectId.uuidString)
            let levelObject = insert(entityName: "Level", context: context)
            levelObject.setValue(levelId, forKey: "id")
            levelObject.setValue(level.name, forKey: "name")
            levelObject.setValue(Int64(level.index), forKey: "orderIndex")
            levelObject.setValue(Int64(level.index), forKey: "number")
            levelObject.setValue(level.background.geojson, forKey: "backgroundGeoJSONPath")
            levelObject.setValue(project, forKey: "project")

            if let north = level.north,
               let start = point(from: north.start),
               let end = point(from: north.end) {
                let angle = GeometryUtils.northAngleDegrees(start: start, end: end)
                levelObject.setValue(angle, forKey: "northAngleDegrees")
            }
            if let bounds = rect(from: level.background.bounds) {
                let boundsData = try encoder.encode(bounds)
                levelObject.setValue(boundsData, forKey: "backgroundBoundsData")
            }

            try seedRooms(
                level: level,
                levelId: levelId,
                levelObject: levelObject,
                projectId: projectId,
                context: context
            )
        }
    }

    private func seedRooms(
        level: DemoPlanLevel,
        levelId: UUID,
        levelObject: NSManagedObject,
        projectId: UUID,
        context: NSManagedObjectContext
    ) throws {
        let encoder = JSONCoding.makeEncoder()
        for room in level.rooms {
            let roomIdSeed = "\(level.id):\(room.id)"
            let roomId = StableID.fromString(roomIdSeed, namespace: projectId.uuidString)
            let roomObject = insert(entityName: "Room", context: context)
            roomObject.setValue(roomId, forKey: "id")
            roomObject.setValue(room.name, forKey: "name")
            roomObject.setValue(room.number, forKey: "number")
            roomObject.setValue(Int64(0), forKey: "assetCount")
            roomObject.setValue(Int64(0), forKey: "roomNoteCount")
            roomObject.setValue(levelObject, forKey: "level")

            let polygon = room.shape.polygon.compactMap(point(from:))
            if polygon.count >= 3 {
                let bounds = GeometryUtils.bounds(for: polygon)
                let geometry = RoomGeometry(polygon: polygon, labelPoint: nil, bounds: bounds)
                let geometryData = try encoder.encode(geometry)
                roomObject.setValue(geometryData, forKey: "geometryData")
            }
        }
    }

    private func insert(entityName: String, context: NSManagedObjectContext) -> NSManagedObject {
        NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
    }

    private func rect(from bounds: [Double]) -> Rect? {
        guard bounds.count >= 4 else {
            return nil
        }
        return Rect(minX: bounds[0], minY: bounds[1], maxX: bounds[2], maxY: bounds[3])
    }

    private func point(from coords: [Double]) -> Point? {
        guard coords.count >= 2 else {
            return nil
        }
        return Point(x: coords[0], y: coords[1])
    }
}
