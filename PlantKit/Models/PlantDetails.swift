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
    let toxicity: String?
    let careGuideWatering: String?
    let careGuideFertilizing: String?
    let careGuidePruning: String?
    let careGuideRepotting: String?
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case plantImageData
        case commonName
        case scientificName
        case plantDescription = "description"
        case general
        case physical
        case development
        case conditions
        case toxicity
        case care
        case careGuideWatering
        case careGuideFertilizing
        case careGuidePruning
        case careGuideRepotting
        case createdAt
        case updatedAt
    }

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
        lhs.toxicity == rhs.toxicity &&
        lhs.careGuideWatering == rhs.careGuideWatering &&
        lhs.careGuideFertilizing == rhs.careGuideFertilizing &&
        lhs.careGuidePruning == rhs.careGuidePruning &&
        lhs.careGuideRepotting == rhs.careGuideRepotting &&
        lhs.createdAt == rhs.createdAt &&
        lhs.updatedAt == rhs.updatedAt
    }

    // Explicit memberwise initializer
    init(id: UUID, plantImageData: Data, commonName: String, scientificName: String, plantDescription: String, general: General, physical: Physical, development: Development, conditions: Conditions?, toxicity: String?, careGuideWatering: String?, careGuideFertilizing: String?, careGuidePruning: String?, careGuideRepotting: String?, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.plantImageData = plantImageData
        self.commonName = commonName
        self.scientificName = scientificName
        self.plantDescription = plantDescription
        self.general = general
        self.physical = physical
        self.development = development
        self.conditions = conditions
        self.toxicity = toxicity
        self.careGuideWatering = careGuideWatering
        self.careGuideFertilizing = careGuideFertilizing
        self.careGuidePruning = careGuidePruning
        self.careGuideRepotting = careGuideRepotting
        self.createdAt = createdAt
        self.updatedAt = updatedAt
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
        
        // Handle toxicity - it can be either a string or an object with description
        if let toxicityString = try? container.decode(String.self, forKey: .toxicity) {
            self.toxicity = toxicityString
        } else if let toxicityObject = try? container.decodeIfPresent([String: String].self, forKey: .toxicity) {
            self.toxicity = toxicityObject["description"]
        } else {
            self.toxicity = nil
        }
        
        // Handle care guide properties - they can be either direct properties or nested under "care"
        if let careObject = try? container.decodeIfPresent([String: String].self, forKey: .care) {
            self.careGuideWatering = careObject["watering"]
            self.careGuideFertilizing = careObject["fertilizing"]
            self.careGuidePruning = careObject["pruning"]
            self.careGuideRepotting = careObject["repotting"]
        } else {
            // Fallback to direct properties if care object doesn't exist
            self.careGuideWatering = try container.decodeIfPresent(String.self, forKey: .careGuideWatering)
            self.careGuideFertilizing = try container.decodeIfPresent(String.self, forKey: .careGuideFertilizing)
            self.careGuidePruning = try container.decodeIfPresent(String.self, forKey: .careGuidePruning)
            self.careGuideRepotting = try container.decodeIfPresent(String.self, forKey: .careGuideRepotting)
        }
        
        self.createdAt = (try? container.decode(Date.self, forKey: .createdAt)) ?? Date()
        self.updatedAt = (try? container.decode(Date.self, forKey: .updatedAt)) ?? Date()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(plantImageData, forKey: .plantImageData)
        try container.encode(commonName, forKey: .commonName)
        try container.encode(scientificName, forKey: .scientificName)
        try container.encode(plantDescription, forKey: .plantDescription)
        try container.encode(general, forKey: .general)
        try container.encode(physical, forKey: .physical)
        try container.encode(development, forKey: .development)
        try container.encodeIfPresent(conditions, forKey: .conditions)
        
        // Encode toxicity as a simple string
        try container.encodeIfPresent(toxicity, forKey: .toxicity)
        
        // Encode care guide properties as individual strings
        try container.encodeIfPresent(careGuideWatering, forKey: .careGuideWatering)
        try container.encodeIfPresent(careGuideFertilizing, forKey: .careGuideFertilizing)
        try container.encodeIfPresent(careGuidePruning, forKey: .careGuidePruning)
        try container.encodeIfPresent(careGuideRepotting, forKey: .careGuideRepotting)
        
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
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
