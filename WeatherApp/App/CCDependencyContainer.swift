import Foundation

@MainActor
class CCDependencyContainer {
    static let shared = CCDependencyContainer()

    private lazy var m_networkService = CCNetworkService()
    private lazy var m_apiClient = CCWeatherAPIClient(networkService: m_networkService)
    private lazy var m_persistenceController = CCPersistenceController.shared
    private lazy var m_placesService = CCPlacesSearchService(networkService: m_networkService)
    private lazy var m_locationService = CCLocationService()

    private lazy var m_weatherRepository: CCWeatherRepositoryProtocol = CCWeatherRepository(
        apiClient: m_apiClient,
        persistenceController: m_persistenceController
    )

    private lazy var m_favouritesRepository: CCFavouritesRepositoryProtocol = CCFavouritesRepository(
        persistenceController: m_persistenceController
    )

    lazy var m_weatherViewModel = CCWeatherViewModel(
        getCurrentWeather: CCGetCurrentWeatherUseCase(repository: m_weatherRepository),
        getForecast: CCGetForecastUseCase(repository: m_weatherRepository),
        getOfflineWeather: CCGetOfflineWeatherUseCase(repository: m_weatherRepository),
        locationService: m_locationService
    )

    lazy var m_favouritesViewModel = CCFavouritesViewModel(
        getFavourites: CCGetFavouritesUseCase(repository: m_favouritesRepository),
        saveFavourite: CCSaveFavouriteUseCase(repository: m_favouritesRepository),
        deleteFavourite: CCDeleteFavouriteUseCase(repository: m_favouritesRepository),
        weatherRepository: m_weatherRepository,
        placesService: m_placesService
    )

    lazy var m_mapViewModel = CCMapViewModel(
        getFavourites: CCGetFavouritesUseCase(repository: m_favouritesRepository),
        saveFavourite: CCSaveFavouriteUseCase(repository: m_favouritesRepository),
        locationService: m_locationService
    )

    func makeWeatherViewModel() -> CCWeatherViewModel {
        CCWeatherViewModel(
            getCurrentWeather: CCGetCurrentWeatherUseCase(repository: m_weatherRepository),
            getForecast: CCGetForecastUseCase(repository: m_weatherRepository),
            getOfflineWeather: CCGetOfflineWeatherUseCase(repository: m_weatherRepository),
            locationService: m_locationService
        )
    }
}
