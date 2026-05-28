import CoreLocation
import Foundation

@MainActor
class CCLocationService: NSObject {
    private let m_locationManager = CLLocationManager()
    private var m_locationContinuation: CheckedContinuation<CLLocation, Error>?
    private var m_authContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?
    private var m_isFetching = false

    var m_authorizationStatus: CLAuthorizationStatus {
        m_locationManager.authorizationStatus
    }

    override init() {
        super.init()
        m_locationManager.delegate = self
        m_locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func fetchCurrentLocation() async throws -> CLLocation {
        if m_isFetching, let m_existing = m_locationContinuation {
            return try await withCheckedThrowingContinuation { _ in
                _ = m_existing
            }
        }

        let m_status = m_locationManager.authorizationStatus

        switch m_status {
        case .notDetermined:
            m_locationManager.requestWhenInUseAuthorization()
            let m_resolved = await withCheckedContinuation { (continuation: CheckedContinuation<CLAuthorizationStatus, Never>) in
                m_authContinuation = continuation
            }
            guard m_resolved == .authorizedWhenInUse || m_resolved == .authorizedAlways else {
                throw CLError(.denied)
            }
        case .denied, .restricted:
            throw CLError(.denied)
        case .authorizedWhenInUse, .authorizedAlways:
            break
        @unknown default:
            throw CLError(.denied)
        }

        m_isFetching = true
        defer { m_isFetching = false }

        return try await withCheckedThrowingContinuation { continuation in
            m_locationContinuation = continuation
            m_locationManager.requestLocation()
        }
    }

    func requestPermission() {
        guard m_locationManager.authorizationStatus == .notDetermined else { return }
        m_locationManager.requestWhenInUseAuthorization()
    }
}

extension CCLocationService: @preconcurrency CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.m_authContinuation?.resume(returning: manager.authorizationStatus)
            self.m_authContinuation = nil
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let m_location = locations.first else { return }
        Task { @MainActor in
            self.m_locationContinuation?.resume(returning: m_location)
            self.m_locationContinuation = nil
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.m_locationContinuation?.resume(throwing: error)
            self.m_locationContinuation = nil
        }
    }
}
