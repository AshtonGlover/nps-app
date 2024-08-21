//
//  LoginScreen.swift
//  NPSSuggestions
//
//  Created by Ashton Glover on 8/21/24.
//

import Foundation
import SwiftUI

struct LoginScreen: View {
    @State private var isLoggedIn = false
    
    var body: some View {
        NavigationView {
            Text("Login screen")
            
            NavigationLink(destination: MapView(), isActive: $isLoggedIn) {
                EmptyView()
            }
        }
    }
}

struct LoginScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreen()
    }
}
