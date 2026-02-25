//
//  AuthView.swift
//  2107083_note_app
//
//  Created by macos on 24/2/26.
//

import Foundation
import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var email = ""
    @State private var password = ""
    @State private var mode: Mode = .signIn

    enum Mode: String, CaseIterable { case signIn = "Sign In", signUp = "Sign Up" }

    var body: some View {
        NavigationView {
            VStack(spacing: 18) {
                Spacer()

                Image(systemName: "lock.shield")
                    .font(.system(size: 52))
                    .foregroundColor(.accentColor)

                Text("Secure Notes")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Your notes stay private to your account.")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Picker("", selection: $mode) {
                    ForEach(Mode.allCases, id: \.self) { m in
                        Text(m.rawValue).tag(m)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                VStack(spacing: 12) {
                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .textFieldStyle(.roundedBorder)

                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.horizontal)

                Button {
                    if mode == .signIn {
                        authViewModel.signIn(email: email, password: password)
                    } else {
                        authViewModel.signUp(email: email, password: password)
                    }
                } label: {
                    Text(mode == .signIn ? "Sign In" : "Create Account")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(12)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.vertical)
            .navigationBarHidden(true)
        }
    }
}
