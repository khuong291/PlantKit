import Foundation
import Combine

class PlantDetailsViewModel: ObservableObject {
    @Published var plantDetails: PlantDetails?
    @Published var isLoading = false
    @Published var errorMessage: String?
    private var cancellables = Set<AnyCancellable>()
    
    func fetchPlantDetails(imageBase64: String) {
        isLoading = true
        errorMessage = nil
        guard let url = URL(string: "YOUR_API_URL_HERE") else {
            self.errorMessage = "Invalid URL"
            self.isLoading = false
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["image": imageBase64]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
            return
        }
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: PlantDetails.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] details in
                self?.plantDetails = details
            })
            .store(in: &cancellables)
    }
} 