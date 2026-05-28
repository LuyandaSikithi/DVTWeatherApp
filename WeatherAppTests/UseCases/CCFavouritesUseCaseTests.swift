import XCTest
@testable import WeatherApp

@MainActor
final class CCFavouritesUseCaseTests: XCTestCase {
    private var m_mockRepository: CCMockFavouritesRepository!

    override func setUp() {
        super.setUp()
        m_mockRepository = CCMockFavouritesRepository()
    }

    override func tearDown() {
        m_mockRepository = nil
        super.tearDown()
    }

    func test_saveFavourite_storesLocation() {
        let m_sut = CCSaveFavouriteUseCase(repository: m_mockRepository)
        let m_location = CCFavouriteLocation(m_id: UUID(), m_name: "Durban", m_lat: -29.8587, m_lon: 31.0218)
        m_sut.execute(m_location)
        XCTAssertEqual(m_mockRepository.m_saveFavouriteCallCount, 1)
        XCTAssertEqual(m_mockRepository.m_savedFavourites.count, 1)
    }

    func test_getFavourites_returnsStoredLocations() {
        let m_location = CCFavouriteLocation(m_id: UUID(), m_name: "Pretoria", m_lat: -25.7461, m_lon: 28.1881)
        m_mockRepository.m_savedFavourites = [m_location]
        let m_sut = CCGetFavouritesUseCase(repository: m_mockRepository)
        let m_result = m_sut.execute()
        XCTAssertEqual(m_result.count, 1)
        XCTAssertEqual(m_result.first?.m_name, "Pretoria")
    }

    func test_deleteFavourite_removesLocation() {
        let m_id = UUID()
        let m_location = CCFavouriteLocation(m_id: m_id, m_name: "Cape Town", m_lat: -33.9249, m_lon: 18.4241)
        m_mockRepository.m_savedFavourites = [m_location]
        let m_sut = CCDeleteFavouriteUseCase(repository: m_mockRepository)
        m_sut.execute(m_location)
        XCTAssertEqual(m_mockRepository.m_deleteFavouriteCallCount, 1)
        XCTAssertTrue(m_mockRepository.m_savedFavourites.isEmpty)
    }
}
