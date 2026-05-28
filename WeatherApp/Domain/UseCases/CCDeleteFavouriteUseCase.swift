import Foundation

class CCDeleteFavouriteUseCase {
    private let m_repository: CCFavouritesRepositoryProtocol

    init(repository: CCFavouritesRepositoryProtocol) {
        self.m_repository = repository
    }

    func execute(_ location: CCFavouriteLocation) {
        m_repository.deleteFavourite(location)
    }
}
