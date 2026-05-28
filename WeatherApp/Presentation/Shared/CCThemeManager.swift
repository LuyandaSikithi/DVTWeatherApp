import SwiftUI

struct CCThemeManager {
    static func backgroundImageName(for condition: CCWeatherCondition) -> String {
        switch condition {
        case .clear:
            return "forest_sunny"
        case .rain, .drizzle, .thunderstorm:
            return "forest_rainy"
        case .clouds, .mist, .fog, .haze, .smoke, .dust, .snow:
            return "forest_cloudy"
        }
    }

    static func backgroundColor(for condition: CCWeatherCondition) -> Color {
        switch condition {
        case .clear:
            return Color("WeatherSunny")
        case .rain, .drizzle, .thunderstorm:
            return Color("WeatherRainy")
        case .clouds, .mist, .fog, .haze, .smoke, .dust, .snow:
            return Color("WeatherCloudy")
        }
    }

    static func accentColor(for condition: CCWeatherCondition) -> Color {
        switch condition {
        case .clear: return Color("WeatherSunny")
        case .rain, .drizzle, .thunderstorm: return Color("WeatherRainy")
        case .clouds, .mist, .fog, .haze, .smoke, .dust, .snow: return Color("WeatherCloudy")
        }
    }
}
