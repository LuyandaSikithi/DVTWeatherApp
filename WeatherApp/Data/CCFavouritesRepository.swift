import Foundation

final class CCFavouritesRepository: CCFavouritesRepositoryProtocol {
    private let m_persistenceController: CCPersistenceController

    init(persistenceController: CCPersistenceController) {
        self.m_persistenceController = persistenceController
    }

    func fetchFavourites() -> [CCFavouriteLocation] {
        m_persistenceController.fetchFavourites()
    }

    func saveFavourite(_ location: CCFavouriteLocation) {
        m_persistenceController.saveFavourite(location)
    }

    func deleteFavourite(_ location: CCFavouriteLocation) {
        m_persistenceController.deleteFavourite(location)
    }
}
