import Foundation

extension Double {
    func m_temperatureString() -> String {
        String(format: "%.0f°", self)
    }

    func m_roundedString() -> String {
        String(format: "%.1f", self)
    }
}
