//
//  ContentView.swift
//  location tracker
//
//  Created by Joel on 01/09/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    let defaults = UserDefaults.standard
    @EnvironmentObject var loc: LocationService
    @State private var enableReporting = UserDefaults.standard.bool(forKey: ConfigurationKeys.enableReporting)
    @State private var endpoint = UserDefaults.standard.string(forKey: ConfigurationKeys.endpoint) ?? "";
    @State private var apikey = UserDefaults.standard.string(forKey: ConfigurationKeys.apikey) ?? "";
    @State private var uid = UserDefaults.standard.string(forKey: ConfigurationKeys.uid) ?? "";
    
    var body: some View {
        VStack {
            if let last = loc.lastLocation {
                Text("lat: \(last.coordinate.latitude), lon: \(last.coordinate.longitude)")
            } else {
                Text("no location yet")
            }
            
            Button("Send Ping") {
                if let last = loc.lastLocation {
                    NetworkingService.shared.sendLocation(last)
                }
            }
            
            Toggle(
                "Enable Reporting",
                isOn: $enableReporting
            ).onChange(of: enableReporting, initial: true) {
                if enableReporting {
                    print("turning on reporting")
                    loc.start()
                    defaults.set(true, forKey: ConfigurationKeys.enableReporting)
                } else {
                    print("turning off reporting")
                    loc.stop()
                    defaults.set(false, forKey: ConfigurationKeys.enableReporting)
                }
            }
            
            HStack {
                Text("Endpoint")
                TextField(
                    "https://",
                    text: $endpoint).onChange(of: endpoint) {
                        NetworkingService.shared.endpoint = endpoint
                        defaults.set(endpoint, forKey: ConfigurationKeys.endpoint)
                    }
            }
            
            HStack {
                Text("API Key")
                TextField(
                    "eyXXXXXXXXX",
                    text: $apikey).onChange(of: apikey) {
                        NetworkingService.shared.apikey = apikey
                        defaults.set(apikey, forKey: ConfigurationKeys.apikey)
                    }
            }
            
            HStack {
                Text("User ID")
                TextField(
                    "anonymous",
                    text: $uid).onChange(of: uid) {
                        NetworkingService.shared.uid = uid
                        defaults.set(uid, forKey: ConfigurationKeys.uid)
                    }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
