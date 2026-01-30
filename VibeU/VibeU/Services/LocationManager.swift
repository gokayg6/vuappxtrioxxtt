import Foundation
import CoreLocation
import Combine

// MARK: - Location Manager Service
@MainActor
class LocationManager: NSObject, ObservableObject {
    static let shared = LocationManager()
    
    @Published var userLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLocationEnabled: Bool = false
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100 // Update every 100 meters
        authorizationStatus = locationManager.authorizationStatus
        checkLocationAuthorization()
    }
    
    // Request location permission
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    // Start updating location
    func startUpdatingLocation() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            print("⚠️ Location permission not granted")
            return
        }
        
        locationManager.startUpdatingLocation()
        isLocationEnabled = true
        print("📍 Started updating location")
    }
    
    // Stop updating location
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        isLocationEnabled = false
        print("📍 Stopped updating location")
    }
    
    // Calculate distance between two coordinates in kilometers
    func calculateDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        let distanceInMeters = fromLocation.distance(from: toLocation)
        return distanceInMeters / 1000.0 // Convert to kilometers
    }
    
    // Calculate distance from user's current location to a coordinate
    func calculateDistanceFromUser(to coordinate: CLLocationCoordinate2D) -> Double? {
        guard let userLocation = userLocation else { return nil }
        return calculateDistance(
            from: CLLocationCoordinate2D(
                latitude: userLocation.coordinate.latitude,
                longitude: userLocation.coordinate.longitude
            ),
            to: coordinate
        )
    }
    
    private func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            print("📍 Location: Not Determined")
        case .restricted:
            print("📍 Location: Restricted")
        case .denied:
            print("📍 Location: Denied")
            isLocationEnabled = false
        case .authorizedAlways, .authorizedWhenInUse:
            print("📍 Location: Authorized")
            startUpdatingLocation()
        @unknown default:
            break
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        Task { @MainActor in
            self.userLocation = location
            print("📍 Location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("⚠️ Location error: \(error.localizedDescription)")
    }
    
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus
            self.checkLocationAuthorization()
        }
    }
}
