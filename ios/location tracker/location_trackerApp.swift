//
//  location_trackerApp.swift
//  location tracker
//
//  Created by Joel on 01/09/2025.
//

import SwiftUI
import CoreLocation

struct RequestPayload: Codable {
    var uid: String
    var lat: Double
    var long: Double
}

class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    @Published var lastLocation: CLLocation?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = true
    }
    
    func requestAuth() {
        print("requesting location service auth")
        manager.requestAlwaysAuthorization()
    }
    
    func start() {
        print("starting location service")
        manager.startUpdatingLocation()
    }
    
    func stop() {
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        DispatchQueue.main.async {
            self.lastLocation = loc
        }
        NetworkingService.shared.sendLocation(loc)
    }
}

class NetworkingService {
    static let shared = NetworkingService()
    var last: Date?
    
    var apikey: String? {
        didSet {
            if apikey == "" { apikey = nil }
        }
    }
    var endpoint: String? {
        didSet {
            if endpoint == "" { endpoint = nil }
        }
    }
    var uid: String? {
        didSet {
            if uid == "" { uid = nil }
        }
    }
    
    func sendLocation(_ location: CLLocation) {
        print("sending location")
        
        if let l: Date = last {
            if (l + 40) > Date.now {
                print("cancelling: 40s limit")
                return
            }
        }
        last = Date.now
        
        guard let url = URL(string: endpoint ?? Environment.endpoint) else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer "+(apikey ?? Environment.apikey), forHTTPHeaderField: "Authorization")
        req.setValue(apikey ?? Environment.apikey, forHTTPHeaderField: "apikey")
        print(location.coordinate.latitude, location.coordinate.longitude)
        do {
            req.httpBody = try JSONEncoder().encode(RequestPayload(uid: uid ?? "anonymous", lat: location.coordinate.latitude, long: location.coordinate.longitude))
        } catch {
            print("json encoding failed", error)
            return
        }
        
        
        let task = URLSession.shared.dataTask(with: req) {(data, response, error) in
            guard let data = data else { return }
            if let http = response as? HTTPURLResponse {
                print("status", http.statusCode)
            }
            print(String(data: data, encoding: .utf8)!)
        }
        task.resume()
    }
}

@main
struct location_trackerApp: App {
    @StateObject private var locService = LocationService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locService)
                .onAppear {
                    print("hello world!!!!!")
                    locService.requestAuth()
                }
        }
    }
}
