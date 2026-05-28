import SwiftUI

struct CCMainTabView: View {
    private let m_container = CCDependencyContainer.shared

    var body: some View {
        TabView {
            Tab("Weather", systemImage: "cloud.sun.fill") {
                CCWeatherView(viewModel: m_container.m_weatherViewModel)
            }
            Tab("Favourites", systemImage: "star.fill") {
                CCFavouritesView(viewModel: m_container.m_favouritesViewModel)
            }
            Tab("Map", systemImage: "map.fill") {
                NavigationStack {
                    CCMapView(viewModel: m_container.m_mapViewModel)
                }
            }
        }
    }
}
