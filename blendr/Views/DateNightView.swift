//
//  DateNightView.swift
//  blendr
//
//  Created by Andrew Nielson on 6/23/24.
//

import SwiftUI

struct DateNightView: View {
    @Binding var isPresented: Bool
    @Binding var isCardStackPresented: Bool // New binding for CardStackView
    @State private var prompt: String = ""
    @FocusState private var isFocused: Bool
    @StateObject var viewModel: DateNightViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack {
                    if viewModel.isLoading {
                        GeneratingRecipesView()
                    } else {
                        HStack {
                            Spacer()
                            Button(action: {
                                isPresented = false
                            }) {
                                Image(systemName: "arrow.down.circle.fill")
                                    .resizable()
                                    .frame(width: 35, height: 35)
                                    .padding()
                                    .foregroundStyle(Color(hex: 0x002247))
                            }
                        }
                        .frame(width: geometry.size.width)
                        .background(Color.white)
                        
                        Image("DateNightViewIcon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: geometry.size.width)
                        
                        Spacer()
                        
                        VStack(spacing: 0) {
                            HStack {
                                Text("What do you like?")
                                    .padding(.horizontal)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color(hex: 0x002247))
                                
                                Spacer()
                            }
                            
                            ZStack(alignment: .topLeading) {
                                TextEditor(text: $prompt)
                                    .focused($isFocused)
                                    .padding(10)
                                    .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.gray, lineWidth: 1))
                                    .frame(height: geometry.size.height / 3)
                                    .padding()
                                
                                if prompt.isEmpty {
                                    Text("E.g., 'We like chicken, pasta, and spicy food...'")
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 30)
                                        .padding(.top, 35)
                                        .onTapGesture {
                                            isFocused = true
                                        }
                                }
                            }
                            .onTapGesture {
                                isFocused = true
                            }
                            
                            Button(action: {
                                withAnimation {
                                    viewModel.isLoading = true
                                    Task {
                                        await authViewModel.updateIngredients("any")
                                        await authViewModel.updateOccasion("Date night")
                                        await authViewModel.updatePreferences(prompt)
                                    }
                                    viewModel.generateMeal(preferences: prompt, user: authViewModel.currentUser!) { result in
                                        switch result {
                                        case .success(let recipes):
                                            authViewModel.updateCurrCardStack(with: recipes)
                                            viewModel.isLoading = false
                                            isPresented = false
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                isCardStackPresented = true // Trigger CardStackView
                                            }
                                        case .failure(let error):
                                            print("Error generating recipes: \(error.localizedDescription)")
                                            viewModel.isLoading = false
                                        }
                                    }
                                }
                            }) {
                                Text("Generate")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color(hex: 0x002247))
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.white)
            }
        }
    }
}
