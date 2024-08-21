//
//  ContentView.swift
//  NPSSuggestions
//
//  Created by Ashton Glover on 8/10/24.
//

import SwiftUI
import SwiftData
import Firebase
import FirebaseAuth

struct ContentView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var userIsLoggedIn = false
    @State private var navigateToMap = false
    @State private var errorOccurred = ""
    @State private var navigateToLogin = false
    
    var body: some View {
        if userIsLoggedIn {
            MapView()
        } else {
            content
        }
    }
    
    var content: some View {
        NavigationView {
            ZStack {
                Color.black
                
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .foregroundStyle(.linearGradient(colors: [.green, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                
                VStack(spacing: 20) {
                    Text("Welcome")
                        .foregroundColor(.white)
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .offset(y: -200)
                    
                    ZStack(alignment: .leading) {
                        if email.isEmpty {
                            Text("Email")
                                .foregroundColor(.white)
                                .bold()
                        }
                        TextField("", text: $email)
                            .foregroundColor(.white)
                    }
                    
                    Rectangle()
                        .frame(width: 350, height: 1)
                        .foregroundColor(.white)
                    
                    ZStack(alignment: .leading) {
                        if self.password.isEmpty {
                            Text("Password")
                                .foregroundColor(.white)
                                .bold()
                        }
                        SecureField("", text: $password)
                            .foregroundColor(.white)
                    }
                    
                    Rectangle()
                        .frame(width: 350, height: 1)
                        .foregroundColor(.white)
                    
                    Button {
                        self.register()
                    } label: {
                        Text("Sign up")
                            .foregroundColor(.white)
                            .bold()
                            .frame(width: 200, height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(.linearGradient(colors: [.red, .pink], startPoint: .top, endPoint: .bottomTrailing))
                            )
                    }
                    .padding(.top)
                    .offset(y: 100)
                    
                    NavigationLink(destination: MapView()
                                        .navigationBarBackButtonHidden(true)
                                   , isActive: $navigateToMap) {
                        EmptyView()
                    }
                    
                    
                    Button {
                        self.login()
                        self.navigateToLogin = true
                    } label: {
                        Text("Already have an account? Login")
                            .bold()
                            .foregroundColor(.white)
                            .underline()
                    }
                    .padding(.top)
                    .offset(y: 110)
                    
                    NavigationLink(destination: LoginScreen(), isActive: $navigateToLogin) {
                        EmptyView()
                    }
                    
                }
                .frame(width:350)

                if (self.errorOccurred != "") {
                    Text(self.errorOccurred)
                        .offset(y: 80)
                        .foregroundColor(.white)
                }
            }
            .ignoresSafeArea()
        }
    }
    
    
    func register() {
        Auth.auth().createUser(withEmail: self.email, password: self.password) { result, error in
            if error != nil {
                print(error!.localizedDescription)
                self.errorOccurred = error!.localizedDescription
            } else {
                if self.email != "" && self.password != "" {
                    self.userIsLoggedIn = true
                    self.navigateToMap = true
                }
            }
        }
    }
    
    func login() {
        Auth.auth().signIn(withEmail: self.email, password: self.password) { result, error in
            if error == nil {
                if self.email != "" && self.password != "" {
                    self.userIsLoggedIn = true
                }
            } else {
                print(error!.localizedDescription)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
