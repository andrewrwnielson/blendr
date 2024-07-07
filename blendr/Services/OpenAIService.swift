//
//  OpenAIService.swift
//  blendr
//
//  Created by Andrew Nielson on 6/23/24.
//

import Foundation
import OpenAI

class OpenAIService {
    private let openAI: OpenAI
    
    init(apiToken: String) {
        self.openAI = OpenAI(apiToken: apiToken)
    }
    
    func generateRecipes(prompt: String, completion: @escaping (Result<[Recipe], Error>) -> Void) {
        guard let systemMessage = ChatQuery.ChatCompletionMessageParam(role: .system, content: "You are a professional cook providing diverse recipes for the average person. If you're given ingredients only use the ingredients specified but not all ingredients have to be used in each recipe. do not combine weird ingredients. Give exactly 10 recipes. You Respond only in JSON format."),
              let userMessage = ChatQuery.ChatCompletionMessageParam(role: .user, content: prompt) else {
            completion(.failure(NSError(domain: "OpenAIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create message parameters."])))
            return
        }
        
        let query = ChatQuery(
            messages: [systemMessage, userMessage],
            model: .gpt3_5Turbo,
            maxTokens: 4096,
            temperature: 1.0,
            topP: 0.9
        )
        
        Task {
            do {
                print("Sending query to OpenAI: \(query)")
                let result = try await openAI.chats(query: query)
                print("Received result from OpenAI: \(result)")
                
                guard let recipeData = result.choices.first?.message.content?.string else {
                    print("Failed to parse response: no content")
                    completion(.failure(NSError(domain: "OpenAI", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response."])))
                    return
                }
                
                do {
                    let recipes = try self.parseRecipes(from: recipeData)
                    completion(.success(recipes))
                } catch {
                    print("Parsing error: \(error)")  // Debug print
                    completion(.failure(error))
                }
            } catch {
                print("Error occurred: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    func generateSteps(prompt: String, completion: @escaping (Result<[String], Error>) -> Void) {
        guard let systemMessage = ChatQuery.ChatCompletionMessageParam(role: .system, content: "Respond only in JSON format."),
              let userMessage = ChatQuery.ChatCompletionMessageParam(role: .user, content: prompt) else {
            completion(.failure(NSError(domain: "OpenAIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create message parameters."])))
            return
        }
        
        let query = ChatQuery(
            messages: [systemMessage, userMessage],
            model: .gpt3_5Turbo,
            maxTokens: 3000
        )
        
        Task {
            do {
                print("Sending query to OpenAI: \(query)")
                let result = try await openAI.chats(query: query)
                print("Received result from OpenAI: \(result)")
                
                guard let stepsData = result.choices.first?.message.content?.string else {
                    print("Failed to parse response: no content")
                    completion(.failure(NSError(domain: "OpenAI", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response."])))
                    return
                }
                
                do {
                    let steps = try self.parseSteps(from: stepsData)
                    completion(.success(steps))
                } catch {
                    print("Parsing error: \(error)")  // Debug print
                    completion(.failure(error))
                }
            } catch {
                print("Error occurred: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    private func parseRecipes(from data: String) throws -> [Recipe] {
        let decoder = JSONDecoder()
        guard let jsonData = data.data(using: .utf8) else {
            throw NSError(domain: "OpenAIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid data format."])
        }

        // Define a wrapper structure that matches the response format
        struct RecipeWrapper: Decodable {
            let recipes: [Recipe]
        }

        let recipeWrapper = try decoder.decode(RecipeWrapper.self, from: jsonData)
        let recipes = recipeWrapper.recipes
        return recipes
    }

    private func parseSteps(from data: String) throws -> [String] {
            let decoder = JSONDecoder()
            guard let jsonData = data.data(using: .utf8) else {
                throw NSError(domain: "OpenAIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid data format."])
            }

            // Define a wrapper structure that matches the response format
            struct StepsWrapper: Decodable {
                let steps: [String]
            }

            let stepsWrapper = try decoder.decode(StepsWrapper.self, from: jsonData)
            let steps = stepsWrapper.steps
            return steps
        }
}
