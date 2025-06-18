import SwiftUI
import Combine

class HealthCheckManager: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastDiagnosis: HealthCheck.Diagnosis?
    private var cancellables = Set<AnyCancellable>()
    
    func diagnose(image: UIImage, completion: @escaping (Result<Void, Error>) -> Void) {
        isLoading = true
        errorMessage = nil
        lastDiagnosis = nil
        HealthCheck.diagnose(image: image) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else {
                    completion(.failure(NSError(domain: "HealthCheckManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Manager was deallocated"])))
                    return
                }
                self.isLoading = false
                switch result {
                case .success(let diagnosis):
                    print("HealthCheckManager: Diagnosis: \(diagnosis)")
                    self.lastDiagnosis = diagnosis
                    completion(.success(()))
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    print("HealthCheckManager: Error: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
    }
} 