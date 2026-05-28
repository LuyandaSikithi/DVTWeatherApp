import SwiftUI

struct CCOfflineBannerView: View {
    let m_cachedAt: Date?

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "wifi.slash")
            Text(m_bannerText)
                .font(.caption)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.6))
        .clipShape(Capsule())
    }

    private var m_bannerText: String {
        if let m_date = m_cachedAt {
            return "Last updated: \(m_date.m_formatted(as: "d MMM, HH:mm"))"
        }
        return "Offline – no cached data"
    }
}
