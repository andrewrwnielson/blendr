//
//  CardService.swift
//  blendr
//
//  Created by Andrew Nielson on 6/23/24.
//

import Foundation

class CardService {
    private let openAIService: OpenAIService

    init(apiToken: String) {
        self.openAIService = OpenAIService(apiToken: apiToken)
    }

    func generateRecipes(prompt: String, completion: @escaping (Result<[Recipe], Error>) -> Void) {
        var attempts = 0
        let maxAttempts = 3

        func attempt() {
            openAIService.generateRecipes(prompt: prompt) { result in
                switch result {
                case .success(let recipes):
                    completion(.success(recipes))
                case .failure(let error):
                    if attempts < maxAttempts {
                        attempts += 1
                        attempt()
                    } else {
                        completion(.failure(error))
                    }
                }
            }
        }

        attempt()
    }
    
    func generateRecipeSteps(prompt: String, completion: @escaping (Result<[String], Error>) -> Void) {
        openAIService.generateSteps(prompt: prompt) { result in
            switch result {
            case .success(let steps):
                completion(.success(steps))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
