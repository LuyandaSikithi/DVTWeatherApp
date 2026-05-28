import Foundation

class CCGetFavouritesUseCase {
    private let m_repository: CCFavouritesRepositoryProtocol

    init(repository: CCFavouritesRepositoryProtocol) {
        self.m_repository = repository
    }

    func execute() -> [CCFavouriteLocation] {
        m_repository.fetchFavourites()
    }
}
