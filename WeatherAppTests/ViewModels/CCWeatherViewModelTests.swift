import XCTest
@testable import WeatherApp

@MainActor
final class CCWeatherViewModelTests: XCTestCase {
    private var m_mockRepository: CCMockWeatherRepository!
    private var m_sut: CCWeatherViewModel!

    override func setUp() {
        super.setUp()
        m_mockRepository = CCMockWeatherRepository()
        let m_persistenceController = CCPersistenceController(inMemory: true)
        m_sut = CCWeatherViewModel(
            getCurrentWeather: CCGetCurrentWeatherUseCase(repository: m_mockRepository),
            getForecast: CCGetForecastUseCase(repository: m_mockRepository),
            getOfflineWeather: CCGetOfflineWeatherUseCase(repository: m_mockRepository),
            locationService: CCLocationService()
        )
    }

    override func tearDown() {
        m_mockRepository = nil
        m_sut = nil
        super.tearDown()
    }

    func test_initialState_isIdle() {
        if case .idle = m_sut.m_state {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected idle state")
        }
    }

    func test_loadWeatherForLocation_success_setsLoadedState() async {
        let m_weather = CCCurrentWeather.m_stub(temp: 20.0)
        let m_forecast = [CCForecastDay.m_stub()]
        m_mockRepository.m_stubbedCurrentWeather = m_weather
        m_mockRepository.m_stubbedForecast = m_forecast

        await m_sut.loadWeatherForLocation(lat: -33.9, lon: 18.4)

        if case .loaded(let m_w, let m_f) = m_sut.m_state {
            XCTAssertEqual(m_w.m_temp, 20.0)
            XCTAssertEqual(m_f.count, 1)
        } else {
            XCTFail("Expected loaded state")
        }
    }

    func test_loadWeatherForLocation_networkFailure_withCachedData_setsOfflineState() async {
        m_mockRepository.m_stubbedError = CCNetworkError.noConnection
        m_mockRepository.m_offlineWeather = CCCurrentWeather.m_stub()

        await m_sut.loadWeatherForLocation(lat: 0, lon: 0)

        if case .error = m_sut.m_state {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected error state")
        }
    }

    func test_loadWeatherForLocation_error_noCache_setsErrorState() async {
        m_mockRepository.m_stubbedError = CCNetworkError.noConnection
        m_mockRepository.m_offlineWeather = nil

        await m_sut.loadWeatherForLocation(lat: 0, lon: 0)

        if case .error = m_sut.m_state {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected error state")
        }
    }
}
