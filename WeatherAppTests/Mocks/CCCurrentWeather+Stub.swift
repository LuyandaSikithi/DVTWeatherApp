import Foundation
@testable import WeatherApp

extension CCCurrentWeather {
    static func m_stub(
        temp: Double = 22.0,
        city: String = "Cape Town",
        condition: CCWeatherCondition = .clear
    ) -> CCCurrentWeather {
        CCCurrentWeather(
            m_temp: temp,
            m_feelsLike: temp - 2,
            m_tempMin: temp - 5,
            m_tempMax: temp + 5,
            m_humidity: 65,
            m_condition: condition,
            m_conditionDescription: condition.m_displayName,
            m_weatherIcon: "01d",
            m_city: city,
            m_windSpeed: 10.0,
            m_latitude: -33.9249,
            m_longitude: 18.4241
        )
    }
}

extension CCForecastDay {
    static func m_stub(condition: CCWeatherCondition = .clear) -> CCForecastDay {
        CCForecastDay(
            m_date: Date(),
            m_minTemp: 15.0,
            m_maxTemp: 25.0,
            m_weatherIcon: "01d",
            m_condition: condition
        )
    }
}
