import Foundation

struct CCForecastResponse: Decodable, Sendable {
    let list: [CCForecastItemDTO]
    let city: CCCityDTO

    struct CCForecastItemDTO: Decodable, Sendable {
        let dt: TimeInterval
        let main: CCCurrentWeatherResponse.CCMainDTO
        let weather: [CCCurrentWeatherResponse.CCWeatherDTO]
    }

    struct CCCityDTO: Decodable, Sendable {
        let name: String
    }
}
