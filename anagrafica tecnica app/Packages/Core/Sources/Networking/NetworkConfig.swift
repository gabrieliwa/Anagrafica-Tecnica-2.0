import Foundation

public struct NetworkConfig {
    public var baseURL: URL
    public var defaultHeaders: [String: String]
    public var timeout: TimeInterval

    public init(
        baseURL: URL,
        defaultHeaders: [String: String] = [:],
        timeout: TimeInterval = 30
    ) {
        self.baseURL = baseURL
        self.defaultHeaders = defaultHeaders
        self.timeout = timeout
    }
}
