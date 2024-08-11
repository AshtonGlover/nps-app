//
//  NPSSuggestionsApp.swift
//  NPSSuggestions
//
//  Created by Ashton Glover on 8/10/24.
//

import SwiftUI
import Firebase

@main
struct NPSSuggestionsApp: App {
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
