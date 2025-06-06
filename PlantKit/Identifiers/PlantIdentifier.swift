//
//  PlantIdentifier.swift
//  PlantKit
//
//  Created by Khuong Pham on 6/6/25.
//

import SwiftUI

struct PlantIdentifier {
    static func identify(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        print("Starting request...")
        
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            completion(.failure(NSError(domain: "EncodingError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to encode image."])))
            return
        }

        let base64Image = imageData.base64EncodedString()
//        let endpoint = URL(string: "http://127.0.0.1:5001/plantkit-c6c69/us-central1/identifyPlant")!
        let endpoint = URL(string: "https://us-central1-plantkit-c6c69.cloudfunctions.net/identifyPlant")!
        print("Endpoint URL:", endpoint)
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60
        
        let body: [String: Any] = ["image": base64Image]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            print("Request body created successfully")
        } catch {
            print("Error creating request body:", error)
            completion(.failure(error))
            return
        }
        
        print("Starting network request...")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            print("Received response or error")
            
            if let error = error {
                print("Network error:", error)
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status code:", httpResponse.statusCode)
            }
            
            guard let data = data else {
                print("No data received")
                completion(.failure(NSError(domain: "NoDataError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received."])))
                return
            }
            
            // Print raw response
            if let responseString = String(data: data, encoding: .utf8) {
                print("Raw response:", responseString)
            }
            
            do {
                // First try to decode as error response
                if let errorResponse = try? JSONDecoder().decode([String: String].self, from: data),
                   let errorMessage = errorResponse["error"] {
                    print("Error response received:", errorMessage)
                    completion(.failure(NSError(domain: "APIError", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                    return
                }
                
                // Then try to decode as success response
                let result = try JSONDecoder().decode([String: String].self, from: data)
                if let plantName = result["plantName"] {
                    print("Successfully decoded response")
                    completion(.success(plantName))
                } else {
                    print("No plantName in response")
                    completion(.failure(NSError(domain: "InvalidResponseError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format."])))
                }
            } catch {
                print("Decoding error:", error)
                completion(.failure(error))
            }
        }
        task.resume()
        print("Network request initiated")
    }
}

struct OpenAIResponse: Decodable {
    struct Choice: Decodable {
        struct Message: Decodable {
            let role: String
            let content: String
        }
        let message: Message
    }

    let choices: [Choice]
}
