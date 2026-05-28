import SwiftUI

struct CCWeatherView: View {
    var m_viewModel: CCWeatherViewModel
    let m_lat: Double?
    let m_lon: Double?

    init(viewModel: CCWeatherViewModel, lat: Double? = nil, lon: Double? = nil) {
        self.m_viewModel = viewModel
        self.m_lat = lat
        self.m_lon = lon
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                CCThemeManager.backgroundColor(for: m_currentCondition)
                    .ignoresSafeArea()

                switch m_viewModel.m_state {
                case .idle:
                    EmptyView()
                case .loading:
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .loaded(let weather, let forecasts), .offline(let weather, let forecasts):
                    m_loadedContent(weather: weather, forecasts: forecasts, geo: geo)
                case .error(let message):
                    m_errorContent(message: message)
                }

                if m_viewModel.m_isOffline {
                    CCOfflineBannerView(m_cachedAt: m_cachedAt)
                        .padding(.top, geo.safeAreaInsets.top + 8)
                }
            }
        }
        .ignoresSafeArea()
        .task {
            guard case .idle = m_viewModel.m_state else { return }
            if let m_lat, let m_lon {
                await m_viewModel.loadWeatherForLocation(lat: m_lat, lon: m_lon)
            } else {
                await m_viewModel.loadWeather()
            }
        }
    }

    @ViewBuilder
    private func m_loadedContent(weather: CCCurrentWeather, forecasts: [CCForecastDay], geo: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            ZStack {
                Image(CCThemeManager.backgroundImageName(for: weather.m_condition))
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height * 0.45)
                    .clipped()

                VStack(spacing: 2) {
                    Text(weather.m_temp.m_temperatureString())
                        .font(.system(size: 80, weight: .thin))
                    Text(weather.m_condition.m_displayName.uppercased())
                        .font(.title2.weight(.semibold))
                        .tracking(2)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)

                Image(weather.m_condition.m_iconName)
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(.top, geo.safeAreaInsets.top + 20)
                    .padding(.trailing, 24)
            }
            .frame(height: geo.size.height * 0.45)

            HStack(spacing: 0) {
                m_statColumn(value: weather.m_tempMin.m_temperatureString(), label: "min")
                Rectangle().fill(.white.opacity(0.4)).frame(width: 1, height: 40)
                m_statColumn(value: weather.m_temp.m_temperatureString(), label: "Current")
                Rectangle().fill(.white.opacity(0.4)).frame(width: 1, height: 40)
                m_statColumn(value: weather.m_tempMax.m_temperatureString(), label: "max")
            }
            .padding(.vertical, 16)

            Rectangle().fill(.white.opacity(0.3)).frame(height: 1)

            VStack(spacing: 0) {
                ForEach(forecasts) { day in
                    CCForecastRowView(m_forecast: day)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                    if day.m_id != forecasts.last?.m_id {
                        Rectangle().fill(.white.opacity(0.2)).frame(height: 1)
                    }
                }
            }
            .padding(.bottom, geo.safeAreaInsets.bottom)

            Spacer()
        }
    }

    @ViewBuilder
    private func m_statColumn(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.weight(.light))
            Text(label)
                .font(.caption)
                .opacity(0.8)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func m_errorContent(message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
            Text(message)
                .multilineTextAlignment(.center)
            Button("Retry") {
                Task { await m_viewModel.loadWeather() }
            }
            .buttonStyle(.bordered)
        }
        .foregroundStyle(.white)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var m_currentCondition: CCWeatherCondition {
        switch m_viewModel.m_state {
        case .loaded(let w, _), .offline(let w, _): return w.m_condition
        default: return .clear
        }
    }

    private var m_cachedAt: Date? {
        if case .offline(let w, _) = m_viewModel.m_state { return w.m_cachedAt }
        return nil
    }
}
