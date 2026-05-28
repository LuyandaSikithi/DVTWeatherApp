import Foundation

class CCNetworkService {
    private let m_session: URLSession

    init(session: URLSession = .shared) {
        self.m_session = session
    }

    func request<T: Decodable>(_ url: URL) async throws -> T {
        let (m_data, m_response) = try await m_session.data(from: url)
        guard let m_httpResponse = m_response as? HTTPURLResponse else {
            throw CCNetworkError.invalidResponse
        }
        guard (200...299).contains(m_httpResponse.statusCode) else {
            throw CCNetworkError.serverError(m_httpResponse.statusCode)
        }
        do {
            let m_decoder = JSONDecoder()
            return try m_decoder.decode(T.self, from: m_data)
        } catch {
            throw CCNetworkError.decodingError(error)
        }
    }
}
