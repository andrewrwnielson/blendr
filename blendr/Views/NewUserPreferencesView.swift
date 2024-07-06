//
//  NewUserPreferencesView.swift
//  blendr
//
//  Created by Andrew Nielson on 6/23/24.
//

import SwiftUI

struct NewUserPreferencesView: View {
    @EnvironmentObject var viewModelAuth: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @Binding var isOnboardingCompleted: Bool
    
    @State private var allergies: String = ""
    @State private var diets: String = ""
    @State private var hideNutrition: Bool = false
    @State private var selection = Set<String>()
    
    @FocusState private var isAllergiesFocused: Bool
    @FocusState private var isDietsFocused: Bool
    
    let equipment = [
        "Microwave", "Oven", "Stove", "Toaster", "Coffee Maker", "Blender",
        "Electric Kettle", "Slow Cooker", "Food Processor", "Hand Mixer",
        "Toaster Oven", "Pressure Cooker", "Rice Cooker", "Air Fryer",
        "Stand Mixer", "Waffle Maker", "Grill", "Panini Press", "Juicer",
        "Hand Blender", "Griddle", "Deep Fryer", "Skillet", "Steamer",
        "Bread Maker", "Meat Grinder", "Food Dehydrator", "Pizza Oven",
        "Popcorn Maker"
    ]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 5) {
                        
                        HStack {
                            Text("Set Your Preferences")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(Color(hex: 0x002247))
                            
                            Spacer()
                            
                            VStack {
                                Text("Hide Nutrition")
                                    .multilineTextAlignment(.center)
                                    .bold()// Adjust the font as needed
                                    .foregroundColor(Color(hex: 0x002247)) // Set the text color
                                    .frame(alignment: .center) // Center the text above the toggle

                                Toggle(isOn: $hideNutrition) {
                                    Text("") // Empty text for the toggle label
                                }
                                .toggleStyle(SwitchToggleStyle(tint: Color(hex: 0x002247))) // Set toggle color
                                .labelsHidden() // Hides the default label space for the toggle, since it's empty
                            }
                            .padding() // Add padding around the VStack
                            .frame(maxWidth: 150) // Ensure VStack takes full width to center text effectively
                        }
                        .padding()
                        
                        HStack {
                            Text("Allergies")
                                .fontWeight(.bold)
                                .foregroundStyle(Color(hex: 0x002247))
                            
                            Spacer()
                            
                            Button(action: {
                                isAllergiesFocused = false
                            }) {
                                if isAllergiesFocused {
                                    Image(systemName: "keyboard.chevron.compact.down.fill")
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                        .foregroundStyle(Color(hex: 0x002247))
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $allergies)
                                .focused($isAllergiesFocused)
                                .keyboardType(.alphabet)
                                .disableAutocorrection(true)
                                .padding(10)
                                .background(RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(Color.gray, lineWidth: 1))
                                .frame(height: 100)
                                .padding(.horizontal)
                            
                            if allergies.isEmpty {
                                Text("E.g., 'Peanuts, shellfish, gluten...'")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 30)
                                    .padding(.top, 17)
                                    .onTapGesture {
                                        isAllergiesFocused = true
                                    }
                            }
                        }
                        .onTapGesture {
                            isAllergiesFocused = true
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text("Diets")
                                .fontWeight(.bold)
                                .foregroundStyle(Color(hex: 0x002247))
                            
                            Spacer()
                            
                            Button(action: {
                                isDietsFocused = false
                            }) {
                                if isDietsFocused {
                                    Image(systemName: "keyboard.chevron.compact.down.fill")
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                        .foregroundStyle(Color(hex: 0x002247))
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $diets)
                                .focused($isDietsFocused)
                                .keyboardType(.alphabet)
                                .disableAutocorrection(true)
                                .padding(10)
                                .background(RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(Color.gray, lineWidth: 1))
                                .frame(height: 100)
                                .padding(.horizontal)
                            
                            if diets.isEmpty {
                                Text("E.g., 'Vegan, keto, low-carb...'")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 30)
                                    .padding(.top, 17)
                                    .onTapGesture {
                                        isDietsFocused = true
                                    }
                            }
                        }
                        .onTapGesture {
                            isDietsFocused = true
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Equipment")
                            .padding(.horizontal)
                            .fontWeight(.bold)
                            .foregroundStyle(Color(hex: 0x002247))
                        
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(equipment, id: \.self) { item in
                                Text(item)
                                    .font(.footnote)
                                    .frame(width: 100, height: 50)
                                    .padding(1)
                                    .background(selection.contains(item) ? Color(hex: 0x002247) : Color.gray.opacity(0.2))
                                    .foregroundColor(selection.contains(item) ? .white : Color(hex: 0x002247))
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                    .onTapGesture {
                                        if selection.contains(item) {
                                            selection.remove(item)
                                        } else {
                                            selection.insert(item)
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        Task {
                            await viewModelAuth.updateAllergies(allergies)
                            await viewModelAuth.updateDiets(diets)
                            await viewModelAuth.updateEquipment(Array(selection))
                            await viewModelAuth.updateHideNutrition(hideNutrition)
                            viewModelAuth.isNewUser = false // Reset flag after saving all preferences
                            isOnboardingCompleted = true // Trigger paywall
                            dismiss()
                        }
                    }) {
                        Text("Save Preferences")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(hex: 0x002247))
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .onAppear {
                loadPreferences()
            }
        }
    }
    
    func loadPreferences() {
        if let user = viewModelAuth.currentUser {
            allergies = user.allergies
            diets = user.diets
            selection = Set(user.equipment)
            hideNutrition = user.hideNutrition ?? false
        } else {
            allergies = ""
            diets = ""
            selection = []
            hideNutrition = false
        }
    }
}
