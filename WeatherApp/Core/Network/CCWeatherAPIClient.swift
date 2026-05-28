import Foundation

class CCWeatherAPIClient {
    private let m_networkService: CCNetworkService
    private let m_baseURL = "https://api.openweathermap.org/data/2.5"

    init(networkService: CCNetworkService) {
        self.m_networkService = networkService
    }

    func fetchCurrentWeather(lat: Double, lon: Double) async throws -> CCCurrentWeatherResponse {
        let m_key = CCAPIConfig.m_weatherAPIKey
        let m_urlString = "\(m_baseURL)/weather?lat=\(lat)&lon=\(lon)&appid=\(m_key)&units=metric"
        guard let m_url = URL(string: m_urlString) else { throw CCNetworkError.invalidURL }
        return try await m_networkService.request(m_url)
    }

    func fetchForecast(lat: Double, lon: Double) async throws -> CCForecastResponse {
        let m_key = CCAPIConfig.m_weatherAPIKey
        let m_urlString = "\(m_baseURL)/forecast?lat=\(lat)&lon=\(lon)&appid=\(m_key)&units=metric&cnt=40"
        guard let m_url = URL(string: m_urlString) else { throw CCNetworkError.invalidURL }
        return try await m_networkService.request(m_url)
    }
}
