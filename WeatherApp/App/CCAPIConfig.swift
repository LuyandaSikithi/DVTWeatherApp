import Foundation

enum CCAPIConfig {
    static let m_weatherAPIKey: String = {
        guard let m_key = Bundle.main.infoDictionary?["WEATHER_API_KEY"] as? String, !m_key.isEmpty else {
            return m_weatherAPIKeyFallback
        }
        return m_key
    }()

    static let m_placesAPIKey: String = {
        guard let m_key = Bundle.main.infoDictionary?["PLACES_API_KEY"] as? String, !m_key.isEmpty else {
            return m_placesAPIKeyFallback
        }
        return m_key
    }()

    private static let m_weatherAPIKeyFallback = "8573252ad3849794f893a4ef2893a7cf"
    private static let m_placesAPIKeyFallback = "AIzaSyA8K_WVS1jKQIcbKCuJLZIpYRfjAn_r-1Q"
}
