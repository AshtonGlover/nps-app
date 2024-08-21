//
//  MapView.swift
//  NPSSuggestions
//
//  Created by Ashton Glover on 8/11/24.
//

import SwiftUI
import Foundation
import MapKit
import CoreLocation

struct MapView: View {
    @State private var parksInfo: [(name: String, description: String, imageURL: String)] = []
    @State private var state = "Choose Your State"

    var abbrToState: [String: String] = [
        "AL": "Alabama ",
        "AK": "Alaska",
        "AZ": "Arizona",
        "AR": "Arkansas",
        "CA": "California",
        "CO": "Colorado",
        "CT": "Connecticut",
        "DE": "Delaware",
        "FL": "Florida",
        "GA": "Georgia",
        "HI": "Hawaii",
        "ID": "Idaho",
        "IL": "Illinois",
        "IN": "Indiana",
        "IA": "Iowa",
        "KS": "Kansas",
        "KY": "Kentucky",
        "LA": "Louisiana",
        "ME": "Maine",
        "MD": "Maryland",
        "MA": "Massachusetts",
        "MI": "Michigan",
        "MN": "Minnesota",
        "MS": "Mississippi",
        "MO": "Missouri",
        "MT": "Montana",
        "NE": "Nebraska",
        "NV": "Nevada",
        "NH": "New Hampshire",
        "NJ": "New Jersey",
        "NM": "New Mexico",
        "NY": "New York",
        "NC": "North Carolina",
        "ND": "North Dakota",
        "OH": "Ohio",
        "OK": "Oklahoma",
        "OR": "Oregon",
        "PA": "Pennsylvania",
        "RI": "Rhode Island",
        "SC": "South Carolina",
        "SD": "South Dakota",
        "TN": "Tennessee",
        "TX": "Texas",
        "UT": "Utah",
        "VT": "Vermont",
        "VA": "Virginia",
        "WA": "Washington",
        "WV": "West Virginia",
        "WI": "Wisconsin",
        "WY": "Wyoming"
    ]
    
    var body: some View {
        VStack {
            ZStack {
                Rectangle()
                    .foregroundStyle(.linearGradient(colors: [.green, .brown], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height:600)
                Text(abbrToState[self.state] ?? "Choose Your State")
                    .font(.title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .offset(y:-130)
                    .foregroundColor(.white)
                Rectangle()
                    .frame(height:1)
                    .offset(y:-110)
                
                MapReader { proxy in
                    Map()
                        .frame(height: 420)
                        .offset(y: 100)
                        .mapStyle(.standard(showsTraffic: true))
                        .onTapGesture { position in
                            if let coordinate = proxy.convert(position, from: .global) {
                                self.fetchState(from: coordinate)
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
                    AsyncImage(url: URL(string: park.imageURL)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(8)
                        case .failure:
                            Image(systemName: "exclamationmark.triangle")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .foregroundColor(.red)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                .foregroundColor(.black)
            }
            .onTapGesture {
                self.fetchParks()
            }
        }
    }
    
    private func fetchState(from coordinate: CLLocationCoordinate2D) {
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
                    self.fetchParks()
                }
            }
        }
    }

    private func fetchParks() {
        if (self.state == "" || self.state == "Choose Your State") {
            return
        }
        
        let endpoint = "https://developer.nps.gov/api/v1/parks?stateCode=" + self.state
        
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
                        let imageUrl = park.images.first?.url ?? "No image available"
                        return (name: park.name, description: park.description, imageURL: imageUrl)
                    }
                }
            } catch {
                print("JSON parsing error: \(error.localizedDescription)")
            }
        }.resume()
    }
        
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}

struct Park: Codable {
    let name: String
    let description: String
    let images: [ParkImage]
}

struct ParkImage: Codable {
    let url: String
}

struct ParkResponse: Codable {
    let data: [Park]
}
