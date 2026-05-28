import Foundation

final class CCWeatherRepository: CCWeatherRepositoryProtocol {
    private let m_apiClient: CCWeatherAPIClient
    private let m_persistenceController: CCPersistenceController

    init(apiClient: CCWeatherAPIClient, persistenceController: CCPersistenceController) {
        self.m_apiClient = apiClient
        self.m_persistenceController = persistenceController
    }

    func fetchCurrentWeather(lat: Double, lon: Double) async throws -> CCCurrentWeather {
        let m_response = try await m_apiClient.fetchCurrentWeather(lat: lat, lon: lon)
        let m_weather = CCWeatherMapper.mapCurrentWeather(m_response)
        m_persistenceController.saveWeatherCache(m_weather)
        return m_weather
    }

    func fetchForecast(lat: Double, lon: Double) async throws -> [CCForecastDay] {
        let m_response = try await m_apiClient.fetchForecast(lat: lat, lon: lon)
        return CCWeatherMapper.mapForecast(m_response)
    }

    func fetchOfflineWeather() -> CCCurrentWeather? {
        m_persistenceController.fetchCachedWeather()
    }
}
