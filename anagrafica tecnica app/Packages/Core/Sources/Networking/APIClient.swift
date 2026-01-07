import Foundation

public final class APIClient {
    private let config: NetworkConfig
    private let session: URLSession
    private let decoder: JSONDecoder

    public init(
        config: NetworkConfig,
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.config = config
        self.session = session
        self.decoder = decoder
    }

    public func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let data = try await request(endpoint)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailed(error)
        }
    }

    public func request(_ endpoint: Endpoint) async throws -> Data {
        let request = try buildRequest(for: endpoint)
        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.httpError(statusCode: httpResponse.statusCode, data: data)
            }
            return data
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.requestFailed(error)
        }
    }

    private func buildRequest(for endpoint: Endpoint) throws -> URLRequest {
        guard var components = URLComponents(url: config.baseURL, resolvingAgainstBaseURL: false) else {
            throw APIError.invalidURL
        }
        components.path = joinedPath(basePath: components.path, endpointPath: endpoint.path)
        if !endpoint.queryItems.isEmpty {
            components.queryItems = endpoint.queryItems
        }
        guard let url = components.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.timeoutInterval = config.timeout
        request.httpBody = endpoint.body

        let headers = config.defaultHeaders.merging(endpoint.headers) { _, new in new }
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        return request
    }

    private func joinedPath(basePath: String, endpointPath: String) -> String {
        let trimmedBase = basePath.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let trimmedEndpoint = endpointPath.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let parts = [trimmedBase, trimmedEndpoint].filter { !$0.isEmpty }
        guard !parts.isEmpty else {
            return ""
        }
        return "/" + parts.joined(separator: "/")
    }
}
