import Foundation

class CCGetCurrentWeatherUseCase {
    private let m_repository: CCWeatherRepositoryProtocol

    init(repository: CCWeatherRepositoryProtocol) {
        self.m_repository = repository
    }

    func execute(lat: Double, lon: Double) async throws -> CCCurrentWeather {
        try await m_repository.fetchCurrentWeather(lat: lat, lon: lon)
    }
}
