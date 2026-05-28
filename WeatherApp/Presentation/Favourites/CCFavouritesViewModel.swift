import Foundation

@Observable
class CCFavouritesViewModel {
    var m_state: CCFavouritesState = .idle
    var m_searchText = ""
    var m_searchState: CCPlaceSearchState = .idle

    private let m_getFavourites: CCGetFavouritesUseCase
    private let m_saveFavourite: CCSaveFavouriteUseCase
    private let m_deleteFavourite: CCDeleteFavouriteUseCase
    private let m_weatherRepository: CCWeatherRepositoryProtocol
    private let m_placesService: CCPlacesSearchService

    init(
        getFavourites: CCGetFavouritesUseCase,
        saveFavourite: CCSaveFavouriteUseCase,
        deleteFavourite: CCDeleteFavouriteUseCase,
        weatherRepository: CCWeatherRepositoryProtocol,
        placesService: CCPlacesSearchService
    ) {
        self.m_getFavourites = getFavourites
        self.m_saveFavourite = saveFavourite
        self.m_deleteFavourite = deleteFavourite
        self.m_weatherRepository = weatherRepository
        self.m_placesService = placesService
    }

    func loadFavourites() async {
        m_state = .loading
        var m_favourites = m_getFavourites.execute()
        for m_index in m_favourites.indices {
            let m_fav = m_favourites[m_index]
            if let m_weather = try? await m_weatherRepository.fetchCurrentWeather(lat: m_fav.m_lat, lon: m_fav.m_lon) {
                m_favourites[m_index].m_currentWeather = m_weather
            }
        }
        m_state = .loaded(m_favourites)
    }

    func delete(_ location: CCFavouriteLocation) {
        m_deleteFavourite.execute(location)
        Task { await loadFavourites() }
    }

    func searchPlaces() async {
        guard !m_searchText.isEmpty else {
            m_searchState = .idle
            return
        }
        m_searchState = .searching
        do {
            let m_results = try await m_placesService.searchPlaces(query: m_searchText)
            m_searchState = .results(m_results)
        } catch {
            m_searchState = .error(error.localizedDescription)
        }
    }

    func selectPlace(_ place: CCPlaceResult) async {
        do {
            let (m_lat, m_lon) = try await m_placesService.fetchPlaceDetails(placeId: place.m_id)
            let m_location = CCFavouriteLocation(m_id: UUID(), m_name: place.m_name, m_lat: m_lat, m_lon: m_lon)
            m_saveFavourite.execute(m_location)
            m_searchText = ""
            m_searchState = .idle
            await loadFavourites()
        } catch {
            m_searchState = .error(error.localizedDescription)
        }
    }

}
