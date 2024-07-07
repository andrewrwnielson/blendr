//
//  RegistrationView.swift
//  blendr
//
//  Created by Andrew Nielson on 6/23/24.
//

import SwiftUI

struct RegistrationView: View {
    @State private var email = ""
    @State private var fullname = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModelAuth: AuthViewModel
    
    var body: some View {
        VStack {
            Image("blendrNoText")
                .resizable()
                .scaledToFill()
                .frame(width: 150, height: 150)
                .padding(.vertical, 32)
                .padding(.top, 32)
            
            VStack(spacing: 24) {
                TextInputView(text: $email, title: "Email Address", placeholder: "name@example.com")
                    .autocapitalization(.none)
                    .onChange(of: email) { _ in
                        viewModelAuth.authError = ""
                    }
                
                TextInputView(text: $fullname, title: "Full Name", placeholder: "Enter your name")
                    .onChange(of: email) { _ in
                        viewModelAuth.authError = ""
                    }
                
                TextInputView(text: $password, title: "Password", placeholder: "Enter your password", isSecureField: true)
                    .onChange(of: email) { _ in
                        viewModelAuth.authError = ""
                    }
                
                ZStack(alignment: .trailing) {
                    TextInputView(text: $confirmPassword, title: "Confirm Password", placeholder: "Confirm your password", isSecureField: true)
                        .onChange(of: email) { _ in
                            viewModelAuth.authError = ""
                        }
                    
                    if !password.isEmpty && !confirmPassword.isEmpty {
                        if password == confirmPassword {
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundStyle(Color(.systemGreen))
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundStyle(Color(.systemRed))
                        }
                    }
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
                    await viewModelAuth.createUser(withEmail: email, password: password, fullname: fullname)
                }
            } label: {
                HStack {
                    Text("SIGN UP")
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
            
            Button(action: {
                dismiss()
            }, label: {
                HStack(spacing: 3) {
                    Text("Already have an account?")
                    Text("Login")
                        .fontWeight(.bold)
                }
                .font(.system(size: 14))
                .foregroundStyle(Color(hex: 0x002247))
            })
            
        }
    }
}

extension RegistrationView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty && email.contains("@") && !password.isEmpty && password.count > 5 && confirmPassword == password && !fullname.isEmpty
    }
}
