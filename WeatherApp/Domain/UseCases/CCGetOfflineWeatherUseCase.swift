import Foundation

class CCGetOfflineWeatherUseCase {
    private let m_repository: CCWeatherRepositoryProtocol

    init(repository: CCWeatherRepositoryProtocol) {
        self.m_repository = repository
    }

    func execute() -> CCCurrentWeather? {
        m_repository.fetchOfflineWeather()
    }
}
