import Foundation

protocol CCFavouritesRepositoryProtocol: Sendable {
    func fetchFavourites() -> [CCFavouriteLocation]
    func saveFavourite(_ location: CCFavouriteLocation)
    func deleteFavourite(_ location: CCFavouriteLocation)
}
