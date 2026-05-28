import Foundation

enum CCWeatherCondition: String, Codable, Sendable {
    case clear = "clear"
    case clouds = "clouds"
    case rain = "rain"
    case drizzle = "drizzle"
    case thunderstorm = "thunderstorm"
    case snow = "snow"
    case mist = "mist"
    case fog = "fog"
    case haze = "haze"
    case smoke = "smoke"
    case dust = "dust"

    var m_displayName: String {
        switch self {
        case .clear: return "Sunny"
        case .clouds: return "Cloudy"
        case .rain: return "Rainy"
        case .drizzle: return "Drizzle"
        case .thunderstorm: return "Thunderstorm"
        case .snow: return "Snow"
        case .mist: return "Misty"
        case .fog: return "Foggy"
        case .haze: return "Hazy"
        case .smoke: return "Smoky"
        case .dust: return "Dusty"
        }
    }

    var m_iconName: String {
        switch self {
        case .clear: return "clear"
        case .clouds, .mist, .fog, .haze, .smoke, .dust: return "partlysunny"
        case .rain, .drizzle, .thunderstorm, .snow: return "rain"
        }
    }
}
