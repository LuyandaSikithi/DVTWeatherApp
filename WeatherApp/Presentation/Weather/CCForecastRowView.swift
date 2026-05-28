import SwiftUI

struct CCForecastRowView: View {
    let m_forecast: CCForecastDay

    var body: some View {
        HStack {
            Text(m_forecast.m_date.m_dayOfWeek())
                .frame(maxWidth: .infinity, alignment: .leading)
            Image(m_forecast.m_condition.m_iconName)
                .resizable()
                .renderingMode(.original)
                .scaledToFit()
                .frame(width: 24, height: 24)
                .frame(maxWidth: .infinity)
            Text(m_forecast.m_maxTemp.m_temperatureString())
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .foregroundStyle(.white)
    }
}
