import Foundation
@testable import WeatherApp

final class CCMockFavouritesRepository: CCFavouritesRepositoryProtocol {
    var m_savedFavourites: [CCFavouriteLocation] = []
    var m_saveFavouriteCallCount = 0
    var m_deleteFavouriteCallCount = 0

    func fetchFavourites() -> [CCFavouriteLocation] {
        m_savedFavourites
    }

    func saveFavourite(_ location: CCFavouriteLocation) {
        m_saveFavouriteCallCount += 1
        m_savedFavourites.append(location)
    }

    func deleteFavourite(_ location: CCFavouriteLocation) {
        m_deleteFavouriteCallCount += 1
        m_savedFavourites.removeAll { $0.m_id == location.m_id }
    }
}
