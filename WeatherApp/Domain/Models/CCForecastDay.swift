import Foundation

struct CCForecastDay: Identifiable, Sendable {
    var m_id = UUID()
    var id: UUID { m_id }
    var m_date: Date
    var m_minTemp: Double
    var m_maxTemp: Double
    var m_weatherIcon: String
    var m_condition: CCWeatherCondition
}
