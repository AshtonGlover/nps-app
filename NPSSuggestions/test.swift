//
//  test.swift
//  NPSSuggestions
//
//  Created by Ashton Glover on 8/21/24.
//

import SwiftUI
import Foundation
import MapKit
import CoreLocation

struct test: View {
    @State private var parksInfo: [(name: String, description: String)] = []
    @State private var state = ""
    
    var body: some View {
        VStack {
            ZStack {
                Rectangle()
                    .foregroundStyle(.linearGradient(colors: [.white, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height:600)
                Text("Choose Your State")
                    .font(.title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .offset(y:-130)
                Rectangle()
                    .frame(height:1)
                    .offset(y:-110)
                
                MapReader { proxy in
                    Map()
                        .frame(height: 420)
                        .offset(y: 100)
                        .mapStyle(.hybrid)
                        .onTapGesture { position in
                            if let coordinate = proxy.convert(position, from: .global) {
                                self.fetchCountry(from: coordinate)
                                self.fetchParks()
                            }
                        }
                }
                
            }
            .frame(height:400)
            .ignoresSafeArea()
            
            List(self.parksInfo, id: \.name) { park in
                VStack(alignment: .leading) {
                    Text("Name: \(park.name)")
                        .font(.headline)
                    Text("Description: \(park.description)")
                        .font(.subheadline)
                }
            }
            .onTapGesture {
                self.fetchParks()
            }
        }
    }
    
    private func fetchCountry(from coordinate: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Error in reverse geocoding: \(error.localizedDescription)")
                return
            }
                
            if let placemark = placemarks?.first {
                DispatchQueue.main.async {
                    let postalAddress = placemark.postalAddress
                    self.state = postalAddress?.state ?? ""
                }
            }
        }
    }

    private func fetchParks() {
        if self.state == "" {
            return
        }
        
        let endpoint = "https://developer.nps.gov/api/v1/parks?stateCode=" + self.state
        let apiKey = "pW71az0TZOmElqWQlbC2HOcnjLOkKNGeUyyfdRnF"

        guard let url = URL(string: endpoint) else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-Api-Key")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            do {
                let parkResponse = try JSONDecoder().decode(ParkResponse.self, from: data)
                DispatchQueue.main.async {
                    self.parksInfo = parkResponse.data.map { park in
                        (name: park.name, description: park.description)
                    }
                }
            } catch {
                print("JSON parsing error: \(error.localizedDescription)")
            }
        }.resume()
    }
        
}

struct test_Previews: PreviewProvider {
    static var previews: some View {
        test()
    }
}

struct Park: Codable {
    let name: String
    let description: String
}

struct ParkResponse: Codable {
    let data: [Park]
}
