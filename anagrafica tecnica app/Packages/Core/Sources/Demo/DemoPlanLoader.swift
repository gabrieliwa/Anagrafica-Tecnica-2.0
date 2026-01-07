import Foundation

public enum DemoPlanLoaderError: Error {
    case bundleNotFound(String)
    case resourceMissing(String)
    case decodeFailed(Error)
}

public struct DemoPlanLoader {
    private let bundle: Bundle

    public init(demoBundle: Bundle) {
        self.bundle = demoBundle
    }

    public init(bundle: Bundle = .main, bundleName: String = "DemoPlan") throws {
        guard let url = bundle.url(forResource: bundleName, withExtension: "bundle"),
              let demoBundle = Bundle(url: url) else {
            throw DemoPlanLoaderError.bundleNotFound(bundleName)
        }
        self.bundle = demoBundle
    }

    public func loadPlanTemplate() throws -> DemoPlanTemplate {
        try decodeJSON(resource: "plan_template", type: DemoPlanTemplate.self)
    }

    public func loadSchemaVersion() throws -> SchemaVersion {
        try decodeJSON(resource: "schema_version", type: SchemaVersion.self)
    }

    private func decodeJSON<T: Decodable>(resource: String, type: T.Type) throws -> T {
        let data = try loadData(resource: resource, withExtension: "json")
        do {
            return try JSONCoding.makeDecoder().decode(T.self, from: data)
        } catch {
            throw DemoPlanLoaderError.decodeFailed(error)
        }
    }

    private func loadData(resource: String, withExtension ext: String) throws -> Data {
        guard let url = bundle.url(forResource: resource, withExtension: ext) else {
            throw DemoPlanLoaderError.resourceMissing("\(resource).\(ext)")
        }
        return try Data(contentsOf: url)
    }
}
