import Foundation

enum CCWeatherState: Sendable {
    case idle
    case loading
    case loaded(CCCurrentWeather, [CCForecastDay])
    case offline(CCCurrentWeather, [CCForecastDay])
    case error(String)
}

enum CCFavouritesState: Sendable {
    case idle
    case loading
    case loaded([CCFavouriteLocation])
    case error(String)
}

enum CCPlaceSearchState: Sendable {
    case idle
    case searching
    case results([CCPlaceResult])
    case error(String)
}
