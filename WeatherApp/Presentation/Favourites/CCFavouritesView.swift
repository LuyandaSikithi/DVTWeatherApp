import SwiftUI

struct CCFavouritesView: View {
    @Bindable var m_viewModel: CCFavouritesViewModel

    init(viewModel: CCFavouritesViewModel) {
        self.m_viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SearchBar(m_text: $m_viewModel.m_searchText)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .onChange(of: m_viewModel.m_searchText) {
                        Task { await m_viewModel.searchPlaces() }
                    }

                if case .results(let m_results) = m_viewModel.m_searchState, !m_results.isEmpty {
                    m_searchResultsList(m_results)
                } else {
                    m_favouritesList
                }
            }
            .navigationTitle("Favourites")
            .task {
                guard case .idle = m_viewModel.m_state else { return }
                await m_viewModel.loadFavourites()
            }
        }
    }

    @ViewBuilder
    private var m_favouritesList: some View {
        switch m_viewModel.m_state {
        case .loading:
            ProgressView().padding()
            Spacer()
        case .loaded(let m_favourites):
            if m_favourites.isEmpty {
                ContentUnavailableView(
                    "No Favourites",
                    systemImage: "star.slash",
                    description: Text("Search for a city on the Map tab to add it here.")
                )
            } else {
                List {
                    ForEach(m_favourites) { m_favourite in
                        NavigationLink(value: m_favourite) {
                            CCFavouriteRowView(m_favourite: m_favourite)
                        }
                        .swipeActions(edge: .trailing) {
                            Button("Delete", role: .destructive) {
                                m_viewModel.delete(m_favourite)
                            }
                        }
                    }
                }
                .navigationDestination(for: CCFavouriteLocation.self) { favourite in
                    CCWeatherView(
                        viewModel: CCDependencyContainer.shared.makeWeatherViewModel(),
                        lat: favourite.m_lat,
                        lon: favourite.m_lon
                    )
                    .navigationTitle(favourite.m_name)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbarColorScheme(.dark, for: .navigationBar)
                }
            }
        case .error(let m_message):
            ContentUnavailableView(
                "Error",
                systemImage: "exclamationmark.triangle",
                description: Text(m_message)
            )
        default:
            Spacer()
        }
    }

    @ViewBuilder
    private func m_searchResultsList(_ results: [CCPlaceResult]) -> some View {
        List(results) { m_result in
            Button {
                Task { await m_viewModel.selectPlace(m_result) }
            } label: {
                VStack(alignment: .leading, spacing: 2) {
                    Text(m_result.m_name).font(.body)
                    Text(m_result.m_description).font(.caption).foregroundStyle(.secondary)
                }
            }
        }
    }
}

private struct CCFavouriteRowView: View {
    let m_favourite: CCFavouriteLocation

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(m_favourite.m_name).font(.headline)
                if let m_weather = m_favourite.m_currentWeather {
                    Text(m_weather.m_condition.m_displayName).font(.caption).foregroundStyle(.secondary)
                }
            }
            Spacer()
            if let m_weather = m_favourite.m_currentWeather {
                Text(m_weather.m_temp.m_temperatureString()).font(.title2)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct SearchBar: View {
    @Binding var m_text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
            TextField("Search cities...", text: $m_text).autocorrectionDisabled()
            if !m_text.isEmpty {
                Button { m_text = "" } label: {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

