//
//  WeatherAppTests.swift
//  WeatherAppTests
//
//  Created by Luyanda Sikithi on 2026/05/26.
//

import Testing
@testable import WeatherApp

struct WeatherAppTests {

    @Test func weatherConditionDisplayName() {
        #expect(CCWeatherCondition.clear.m_displayName == "Sunny")
        #expect(CCWeatherCondition.rain.m_displayName == "Rainy")
        #expect(CCWeatherCondition.clouds.m_displayName == "Cloudy")
    }

    @Test func temperatureFormatting() {
        #expect(22.5.m_temperatureString() == "23°")
        #expect(0.0.m_temperatureString() == "0°")
    }

    @Test func weatherMapperCreatesCorrectCondition() {
        let m_response = CCCurrentWeatherResponse(
            name: "London",
            main: .init(temp: 15.0, feelsLike: 13.0, tempMin: 10.0, tempMax: 18.0, humidity: 80),
            weather: [.init(main: "Rain", description: "light rain", icon: "10d")],
            wind: .init(speed: 5.0),
            coord: .init(lat: 51.5, lon: -0.12)
        )
        let m_weather = CCWeatherMapper.mapCurrentWeather(m_response)
        #expect(m_weather.m_condition == .rain)
        #expect(m_weather.m_city == "London")
        #expect(m_weather.m_temp == 15.0)
    }
}
