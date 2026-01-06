import CoreData

public enum CoreDataStackError: Error {
    case storeLoadFailed(Error)
}

public final class CoreDataStack {
    public let container: NSPersistentContainer

    public init(name: String, model: NSManagedObjectModel, inMemory: Bool = false) throws {
        container = NSPersistentContainer(name: name, managedObjectModel: model)
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        var loadError: Error?
        container.loadPersistentStores { _, error in
            loadError = error
        }

        if let error = loadError {
            throw CoreDataStackError.storeLoadFailed(error)
        }
    }
}
