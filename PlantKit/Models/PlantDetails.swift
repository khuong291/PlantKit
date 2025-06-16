import Foundation

struct PlantDetails: Codable {
    let id: UUID
    let commonName: String
    let scientificName: String
    let plantDescription: String
    let general: General
    let physical: Physical
    let development: Development
    let conditions: Conditions?
    let createdAt: Date
    let updatedAt: Date

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
    struct Conditions: Codable {
        let climatic: Climatic?
        let soil: Soil?
        let light: Light?
        struct RangeD: Codable {
            let lower: Double
            let upper: Double
        }
        struct RangeI: Codable {
            let lower: Int
            let upper: Int
        }
        struct Climatic: Codable {
            let hardinessZone: [Int] // e.g. [1,2,3,4,5,6,7,8,9,10,11,12,13]
            let minTemperature: Double // e.g. -1.1
            let temperatureRange: RangeD
            let idealTemperatureRange: RangeD
            let humidityRange: RangeI
            let windResistance: String? // e.g. "50km/h"
        }
        struct Soil: Codable {
            let phRange: [Double]
            let phLabel: String
            let types: [String]
        }
        struct Light: Codable {
            let amount: String // e.g. "8 to 12 hrs/day"
            let type: String // e.g. "Full sun"
        }
    }
} 