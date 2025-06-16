import Foundation

struct PlantDetails: Codable, Identifiable, Equatable, Hashable {
    let id: UUID
    let plantImageData: Data
    let commonName: String
    let scientificName: String
    let plantDescription: String
    let general: General
    let physical: Physical
    let development: Development
    let conditions: Conditions?
    let createdAt: Date
    let updatedAt: Date

    static func == (lhs: PlantDetails, rhs: PlantDetails) -> Bool {
        lhs.id == rhs.id &&
        lhs.plantImageData == rhs.plantImageData &&
        lhs.commonName == rhs.commonName &&
        lhs.scientificName == rhs.scientificName &&
        lhs.plantDescription == rhs.plantDescription &&
        lhs.general == rhs.general &&
        lhs.physical == rhs.physical &&
        lhs.development == rhs.development &&
        lhs.conditions == rhs.conditions &&
        lhs.createdAt == rhs.createdAt &&
        lhs.updatedAt == rhs.updatedAt
    }

    // Explicit memberwise initializer
    init(id: UUID, plantImageData: Data, commonName: String, scientificName: String, plantDescription: String, general: General, physical: Physical, development: Development, conditions: Conditions?, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.plantImageData = plantImageData
        self.commonName = commonName
        self.scientificName = scientificName
        self.plantDescription = plantDescription
        self.general = general
        self.physical = physical
        self.development = development
        self.conditions = conditions
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id, plantImageData, commonName, scientificName, plantDescription, general, physical, development, conditions, createdAt, updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        self.plantImageData = (try? container.decode(Data.self, forKey: .plantImageData)) ?? Data()
        self.commonName = try container.decode(String.self, forKey: .commonName)
        self.scientificName = try container.decode(String.self, forKey: .scientificName)
        self.plantDescription = try container.decodeIfPresent(String.self, forKey: .plantDescription) ?? ""
        self.general = try container.decode(General.self, forKey: .general)
        self.physical = try container.decode(Physical.self, forKey: .physical)
        self.development = try container.decode(Development.self, forKey: .development)
        self.conditions = try container.decodeIfPresent(Conditions.self, forKey: .conditions)
        self.createdAt = (try? container.decode(Date.self, forKey: .createdAt)) ?? Date()
        self.updatedAt = (try? container.decode(Date.self, forKey: .updatedAt)) ?? Date()
    }

    struct General: Codable, Equatable, Hashable {
        let habitat: String
        let originCountries: [String]
        let environmentalBenefits: [String]
    }
    struct Physical: Codable, Equatable, Hashable {
        let height: String
        let crownDiameter: String
        let form: String
    }
    struct Development: Codable, Equatable, Hashable {
        let matureHeightTime: String
        let growthSpeed: Int
        let propagationMethods: [String]
        let cycle: String
    }
    struct Conditions: Codable, Equatable, Hashable {
        let climatic: Climatic?
        let soil: Soil?
        let light: Light?
        struct RangeD: Codable, Equatable, Hashable {
            let lower: Double
            let upper: Double
        }
        struct RangeI: Codable, Equatable, Hashable {
            let lower: Int
            let upper: Int
        }
        struct Climatic: Codable, Equatable, Hashable {
            let hardinessZone: [Int] // e.g. [1,2,3,4,5,6,7,8,9,10,11,12,13]
            let minTemperature: Double // e.g. -1.1
            let temperatureRange: RangeD
            let idealTemperatureRange: RangeD
            let humidityRange: RangeI
            let windResistance: String? // e.g. "50km/h"
        }
        struct Soil: Codable, Equatable, Hashable {
            let phRange: [Double]
            let phLabel: String
            let types: [String]
        }
        struct Light: Codable, Equatable, Hashable {
            let amount: String // e.g. "8 to 12 hrs/day"
            let type: String // e.g. "Full sun"
        }
    }
} 
