import Foundation

struct CCCurrentWeather: Sendable {
    var m_temp: Double
    var m_feelsLike: Double
    var m_tempMin: Double
    var m_tempMax: Double
    var m_humidity: Int
    var m_condition: CCWeatherCondition
    var m_conditionDescription: String
    var m_weatherIcon: String
    var m_city: String
    var m_windSpeed: Double
    var m_latitude: Double
    var m_longitude: Double
    var m_cachedAt: Date?
}
