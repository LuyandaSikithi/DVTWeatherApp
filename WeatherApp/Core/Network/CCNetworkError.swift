import Foundation

enum CCNetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError(Error)
    case serverError(Int)
    case noConnection

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .invalidResponse: return "Invalid server response"
        case .decodingError(let error): return "Failed to decode: \(error.localizedDescription)"
        case .serverError(let code): return "Server error: \(code)"
        case .noConnection: return "No internet connection"
        }
    }
}
