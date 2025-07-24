import SwiftUI

struct HealthCheck {
    struct Diagnosis: Decodable {
        let healthScore: Int
        let overallCondition: String
        let diseaseRisk: String
        let healthIssues: [String]
        let recommendations: [String]
        let quickHack: String?
    }

    static func diagnose(image: UIImage, completion: @escaping (Result<Diagnosis, Error>) -> Void) {
        print("HealthCheck: Starting request...")
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            print("HealthCheck: Failed to encode image")
            completion(.failure(NSError(domain: "EncodingError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to encode image."])) )
            return
        }
        let base64Image = imageData.base64EncodedString()
        let endpoint = URL(string: "https://us-central1-plantkit-c6c69.cloudfunctions.net/diagnosePlant")!
        print("HealthCheck: Endpoint URL:", endpoint)
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60
        let body: [String: Any] = ["image": base64Image]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            print("HealthCheck: Request body created successfully")
        } catch {
            print("HealthCheck: Error creating request body:", error)
            completion(.failure(error))
            return
        }
        print("HealthCheck: Starting network request...")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            print("HealthCheck: Received response or error")
            if let error = error {
                print("HealthCheck: Network error:", error)
                completion(.failure(error))
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                print("HealthCheck: HTTP Status code:", httpResponse.statusCode)
            }
            guard let data = data else {
                print("HealthCheck: No data received")
                completion(.failure(NSError(domain: "NoDataError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received."])) )
                return
            }
            // Print raw response
            if let responseString = String(data: data, encoding: .utf8) {
                print("HealthCheck: Raw response:", responseString)
            }
            do {
                // First try to decode as error response
                if let errorResponse = try? JSONDecoder().decode([String: String].self, from: data),
                   let errorMessage = errorResponse["error"] {
                    print("HealthCheck: Error response received:", errorMessage)
                    completion(.failure(NSError(domain: "APIError", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                    return
                }
                // Try to decode as Diagnosis
                let diagnosis = try JSONDecoder().decode(Diagnosis.self, from: data)
                print("HealthCheck: Successfully decoded Diagnosis")
                completion(.success(diagnosis))
            } catch {
                print("HealthCheck: Decoding error:", error)
                completion(.failure(error))
            }
        }
        task.resume()
        print("HealthCheck: Network request initiated")
    }
} 