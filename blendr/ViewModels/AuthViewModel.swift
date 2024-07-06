//
//  AuthViewModel.swift
//  blendr
//
//  Created by Andrew Nielson on 6/23/24.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import Combine

protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User? {
        didSet {
            objectWillChange.send() // Notify views when currentUser changes
        }
    }
    @Published var authError: String?
    @Published var isLoading: Bool = false
    @Published var isNewUser: Bool = false
    @Published var isLikedRecipesPresented = false
    @Published var selectedTab: Int = 1
    var cancellables = Set<AnyCancellable>()
    
    init() {
        self.userSession = Auth.auth().currentUser
        print("DEBUG: User session initialized: \(self.userSession != nil)")
        
        if self.userSession != nil {
            Task {
                await fetchUser()
            }
        }
    }
    
    func signIn(withEmail email: String, password: String) async {
        isLoading = true
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
        } catch let error as NSError {
            handleAuthError(error)
        }
        isLoading = false
    }
    
    func createUser(withEmail email: String, password: String, fullname: String) async {
        isLoading = true
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = User(
                id: result.user.uid,
                fullname: fullname,
                email: email,
                subscription: 0,
                swipes: 10
            )
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id!).setData(encodedUser)
            await fetchUser()
            isNewUser = true
        } catch let error as NSError {
            handleAuthError(error)
        }
        isLoading = false
    }
    
    func updateAllergies(_ allergies: String) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            try await Firestore.firestore().collection("users").document(uid).updateData(["allergies": allergies])
            self.currentUser?.allergies = allergies
        } catch {
            print("DEBUG: Failed to update allergies with error \(error.localizedDescription)")
        }
    }
    
    func updateDiets(_ diets: String) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            try await Firestore.firestore().collection("users").document(uid).updateData(["diets": diets])
            self.currentUser?.diets = diets
        } catch {
            print("DEBUG: Failed to update diets with error \(error.localizedDescription)")
        }
    }
    
    func updateEquipment(_ equipment: [String]) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            try await Firestore.firestore().collection("users").document(uid).updateData(["equipment": equipment])
            self.currentUser?.equipment = equipment
        } catch {
            print("DEBUG: Failed to update equipment with error \(error.localizedDescription)")
        }
    }
    
    func updateUserAttributes(_ isFood: Bool, _ occasion: String, _ preferences: String, _ ingredients: String, _ alcohol: Bool, _ mealType: String) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            let data: [String: Any] = [
                "isFood": isFood,
                "occasion": isFood ? mealType + occasion : occasion,
                "preferences":  isFood ? preferences : (alcohol ? "alcoholic drink " + preferences : "non-alcoholic drink " + preferences),
                "ingredients": ingredients
            ]
            
            try await Firestore.firestore().collection("users").document(uid).updateData(data)
            
            if var currentUser = self.currentUser {
                currentUser.isFood = isFood
                currentUser.occasion = occasion
                currentUser.preferences = preferences
                currentUser.ingredients = ingredients
                self.currentUser = currentUser
            }
        } catch {
            print("DEBUG: Failed to update user attributes with error \(error.localizedDescription)")
        }
    }
    
    func updateCurrCardStack(with recipes: [Recipe]) {
        DispatchQueue.main.async {
            self.currentUser?.currCardStack = recipes
            print("DEBUG: currCardStack updated with \(recipes.count) recipes.")
            
            guard let user = self.currentUser else { return }
            let docRef = Firestore.firestore().collection("users").document(user.id!)
            do {
                try docRef.setData(from: user)
                print("DEBUG: Card stack updated in Firestore.")
                // Notify the UI about the change
                self.objectWillChange.send()
            } catch {
                print("Error updating user: \(error.localizedDescription)")
            }
        }
    }
    
    func updateHideNutrition(_ hide: Bool) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            try await Firestore.firestore().collection("users").document(uid).updateData(["hideNutrition": hide])
            self.currentUser?.hideNutrition = hide
        } catch {
            print("Failed to update hide nutrition preference with error \(error.localizedDescription)")
        }
    }
    
    func updateProfileIcon(_ icon: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Task {
            do {
                try await Firestore.firestore().collection("users").document(uid).updateData(["profileIcon": icon])
                self.currentUser?.profileIcon = icon
            } catch {
                print("DEBUG: Failed to update profile icon with error \(error.localizedDescription)")
            }
        }
    }
    
    func updateLikedRecipesInFirestore() async {
        guard let user = currentUser else { return }
        let docRef = Firestore.firestore().collection("users").document(user.id!)
        do {
            try docRef.setData(from: user)
            print("DEBUG: Liked recipes updated in Firestore.")
            await fetchUser() // Fetch the updated user data
        } catch {
            print("Error updating liked recipes: \(error.localizedDescription)")
        }
    }
    
    func fetchCurrCardStack() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
            if let user = try? snapshot.data(as: User.self) {
                await MainActor.run {
                    self.currentUser?.currCardStack = user.currCardStack
                }
                print("DEBUG: currCardStack reloaded with \(user.currCardStack.count) recipes.")
            }
        } catch {
            print("DEBUG: Failed to fetch currCardStack: \(error.localizedDescription)")
        }
    }

    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("DEBUG: No user is currently logged in.")
            return
        }
        do {
            let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
            if snapshot.exists {
                self.currentUser = try snapshot.data(as: User.self)
                print("DEBUG: Current user fetched")
            } else {
                print("DEBUG: User document does not exist.")
                try Auth.auth().signOut()
                DispatchQueue.main.async {
                    self.userSession = nil
                    self.currentUser = nil
                    self.isNewUser = false
                }
            }
        } catch {
            print("DEBUG: Failed to fetch user data: \(error.localizedDescription)") // user is corrupt
            await deleteAccount()
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
            isNewUser = false
        } catch {
            print("DEBUG: Failed to sign out with error \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func deleteAccount() async {
        guard let user = Auth.auth().currentUser else { return }
        do {
            // Delete the user's document from Firestore
            try await Firestore.firestore().collection("users").document(user.uid).delete()
            print("DEBUG: User data deleted from Firestore.")
            
            // Delete the user's authentication record
            try await user.delete()
            print("DEBUG: User account deleted.")
            
            // Reset local user session and currentUser data
            self.userSession = nil
            self.currentUser = nil
            isNewUser = false
        } catch {
            print("DEBUG: Failed to delete account with error \(error.localizedDescription)")
            authError = "Failed to delete account: \(error.localizedDescription)"
        }
    }
    
    @MainActor
    func reauthenticateUser(email: String, password: String) async throws {
        guard let user = Auth.auth().currentUser else { return }
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        do {
            try await user.reauthenticate(with: credential)
        } catch {
            throw error
        }
    }
    
    func saveRecipe(_ recipe: Recipe) async {
        guard var currentUser = currentUser else { return }
        // Check if the recipe is already saved
        if !currentUser.savedRecipes.contains(where: { $0.id == recipe.id }) {
            currentUser.savedRecipes.append(recipe)
            self.currentUser = currentUser
            do {
                let docRef = Firestore.firestore().collection("users").document(currentUser.id!)
                try docRef.setData(from: currentUser)
                print("DEBUG: Recipe successfully saved to Firestore.")
            } catch {
                print("Error saving recipe: \(error.localizedDescription)")
            }
        }
    }
    
    func unsaveRecipe(_ recipe: Recipe) async {
        guard var currentUser = currentUser else { return }
        if let index = currentUser.savedRecipes.firstIndex(where: { $0.id == recipe.id }) {
            currentUser.savedRecipes.remove(at: index)
            self.currentUser = currentUser
            do {
                let docRef = Firestore.firestore().collection("users").document(currentUser.id!)
                try docRef.setData(from: currentUser)
                print("DEBUG: Recipe successfully removed from Firestore.")
            } catch {
                print("Error removing recipe: \(error.localizedDescription)")
            }
        }
    }

    func isRecipeSaved(_ recipe: Recipe) -> Bool {
        guard let currentUser = currentUser else { return false }
        return currentUser.savedRecipes.contains(where: { $0.id == recipe.id })
    }
    
    func fetchSavedRecipes() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
            if let user = try? snapshot.data(as: User.self) {
                await MainActor.run {
                    self.currentUser?.savedRecipes = user.savedRecipes
                }
            }
        } catch {
            print("DEBUG: Failed to fetch saved recipes: \(error.localizedDescription)")
        }
    }
    
    func updateRecipeSteps(recipeId: UUID, steps: [String]) {
        if let index = currentUser?.likedRecipes.firstIndex(where: { $0.id == recipeId }) {
            currentUser?.likedRecipes[index].steps = steps
        }
    }
    
    func limitLikedRecipesTo50MostRecent() {
        guard var currentUser = currentUser else { return }
        if currentUser.likedRecipes.count > 50 {
            currentUser.likedRecipes = Array(currentUser.likedRecipes.suffix(50))
            self.currentUser = currentUser
            Task {
                do {
                    let docRef = Firestore.firestore().collection("users").document(currentUser.id!)
                    try docRef.setData(from: currentUser)
                    print("DEBUG: Liked recipes limited to 50 most recent in Firestore.")
                } catch {
                    print("Error updating liked recipes: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @MainActor
    func updateUserSwipes(_ swipes: Int) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            try await Firestore.firestore().collection("users").document(uid).updateData(["swipes": swipes])
            self.currentUser?.swipes = swipes
        } catch {
            print("DEBUG: Failed to update swipes with error \(error.localizedDescription)")
        }
    }

    @MainActor
    func updateUserSubscription(_ subscription: Int) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            try await Firestore.firestore().collection("users").document(uid).updateData(["subscription": subscription])
            self.currentUser?.subscription = subscription
        } catch {
            print("DEBUG: Failed to update subscription with error \(error.localizedDescription)")
        }
    }
    
    private func handleAuthError(_ error: NSError) {
        guard let errorCode = AuthErrorCode.Code(rawValue: error.code) else {
            authError = "An unknown error occurred. Please try again."
            return
        }

        switch errorCode {
        case .networkError:
            authError = "Network error. Please try again."
        case .userNotFound:
            authError = "User not found. Please check your email and try again."
        case .userTokenExpired:
            authError = "Session expired. Please sign in again."
        case .tooManyRequests:
            authError = "Too many requests. Please try again later."
        case .invalidEmail:
            authError = "Invalid email address. Please check and try again."
        case .userDisabled:
            authError = "This account has been disabled."
        case .wrongPassword:
            authError = "Incorrect password. Please try again."
        case .emailAlreadyInUse:
            authError = "The email address is already in use."
        case .weakPassword:
            authError = "The password is too weak."
        case .operationNotAllowed:
            authError = "Operation not allowed. Please contact support."
        case .invalidCredential:
                authError = "Invalid credentials. Please check your email and password."
        default:
            authError = "An unknown error occurred. Please try again."
        }
    }
}
