import MapKit
import SwiftUI

struct CCMapView: View {
    @Bindable var m_viewModel: CCMapViewModel

    init(viewModel: CCMapViewModel) {
        self.m_viewModel = viewModel
    }

    var body: some View {
        ZStack(alignment: .top) {
            Map(position: $m_viewModel.m_cameraPosition) {
                ForEach(m_viewModel.m_favourites) { m_favourite in
                    Annotation(m_favourite.m_name, coordinate: m_favourite.m_coordinate) {
                        CCMapPinView(
                            m_name: m_favourite.m_name,
                            m_weather: m_favourite.m_currentWeather,
                            m_isSelected: m_viewModel.m_selectedFavourite?.m_id == m_favourite.m_id
                        )
                        .onTapGesture {
                            m_viewModel.m_selectedFavourite = m_favourite
                        }
                    }
                }

                if let m_result = m_viewModel.m_searchedLocation {
                    Annotation(m_result.m_name, coordinate: m_result.m_coordinate) {
                        CCSearchPinView()
                    }
                }

                if let m_coordinate = m_viewModel.m_currentCoordinate {
                    Annotation("My Location", coordinate: m_coordinate) {
                        ZStack {
                            Circle().fill(.blue.opacity(0.2)).frame(width: 40, height: 40)
                            Circle().fill(.blue).frame(width: 16, height: 16)
                            Circle().stroke(.white, lineWidth: 2).frame(width: 16, height: 16)
                        }
                    }
                }
            }
            .ignoresSafeArea(edges: .bottom)

            VStack(spacing: 0) {
                CCMapSearchBar(
                    m_query: $m_viewModel.m_searchQuery,
                    m_isSearching: m_viewModel.m_isSearching,
                    m_onSearch: { Task { await m_viewModel.searchCity() } },
                    m_onClear: { m_viewModel.clearSearch() }
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 8)

                if let m_errorMessage = m_viewModel.m_searchError {
                    Text(m_errorMessage)
                        .font(.caption)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color.red.opacity(0.85))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.horizontal, 16)
                }

                Spacer()

                if let m_result = m_viewModel.m_searchedLocation {
                    CCAddFavouriteCard(
                        m_name: m_result.m_name,
                        m_onAdd: { m_viewModel.saveSearchedLocation() },
                        m_onDismiss: { m_viewModel.clearSearch() }
                    )
                    .padding(16)
                }
            }
        }
        .navigationTitle("Map")
        .onAppear {
            m_viewModel.refreshFavourites()
        }
        .task {
            guard m_viewModel.m_currentCoordinate == nil else { return }
            await m_viewModel.loadData()
        }
    }
}

private struct CCMapSearchBar: View {
    @Binding var m_query: String
    let m_isSearching: Bool
    let m_onSearch: () -> Void
    let m_onClear: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search city...", text: $m_query)
                    .autocorrectionDisabled()
                    .onSubmit { m_onSearch() }
                if m_isSearching {
                    ProgressView().scaleEffect(0.8)
                } else if !m_query.isEmpty {
                    Button { m_onClear() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(10)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            if !m_query.isEmpty {
                Button("Search") { m_onSearch() }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.regular)
            }
        }
    }
}

private struct CCAddFavouriteCard: View {
    let m_name: String
    let m_onAdd: () -> Void
    let m_onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "mappin.circle.fill")
                .font(.title2)
                .foregroundStyle(.orange)
            VStack(alignment: .leading, spacing: 2) {
                Text(m_name)
                    .font(.headline)
                Text("Add this location to favourites?")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button(action: m_onAdd) {
                Label("Add", systemImage: "star.fill")
                    .font(.subheadline.weight(.semibold))
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)

            Button(action: m_onDismiss) {
                Image(systemName: "xmark")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 8)
    }
}

private struct CCSearchPinView: View {
    var body: some View {
        Image(systemName: "mappin.circle.fill")
            .font(.title)
            .foregroundStyle(.purple)
            .shadow(radius: 3)
    }
}

private struct CCMapPinView: View {
    let m_name: String
    let m_weather: CCCurrentWeather?
    let m_isSelected: Bool

    var body: some View {
        VStack(spacing: 0) {
            if m_isSelected, let m_w = m_weather {
                VStack(spacing: 2) {
                    Text(m_name).font(.caption.bold())
                    Text(m_w.m_temp.m_temperatureString()).font(.caption)
                    Text(m_w.m_condition.m_displayName).font(.caption2).foregroundStyle(.secondary)
                }
                .padding(8)
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(radius: 4)
            }
            Image(systemName: "mappin.circle.fill")
                .font(.title)
                .foregroundStyle(m_isSelected ? .red : .orange)
        }
    }
}
