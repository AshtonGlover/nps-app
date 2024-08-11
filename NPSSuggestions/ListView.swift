//
//  ListView.swift
//  NPSSuggestions
//
//  Created by Ashton Glover on 8/11/24.
//

import SwiftUI
import Foundation

struct ListView: View {
    @State private var parksInfo: [(name: String, description: String)] = []
    @State private var stateChosen = ""

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
                
                //map goes here
                
            }
            .frame(height:400)
            .ignoresSafeArea()
            
            List(parksInfo, id: \.name) { park in
                VStack(alignment: .leading) {
                    Text("Name: \(park.name)")
                        .font(.headline)
                    Text("Description: \(park.description)")
                        .font(.subheadline)
                }
            }
            .onAppear {
                fetchParks()
            }
            
            if stateChosen == "" {
                Text("Choose a state to output data.")
                    .offset(y:-150)
            }
        }
    }

    private func fetchParks() {
        if stateChosen == "" {
            return
        }
        
        let endpoint = "https://developer.nps.gov/api/v1/parks?stateCode=hi"
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

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}

struct Park: Codable {
    let name: String
    let description: String
}

struct ParkResponse: Codable {
    let data: [Park]
}
