import CoreData

public enum CoreDataStackError: Error {
    case storeLoadFailed(Error)
}

public final class CoreDataStack {
    public let container: NSPersistentContainer

    public init(
        name: String,
        model: NSManagedObjectModel,
        inMemory: Bool = false,
        allowsLightweightMigration: Bool = true
    ) throws {
        container = NSPersistentContainer(name: name, managedObjectModel: model)
        if let description = container.persistentStoreDescriptions.first {
            if inMemory {
                description.url = URL(fileURLWithPath: "/dev/null")
            }
            if allowsLightweightMigration {
                description.shouldMigrateStoreAutomatically = true
                description.shouldInferMappingModelAutomatically = true
            }
        }

        var loadError: Error?
        container.loadPersistentStores { _, error in
            loadError = error
        }

        if let error = loadError {
            throw CoreDataStackError.storeLoadFailed(error)
        }

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
