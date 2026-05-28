import XCTest
@testable import WeatherApp

@MainActor
final class CCGetCurrentWeatherUseCaseTests: XCTestCase {
    private var m_mockRepository: CCMockWeatherRepository!
    private var m_sut: CCGetCurrentWeatherUseCase!

    override func setUp() {
        super.setUp()
        m_mockRepository = CCMockWeatherRepository()
        m_sut = CCGetCurrentWeatherUseCase(repository: m_mockRepository)
    }

    override func tearDown() {
        m_mockRepository = nil
        m_sut = nil
        super.tearDown()
    }

    func test_execute_callsRepositoryOnce() async throws {
        _ = try await m_sut.execute(lat: -33.9, lon: 18.4)
        XCTAssertEqual(m_mockRepository.m_fetchCurrentWeatherCallCount, 1)
    }

    func test_execute_returnsCorrectWeather() async throws {
        let m_expected = CCCurrentWeather.m_stub(temp: 25.0, city: "Johannesburg")
        m_mockRepository.m_stubbedCurrentWeather = m_expected
        let m_result = try await m_sut.execute(lat: -26.2, lon: 28.0)
        XCTAssertEqual(m_result.m_temp, 25.0)
        XCTAssertEqual(m_result.m_city, "Johannesburg")
    }

    func test_execute_throwsOnRepositoryError() async {
        m_mockRepository.m_stubbedError = CCNetworkError.serverError(500)
        do {
            _ = try await m_sut.execute(lat: 0, lon: 0)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertNotNil(error)
        }
    }
}
