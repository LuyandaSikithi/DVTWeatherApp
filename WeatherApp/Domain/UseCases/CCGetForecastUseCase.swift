import Foundation

class CCGetForecastUseCase {
    private let m_repository: CCWeatherRepositoryProtocol

    init(repository: CCWeatherRepositoryProtocol) {
        self.m_repository = repository
    }

    func execute(lat: Double, lon: Double) async throws -> [CCForecastDay] {
        try await m_repository.fetchForecast(lat: lat, lon: lon)
    }
}
