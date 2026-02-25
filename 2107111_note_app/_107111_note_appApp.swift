//
//  _107083_note_appApp.swift
//  2107083_note_app
//
//  Created by macos on 21/2/26.
//

import SwiftUI
import Firebase

@main
struct firebasetestApp: App {
    @StateObject private var viewModel: AuthViewModel

    init() {
        FirebaseApp.configure()
        print("Configured Firebase!!!")
        _viewModel = StateObject(wrappedValue: AuthViewModel())
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(viewModel)
        }
    }
}

private struct RootView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        Group {
            if authViewModel.isSignedIn {
                ContentView()
            } else {
                AuthView()
            }
        }
    }
}
