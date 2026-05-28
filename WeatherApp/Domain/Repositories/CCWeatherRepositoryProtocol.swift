import Foundation

protocol CCWeatherRepositoryProtocol: Sendable {
    func fetchCurrentWeather(lat: Double, lon: Double) async throws -> CCCurrentWeather
    func fetchForecast(lat: Double, lon: Double) async throws -> [CCForecastDay]
    func fetchOfflineWeather() -> CCCurrentWeather?
}
