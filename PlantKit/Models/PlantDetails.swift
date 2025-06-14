import Foundation

struct PlantDetails: Codable {
    let commonName: String
    let scientificName: String
    let description: String
    let general: General
    let physical: Physical
    let development: Development

    struct General: Codable {
        let habitat: String
        let originCountries: [String]
        let environmentalBenefits: [String]
    }
    struct Physical: Codable {
        let height: String
        let crownDiameter: String
        let form: String
    }
    struct Development: Codable {
        let matureHeightTime: String
        let growthSpeed: Int
        let propagationMethods: [String]
        let cycle: String
    }
} 