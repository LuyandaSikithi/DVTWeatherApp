import Foundation

class CCPlacesSearchService {
    private let m_networkService: CCNetworkService
    private let m_baseURL = "https://maps.googleapis.com/maps/api/place"

    init(networkService: CCNetworkService) {
        self.m_networkService = networkService
    }

    func searchPlaces(query: String) async throws -> [CCPlaceResult] {
        let m_key = CCAPIConfig.m_placesAPIKey
        let m_encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let m_urlString = "\(m_baseURL)/autocomplete/json?input=\(m_encoded)&types=(cities)&key=\(m_key)"
        guard let m_url = URL(string: m_urlString) else { throw CCNetworkError.invalidURL }
        let m_response: CCPlacesAutocompleteResponse = try await m_networkService.request(m_url)
        return m_response.predictions.map { p in
            CCPlaceResult(m_id: p.placeId, m_name: p.structuredFormatting.mainText, m_description: p.description, m_lat: 0, m_lon: 0)
        }
    }

    func fetchPlaceDetails(placeId: String) async throws -> (lat: Double, lon: Double) {
        let m_key = CCAPIConfig.m_placesAPIKey
        let m_urlString = "\(m_baseURL)/details/json?place_id=\(placeId)&fields=geometry&key=\(m_key)"
        guard let m_url = URL(string: m_urlString) else { throw CCNetworkError.invalidURL }
        let m_response: CCPlaceDetailsResponse = try await m_networkService.request(m_url)
        let m_location = m_response.result.geometry.location
        return (lat: m_location.lat, lon: m_location.lng)
    }
}

private struct CCPlacesAutocompleteResponse: Decodable {
    let predictions: [CCPrediction]

    struct CCPrediction: Decodable {
        let placeId: String
        let description: String
        let structuredFormatting: CCStructuredFormatting

        enum CodingKeys: String, CodingKey {
            case placeId = "place_id"
            case description
            case structuredFormatting = "structured_formatting"
        }

        struct CCStructuredFormatting: Decodable {
            let mainText: String
            enum CodingKeys: String, CodingKey {
                case mainText = "main_text"
            }
        }
    }
}

private struct CCPlaceDetailsResponse: Decodable {
    let result: CCResult

    struct CCResult: Decodable {
        let geometry: CCGeometry

        struct CCGeometry: Decodable {
            let location: CCLocation

            struct CCLocation: Decodable {
                let lat: Double
                let lng: Double
            }
        }
    }
}
