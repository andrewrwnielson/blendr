//
//  ReauthenticateView.swift
//  blendr
//
//  Created by Andrew Nielson on 6/24/24.
//

import SwiftUI

struct ReauthenticateView: View {
    @EnvironmentObject var viewModelAuth: AuthViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.down.circle.fill")
                        .foregroundStyle(Color(hex: 0x002247))
                        .imageScale(.large)
                        .font(.system(size: 30))
                }
            }
            
            Spacer()
            
            Text("Re-authenticate to delete your account")
                .font(.headline)
                .padding()

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            if errorMessage != nil {
                Text("Your email and/or password are incorrect. Please try again.")
                    .foregroundColor(.red)
                    .font(.subheadline)
                    .padding()
            }

            Button(action: {
                Task {
                    await reauthenticateAndDeleteAccount()
                }
            }) {
                Text("Delete Account")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .padding()
            
            Spacer()
            
            Text("This action cannot be undone.")
                .foregroundColor(.red)
                .font(.subheadline)
                .padding()
        }
        .padding()
    }

    private func reauthenticateAndDeleteAccount() async {
        do {
            try await viewModelAuth.reauthenticateUser(email: email, password: password)
            try await viewModelAuth.deleteAccount()
            presentationMode.wrappedValue.dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
