import XCTest
@testable import WeatherApp

@MainActor
final class CCGetForecastUseCaseTests: XCTestCase {
    private var m_mockRepository: CCMockWeatherRepository!
    private var m_sut: CCGetForecastUseCase!

    override func setUp() {
        super.setUp()
        m_mockRepository = CCMockWeatherRepository()
        m_sut = CCGetForecastUseCase(repository: m_mockRepository)
    }

    override func tearDown() {
        m_mockRepository = nil
        m_sut = nil
        super.tearDown()
    }

    func test_execute_returnsEmptyForecastByDefault() async throws {
        let m_result = try await m_sut.execute(lat: 0, lon: 0)
        XCTAssertTrue(m_result.isEmpty)
    }

    func test_execute_returnsStubbedForecast() async throws {
        let m_stubs = [CCForecastDay.m_stub(), CCForecastDay.m_stub(condition: .rain)]
        m_mockRepository.m_stubbedForecast = m_stubs
        let m_result = try await m_sut.execute(lat: 0, lon: 0)
        XCTAssertEqual(m_result.count, 2)
    }

    func test_execute_throwsOnError() async {
        m_mockRepository.m_stubbedError = CCNetworkError.noConnection
        do {
            _ = try await m_sut.execute(lat: 0, lon: 0)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertNotNil(error)
        }
    }
}
