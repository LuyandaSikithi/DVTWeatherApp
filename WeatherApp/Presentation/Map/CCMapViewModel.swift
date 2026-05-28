import CoreLocation
import Foundation
import MapKit
import SwiftUI

struct CCMapSearchResult {
    let m_name: String
    let m_lat: Double
    let m_lon: Double

    var m_coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: m_lat, longitude: m_lon)
    }
}

@Observable
class CCMapViewModel {
    var m_favourites: [CCFavouriteLocation] = []
    var m_currentCoordinate: CLLocationCoordinate2D?
    var m_selectedFavourite: CCFavouriteLocation?
    var m_cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -26.2041, longitude: 28.0473),
        span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5)
    ))

    var m_searchQuery = ""
    var m_searchedLocation: CCMapSearchResult?
    var m_isSearching = false
    var m_searchError: String?

    private let m_getFavourites: CCGetFavouritesUseCase
    private let m_saveFavourite: CCSaveFavouriteUseCase
    private let m_locationService: CCLocationService

    init(
        getFavourites: CCGetFavouritesUseCase,
        saveFavourite: CCSaveFavouriteUseCase,
        locationService: CCLocationService
    ) {
        self.m_getFavourites = getFavourites
        self.m_saveFavourite = saveFavourite
        self.m_locationService = locationService
    }

    func refreshFavourites() {
        m_favourites = m_getFavourites.execute()
    }

    func loadData() async {
        m_favourites = m_getFavourites.execute()
        if let m_location = try? await m_locationService.fetchCurrentLocation() {
            m_currentCoordinate = m_location.coordinate
            m_cameraPosition = .region(MKCoordinateRegion(
                center: m_location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2)
            ))
        }
    }

    func searchCity() async {
        let m_query = m_searchQuery.trimmingCharacters(in: .whitespaces)
        guard !m_query.isEmpty else { return }

        m_isSearching = true
        m_searchError = nil
        m_searchedLocation = nil

        let m_request = MKLocalSearch.Request()
        m_request.naturalLanguageQuery = m_query
        m_request.resultTypes = [.address, .pointOfInterest]

        do {
            let m_search = MKLocalSearch(request: m_request)
            let m_response = try await m_search.start()
            if let m_item = m_response.mapItems.first {
                let m_coord = m_item.placemark.coordinate
                let m_name = m_item.placemark.locality
                    ?? m_item.placemark.administrativeArea
                    ?? m_item.name
                    ?? m_query
                m_searchedLocation = CCMapSearchResult(
                    m_name: m_name,
                    m_lat: m_coord.latitude,
                    m_lon: m_coord.longitude
                )
                m_cameraPosition = .region(MKCoordinateRegion(
                    center: m_coord,
                    span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                ))
            } else {
                m_searchError = "No results found for \"\(m_query)\""
            }
        } catch {
            m_searchError = error.localizedDescription
        }

        m_isSearching = false
    }

    func saveSearchedLocation() {
        guard let m_result = m_searchedLocation else { return }
        let m_location = CCFavouriteLocation(
            m_id: UUID(),
            m_name: m_result.m_name,
            m_lat: m_result.m_lat,
            m_lon: m_result.m_lon
        )
        m_saveFavourite.execute(m_location)
        m_favourites = m_getFavourites.execute()
        clearSearch()
    }

    func clearSearch() {
        m_searchQuery = ""
        m_searchedLocation = nil
        m_searchError = nil
    }
}
