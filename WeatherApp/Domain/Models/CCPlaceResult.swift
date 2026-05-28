import Foundation

struct CCPlaceResult: Identifiable, Sendable {
    var m_id: String
    var m_name: String
    var m_description: String
    var m_lat: Double
    var m_lon: Double

    var id: String { m_id }
}
