import Foundation
@testable import WeatherApp

final class CCMockWeatherRepository: CCWeatherRepositoryProtocol {
    var m_stubbedCurrentWeather: CCCurrentWeather?
    var m_stubbedForecast: [CCForecastDay] = []
    var m_stubbedError: Error?
    var m_offlineWeather: CCCurrentWeather?
    var m_fetchCurrentWeatherCallCount = 0
    var m_fetchForecastCallCount = 0

    func fetchCurrentWeather(lat: Double, lon: Double) async throws -> CCCurrentWeather {
        m_fetchCurrentWeatherCallCount += 1
        if let m_error = m_stubbedError { throw m_error }
        return m_stubbedCurrentWeather ?? CCCurrentWeather.m_stub()
    }

    func fetchForecast(lat: Double, lon: Double) async throws -> [CCForecastDay] {
        m_fetchForecastCallCount += 1
        if let m_error = m_stubbedError { throw m_error }
        return m_stubbedForecast
    }

    func fetchOfflineWeather() -> CCCurrentWeather? {
        m_offlineWeather
    }
}
