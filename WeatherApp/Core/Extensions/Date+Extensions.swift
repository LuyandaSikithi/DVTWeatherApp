import Foundation

extension Date {
    func m_formatted(as format: String) -> String {
        let m_formatter = DateFormatter()
        m_formatter.dateFormat = format
        return m_formatter.string(from: self)
    }

    func m_dayOfWeek() -> String {
        let m_formatter = DateFormatter()
        m_formatter.dateFormat = "EEEE"
        return m_formatter.string(from: self)
    }

    func m_timeAgoString() -> String {
        let m_interval = Date().timeIntervalSince(self)
        let m_minutes = Int(m_interval / 60)
        if m_minutes < 1 { return "Just now" }
        if m_minutes == 1 { return "1 minute ago" }
        if m_minutes < 60 { return "\(m_minutes) minutes ago" }
        let m_hours = m_minutes / 60
        if m_hours == 1 { return "1 hour ago" }
        return "\(m_hours) hours ago"
    }
}
