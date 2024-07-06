//
//  LoginView.swift
//  blendr
//
//  Created by Andrew Nielson on 6/23/24.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var viewModelAuth: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                Image("blendrNoText")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .padding(.vertical, 32)
                
                VStack(spacing: 24) {
                    TextInputView(text: $email, title: "Email Address", placeholder: "name@example.com")
                        .autocapitalization(.none)
                        .onChange(of: email) { _ in
                            viewModelAuth.authError = ""
                        }
                    
                    TextInputView(text: $password, title: "Password", placeholder: "Enter your password", isSecureField: true)
                        .onChange(of: email) { _ in
                            viewModelAuth.authError = ""
                        }
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                if let errorMessage = viewModelAuth.authError {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                Button {
                    Task {
                        await viewModelAuth.signIn(withEmail: email, password: password)
                    }
                } label: {
                    HStack {
                        Text("SIGN IN")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundStyle(.white)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                }
                .background(Color(hex: 0x002247))
                .opacity(formIsValid ? 1.0 : 0.5)
                .disabled(!formIsValid)
                .cornerRadius(10)
                .padding(.top, 24)
                
                Spacer()
                
                NavigationLink {
                    RegistrationView()
                        .navigationBarBackButtonHidden()
                } label: {
                    HStack(spacing: 3) {
                        Text("Don't have an account?")
                        Text("Sign up")
                            .fontWeight(.bold)
                    }
                    .font(.system(size: 14))
                    .foregroundStyle(Color(hex: 0x002247))
                }
                
            }
        }
    }
}

extension LoginView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty && email.contains("@") && !password.isEmpty && password.count > 5
    }
}
