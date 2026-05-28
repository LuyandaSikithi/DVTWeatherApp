import CoreLocation
import Foundation

@Observable
class CCWeatherViewModel {
    var m_state: CCWeatherState = .idle
    var m_isOffline = false

    private let m_getCurrentWeather: CCGetCurrentWeatherUseCase
    private let m_getForecast: CCGetForecastUseCase
    private let m_getOfflineWeather: CCGetOfflineWeatherUseCase
    private let m_locationService: CCLocationService

    init(
        getCurrentWeather: CCGetCurrentWeatherUseCase,
        getForecast: CCGetForecastUseCase,
        getOfflineWeather: CCGetOfflineWeatherUseCase,
        locationService: CCLocationService
    ) {
        self.m_getCurrentWeather = getCurrentWeather
        self.m_getForecast = getForecast
        self.m_getOfflineWeather = getOfflineWeather
        self.m_locationService = locationService
    }

    func loadWeather() async {
        m_state = .loading
        do {
            let m_location = try await m_locationService.fetchCurrentLocation()
            let m_lat = m_location.coordinate.latitude
            let m_lon = m_location.coordinate.longitude
            async let m_weather = m_getCurrentWeather.execute(lat: m_lat, lon: m_lon)
            async let m_forecast = m_getForecast.execute(lat: m_lat, lon: m_lon)
            let (m_w, m_f) = try await (m_weather, m_forecast)
            m_isOffline = false
            m_state = .loaded(m_w, m_f)
        } catch {
            if let m_cached = m_getOfflineWeather.execute() {
                m_isOffline = true
                m_state = .offline(m_cached, [])
            } else {
                m_state = .error(error.localizedDescription)
            }
        }
    }

    func loadWeatherForLocation(lat: Double, lon: Double) async {
        m_state = .loading
        do {
            async let m_weather = m_getCurrentWeather.execute(lat: lat, lon: lon)
            async let m_forecast = m_getForecast.execute(lat: lat, lon: lon)
            let (m_w, m_f) = try await (m_weather, m_forecast)
            m_isOffline = false
            m_state = .loaded(m_w, m_f)
        } catch {
            m_state = .error(error.localizedDescription)
        }
    }

    func requestLocationPermission() {
        m_locationService.requestPermission()
    }
}
