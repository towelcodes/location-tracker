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
    var apikey: String?
    var endpoint: String?
    var uid: String?
    
    func sendLocation(_ location: CLLocation) {
        print("sending location")
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

//class NetworkingService: NSObject, URLSessionDelegate, URLSessionTaskDelegate {
//    static let shared = NetworkingService()
//    
//    private lazy var session: URLSession = {
//        let config = URLSessionConfiguration.background(withIdentifier: "codes.towel.location-tracker")
//        config.isDiscretionary = false
//        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
//    }()
//    
//    func sendLocation(_ location: CLLocation) {
//        let url = URL(string: "https://sgofzvpbietvmuaibcdm.supabase.co/functions/v1/ping")!
//        var req = URLRequest(url: url)
//        req.httpMethod = "POST"
//        let body: [String : Any] = [
//            "uid": "ios",
//            "lat": location.coordinate.latitude,
//            "long": location.coordinate.longitude
//        ]
//        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
//        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        session.dataTask(with: url) {(data, response, error) in
//            guard let data = data else { return }
//            print(String(data: data, encoding: .utf8)!)
//        }
////        session.uploadTask(with: req, from: req.httpBody!).resume()
//    }
//    
//    // urlsessiondelegate methods can go here (handling auth, retries, etc.)
//}


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
//                    locService.start()
                }
        }
    }
}
