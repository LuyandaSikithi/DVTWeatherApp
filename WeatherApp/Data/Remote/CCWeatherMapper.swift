import Foundation

struct CCWeatherMapper {
    static func mapCurrentWeather(_ response: CCCurrentWeatherResponse) -> CCCurrentWeather {
        let m_condition = CCWeatherCondition(rawValue: response.weather.first?.main.lowercased() ?? "") ?? .clear
        return CCCurrentWeather(
            m_temp: response.main.temp,
            m_feelsLike: response.main.feelsLike,
            m_tempMin: response.main.tempMin,
            m_tempMax: response.main.tempMax,
            m_humidity: response.main.humidity,
            m_condition: m_condition,
            m_conditionDescription: response.weather.first?.description.capitalized ?? "",
            m_weatherIcon: response.weather.first?.icon ?? "",
            m_city: response.name,
            m_windSpeed: response.wind.speed,
            m_latitude: response.coord.lat,
            m_longitude: response.coord.lon
        )
    }

    static func mapForecast(_ response: CCForecastResponse) -> [CCForecastDay] {
        let m_formatter = DateFormatter()
        m_formatter.dateFormat = "yyyy-MM-dd"
        var m_dailyData: [String: (min: Double, max: Double, icon: String, condition: String)] = [:]

        for m_item in response.list {
            let m_date = Date(timeIntervalSince1970: m_item.dt)
            let m_key = m_formatter.string(from: m_date)
            if let m_existing = m_dailyData[m_key] {
                m_dailyData[m_key] = (
                    min: Swift.min(m_existing.min, m_item.main.tempMin),
                    max: Swift.max(m_existing.max, m_item.main.tempMax),
                    icon: m_existing.icon,
                    condition: m_existing.condition
                )
            } else {
                m_dailyData[m_key] = (
                    min: m_item.main.tempMin,
                    max: m_item.main.tempMax,
                    icon: m_item.weather.first?.icon ?? "",
                    condition: m_item.weather.first?.main ?? ""
                )
            }
        }

        return m_dailyData.sorted { $0.key < $1.key }.prefix(5).map { (m_key, m_value) in
            let m_date = m_formatter.date(from: m_key) ?? Date()
            let m_condition = CCWeatherCondition(rawValue: m_value.condition.lowercased()) ?? .clear
            return CCForecastDay(
                m_date: m_date,
                m_minTemp: m_value.min,
                m_maxTemp: m_value.max,
                m_weatherIcon: m_value.icon,
                m_condition: m_condition
            )
        }
    }
}
