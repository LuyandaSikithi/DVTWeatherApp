import CoreLocation
import Foundation

struct CCFavouriteLocation: Identifiable, Hashable, Sendable {
    var m_id: UUID
    var m_name: String
    var m_lat: Double
    var m_lon: Double
    var m_currentWeather: CCCurrentWeather?

    var id: UUID { m_id }

    var m_coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: m_lat, longitude: m_lon)
    }

    static func == (lhs: CCFavouriteLocation, rhs: CCFavouriteLocation) -> Bool {
        lhs.m_id == rhs.m_id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(m_id)
    }
}
