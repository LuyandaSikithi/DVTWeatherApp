import Foundation

struct CCCurrentWeatherResponse: Decodable, Sendable {
    let name: String
    let main: CCMainDTO
    let weather: [CCWeatherDTO]
    let wind: CCWindDTO
    let coord: CCCoordDTO

    struct CCMainDTO: Decodable, Sendable {
        let temp: Double
        let feelsLike: Double
        let tempMin: Double
        let tempMax: Double
        let humidity: Int

        enum CodingKeys: String, CodingKey {
            case temp
            case feelsLike = "feels_like"
            case tempMin = "temp_min"
            case tempMax = "temp_max"
            case humidity
        }
    }

    struct CCWeatherDTO: Decodable, Sendable {
        let main: String
        let description: String
        let icon: String
    }

    struct CCWindDTO: Decodable, Sendable {
        let speed: Double
    }

    struct CCCoordDTO: Decodable, Sendable {
        let lat: Double
        let lon: Double
    }
}
