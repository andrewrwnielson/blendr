//
//  InputView.swift
//  blendr
//
//  Created by Andrew Nielson on 6/27/24.
//

import SwiftUI
import Speech
import AVFoundation

struct InputView: View {
    // State properties
    @State private var selectedSegmentFoodDrink = 0
    @State private var selectedSegmentBLDD = 0
    @State private var selectedMealType: String = "Breakfast"
    @State private var occasion: String = ""
    @State private var preferences: String = ""
    @State private var ingredients: String = ""
    @FocusState private var isOccasionFocused: Bool
    @FocusState private var isPreferencesFocused: Bool
    @FocusState private var isIngredientsFocused: Bool
    @State private var showTextInput = false
    @State private var showVoiceInput = false
    @EnvironmentObject var authViewModel: AuthViewModel
    @Binding var isCardStackPresented: Bool
    @Binding var isPresented: Bool
    @Binding var isFood: Bool
    @State private var alcohol: Bool = false
    @StateObject var viewModel: CardsViewModel
    @EnvironmentObject var interstitialAdsManager: InterstitialAdsManager
    @State private var hasAdShowed: Bool = false
    
    @State private var adLoadTimeoutOccurred = false
    
    // Speech recognition properties
    @State private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?
    @State private var audioEngine = AVAudioEngine()
    @State private var transcribedText = ""
    
    let selectAlcoholTip = SelectAlcoholTip()
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    if viewModel.isLoading {
                        GeneratingRecipesView()
                            .onAppear() {
                                if !hasAdShowed {
                                    interstitialAdsManager.displayInterstitialAd()
                                    hasAdShowed = true
                                }
                            }
                    } else {
                        HStack {
                            if !isFood {
                                Button(action: {
                                    alcohol.toggle()
                                    selectAlcoholTip.invalidate(reason: .actionPerformed)
                                }) {
                                    Image(alcohol ? "alcohol" : "noAlcohol")
                                        .resizable()
                                        .scaledToFit()
                                        .padding(1)
                                        .background(alcohol ? Color.green : Color.red)
                                        .clipShape(Circle())
                                        .foregroundColor(.white)
                                        .popoverTip(selectAlcoholTip)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .frame(width: 35, height: 35)
                            } else {
                                Circle()
                                    .frame(width: 35)
                                    .foregroundStyle(.white)
                            }
                            
                            Spacer()
                            
                            if isFood {
                                Text("Food")
                                    .font(.title)
                                    .bold()
                                    .foregroundStyle(Color(hex: 0x002247))
                            } else {
                                Text("Drinks")
                                    .bold()
                                    .font(.title)
                                    .foregroundStyle(Color(hex: 0x002247))
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                withAnimation {
                                    isPresented = false
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .resizable()
                                    .frame(width: 35, height: 35)
                                    .foregroundStyle(Color(hex: 0x002247))
                            }
                        }
                        
                        Spacer()
                        
                        Image(isFood ? "food" : "drinks")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.height / 4)
                        
                        Spacer()
                        
                        if isFood {
                            Picker("Select", selection: $selectedSegmentBLDD) {
                                Text("Bfast").tag(0)
                                Text("Lunch").tag(1)
                                Text("Dinner").tag(2)
                                Text("Dessert").tag(3)
                                Text("Snack").tag(4)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .foregroundStyle(Color(hex: 0x002247))
                            .padding(.vertical)
                            .onChange(of: selectedSegmentBLDD) { newValue in
                                selectedMealType = mealType(for: newValue)
                            }
                        }
                        
                        // Occasion
                        HStack {
                            Text("What's the occasion?")
                                .fontWeight(.bold)
                                .foregroundStyle(Color(hex: 0x002247))
                            Text("Optional")
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                            Spacer()
                            Button(action: {
                                isOccasionFocused = false
                            }) {
                                if isOccasionFocused {
                                    Image(systemName: "keyboard.chevron.compact.down.fill")
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                        .foregroundStyle(Color(hex: 0x002247))
                                }
                            }
                        }
                        .padding(.top)
                        .padding(.bottom, 3)
                        
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $occasion)
                                .focused($isOccasionFocused)
                                .keyboardType(.alphabet)
                                .disableAutocorrection(true)
                                .padding(10)
                                .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.gray, lineWidth: 1))
                                .frame(height: geometry.size.height / 9)
                            
                            if occasion.isEmpty {
                                Text(isFood ? "E.g., 'Family gathering on a weekend...'" : "E.g., 'Cocktail party on a Friday night...'")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 13)
                                    .padding(.top, 18)
                                    .onTapGesture {
                                        isOccasionFocused = true
                                    }
                            }
                        }
                        .onTapGesture {
                            isOccasionFocused = true
                        }
                        
                        // Preferences
                        HStack {
                            Text("What do you like?")
                                .fontWeight(.bold)
                                .foregroundStyle(Color(hex: 0x002247))
                            Text("Optional")
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                            Spacer()
                            Button(action: {
                                isPreferencesFocused = false
                            }) {
                                if isPreferencesFocused {
                                    Image(systemName: "keyboard.chevron.compact.down.fill")
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                        .foregroundStyle(Color(hex: 0x002247))
                                }
                            }
                        }
                        .padding(.top)
                        .padding(.bottom, 3)
                        
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $preferences)
                                .focused($isPreferencesFocused)
                                .keyboardType(.alphabet)
                                .disableAutocorrection(true)
                                .padding(10)
                                .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.gray, lineWidth: 1))
                                .frame(height: geometry.size.height / 9)
                            
                            if preferences.isEmpty {
                                Text(isFood ? "E.g., 'We enjoy BBQ, salads, and desserts...'" : "E.g., 'We enjoy fruity cocktails, sparkling drinks, and mocktails...'")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 13)
                                    .padding(.top, 18)
                                    .onTapGesture {
                                        isPreferencesFocused = true
                                    }
                            }
                        }
                        .onTapGesture {
                            isPreferencesFocused = true
                        }
                        
                        if showTextInput {
                            VStack(spacing: 0) {
                                HStack {
                                    Text("What ingredients do you have?")
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color(hex: 0x002247))
                                    Text("Optional")
                                        .font(.subheadline)
                                        .foregroundStyle(.gray)
                                    
                                    Spacer()
                                    
                                    if isIngredientsFocused {
                                        Button(action: {
                                            isIngredientsFocused = false
                                        }) {
                                            if isIngredientsFocused {
                                                Image(systemName: "keyboard.chevron.compact.down.fill")
                                                    .resizable()
                                                    .frame(width: 25, height: 25)
                                                    .foregroundStyle(Color(hex: 0x002247))
                                            }
                                        }
                                    } else {
                                        Button(action: {
                                            showTextInput = false
                                        }) {
                                            Image(systemName: "arrow.left.circle.fill")
                                                .resizable()
                                                .frame(width: 25, height: 25)
                                                .foregroundStyle(Color(hex: 0x002247))
                                                .fontWeight(.bold)
                                        }
                                    }
                                }
                                .padding(.top)
                                .padding(.bottom, 3)
                                
                                ZStack(alignment: .topLeading) {
                                    TextEditor(text: $ingredients)
                                        .focused($isIngredientsFocused)
                                        .keyboardType(.alphabet)
                                        .disableAutocorrection(true)
                                        .padding(10)
                                        .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.gray, lineWidth: 1))
                                        .frame(height: geometry.size.height / 5)
                                    
                                    if ingredients.isEmpty {
                                        Text(isFood ? "E.g., 'Chicken, rice, broccoli...'" : "E.g., 'Vodka, lime, mint...'")
                                            .foregroundColor(.gray)
                                            .padding(.horizontal, 13)
                                            .padding(.top, 18)
                                            .onTapGesture {
                                                isIngredientsFocused = true
                                            }
                                    }
                                }
                                .onTapGesture {
                                    isIngredientsFocused = true
                                }
                            }
                        } else if showVoiceInput {
                            VStack(spacing: 0) {
                                HStack {
                                    Text("What ingredients do you have?")
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color(hex: 0x002247))
                                    Text("Optional")
                                        .font(.subheadline)
                                        .foregroundStyle(.gray)
                                    
                                    Spacer()
                                    
                                    if isIngredientsFocused {
                                        Button(action: {
                                            isIngredientsFocused = false
                                        }) {
                                            if isIngredientsFocused {
                                                Image(systemName: "keyboard.chevron.compact.down.fill")
                                                    .resizable()
                                                    .frame(width: 25, height: 25)
                                                    .foregroundStyle(Color(hex: 0x002247))
                                            }
                                        }
                                    } else {
                                        Button(action: {
                                            showVoiceInput = false
                                            stopRecording()
                                        }) {
                                            Image(systemName: "arrow.left.circle.fill")
                                                .resizable()
                                                .frame(width: 25, height: 25)
                                                .foregroundStyle(Color(hex: 0x002247))
                                                .fontWeight(.bold)
                                        }
                                    }
                                }
                                .padding(.top)
                                .padding(.bottom, 3)
                                
                                ZStack(alignment: .topLeading) {
                                    TextEditor(text: $transcribedText)
                                        .focused($isIngredientsFocused)
                                        .keyboardType(.alphabet)
                                        .disableAutocorrection(true)
                                        .padding(10)
                                        .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.gray, lineWidth: 1))
                                        .frame(height: geometry.size.height / 5)
                                    
                                    if transcribedText.isEmpty {
                                        Text("Listening...")
                                            .foregroundColor(.gray)
                                            .padding(.horizontal, 13)
                                            .padding(.top, 18)
                                    }
                                }
                                .onAppear {
                                    startRecording()
                                }
                                .onDisappear {
                                    stopRecording()
                                }
                                .onChange(of: transcribedText) { newValue in
                                    ingredients = newValue
                                }
                            }
                        } else {
                            let buttonWidth = abs((UIScreen.main.bounds.width - 70) / 3)
                            
                            HStack {
                                Text("What ingredients do you have?")
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color(hex: 0x002247))
                                Text("Optional")
                                    .font(.subheadline)
                                    .foregroundStyle(.gray)
                                Spacer()
                            }
                            .padding(.top)
                            .padding(.bottom, 3)
                            
                            HStack {
                                Button(action: {
                                    isOccasionFocused = false
                                    isPreferencesFocused = false
                                    showTextInput = true
                                }) {
                                    VStack {
                                        Image(systemName: "text.bubble.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .foregroundColor(.white)
                                            .padding(.top, 10)
                                        
                                        Spacer()
                                        
                                        Text("Text")
                                            .font(.subheadline)
                                            .bold()
                                            .foregroundStyle(.white)
                                            .padding(.bottom, 10)
                                    }
                                }
                                .frame(width: buttonWidth, height: buttonWidth)
                                .background(Color(hex: 0x002247))
                                .cornerRadius(20)
                                .padding(5)
                                
                                Button(action: {
                                    isOccasionFocused = false
                                    isPreferencesFocused = false
                                    showVoiceInput = true
                                }) {
                                    VStack {
                                        Image(systemName: "waveform")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .foregroundColor(.white)
                                            .padding(.top, 10)
                                        
                                        Spacer()
                                        
                                        Text("Voice")
                                            .font(.subheadline)
                                            .bold()
                                            .foregroundStyle(.white)
                                            .padding(.bottom, 10)
                                    }
                                }
                                .frame(width: buttonWidth, height: buttonWidth)
                                .background(Color(hex: 0x002247))
                                .cornerRadius(20)
                                .padding(5)
                                
                                ZStack {
                                    VStack {
                                        Image(systemName: "photo")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .foregroundColor(.white)
                                            .padding(.top, 10)
                                        
                                        Spacer()
                                        
                                        Text("Photo")
                                            .font(.subheadline)
                                            .bold()
                                            .foregroundStyle(.white)
                                            .padding(.bottom, 10)
                                        
                                    }
                                    Rectangle()
                                        .fill(LinearGradient(
                                            gradient: Gradient(colors: [Color.gray.opacity(0.6), Color.gray.opacity(0.6)]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        ))
                                        .cornerRadius(20)
                                    Text("Coming Soon...")
                                        .foregroundColor(.white)
                                        .font(.headline)
                                        .padding(.bottom, 25)
                                }
                                .frame(width: buttonWidth, height: buttonWidth)
                                .background(Color(hex: 0x002247))
                                .cornerRadius(20)
                                .padding(5)
                            }
                        }
                        
                        Button(action: {
                            if interstitialAdsManager.interstitialAdLoaded || adLoadTimeoutOccurred {
                                withAnimation {
                                    occasion = isFood ? "\(selectedMealType) \(occasion)" : occasion
                                    preferences = isFood ? preferences : (alcohol ? "alcoholic drink \(preferences)" : "non-alcoholic drink \(preferences)")
                                    Task {
                                        await authViewModel.updateUserAttributes(isFood, occasion, preferences, ingredients, alcohol, selectedMealType)
                                    }
                                    viewModel.generateRecipes(ingredients: ingredients, occasion: occasion, preferences: preferences, isFood: isFood, user: authViewModel.currentUser!) { result in
                                        switch result {
                                        case .success(let recipes):
                                            authViewModel.updateCurrCardStack(with: recipes)
                                            isPresented = false
                                            isCardStackPresented = true
                                        case .failure(let error):
                                            print("Error generating recipes: \(error.localizedDescription)")
                                        }
                                    }
                                }
                            }
                        }) {
                            
                            ZStack {
                                Rectangle()
                                    .frame(height: 55)
                                    .foregroundColor(Color(hex: 0x002247))
                                    .cornerRadius(10)
                                
                                if interstitialAdsManager.interstitialAdLoaded || adLoadTimeoutOccurred {
                                    Text("Generate")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding()
                                } else {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                }
                            }
                        }
                        .padding(.vertical)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                adLoadTimeoutOccurred = true // Set timeout flag after 5 seconds
                            }
                        }
                    }
                }
                .padding(.horizontal, 10)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.white)
            }
        }
    }
    
    func mealType(for index: Int) -> String {
        switch index {
        case 0:
            return "Breakfast "
        case 1:
            return "Lunch "
        case 2:
            return "Dinner "
        case 3:
            return "Dessert "
        case 4:
            return "Small snack, make sure it's not a meal "
        default:
            return ""
        }
    }
    
    private func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            switch authStatus {
            case .authorized:
                print("Speech recognition authorized")
            case .denied, .restricted, .notDetermined:
                print("Speech recognition not authorized")
            @unknown default:
                print("Unknown authorization status")
            }
        }
    }
    private func startRecording() {
        recognitionTask?.cancel()
        recognitionTask = nil
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to set up audio session")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            print("Failed to create request")
            return
        }
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Failed to start audio engine")
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                self.transcribedText = result.bestTranscription.formattedString
                self.ingredients = self.transcribedText // Ensure real-time update of ingredients
            }
            
            if error != nil || result?.isFinal == true {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        }
    }
    
    private func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
    }
}
