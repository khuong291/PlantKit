//
//  SamplePlantData.swift
//  PlantKit
//
//  Created by Khuong Pham on 3/6/25.
//

import Foundation
import UIKit

struct SamplePlantData {
    static let monsteraDeliciosa: PlantDetails = {
        // Convert the monstera image to Data
        let imageData = UIImage(named: "monstera")?.jpegData(compressionQuality: 0.8) ?? Data()
        
        return PlantDetails(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001") ?? UUID(),
            plantImageData: imageData,
            commonName: "Monstera Deliciosa",
            scientificName: "Monstera deliciosa",
            plantDescription: "The Monstera Deliciosa, also known as the Swiss Cheese Plant, is a popular tropical houseplant known for its distinctive leaves with natural holes and splits. This climbing plant can grow quite large and is prized for its dramatic foliage that adds a touch of the tropics to any indoor space.",
            general: PlantDetails.General(
                habitat: "Tropical rainforests",
                originCountries: ["Mexico", "Panama", "Costa Rica"],
                environmentalBenefits: ["Air purification", "Humidity regulation", "Carbon dioxide absorption"]
            ),
            physical: PlantDetails.Physical(
                height: "3-6 meters (10-20 feet)",
                crownDiameter: "1-2 meters (3-6 feet)",
                form: "Climbing vine with large, perforated leaves"
            ),
            development: PlantDetails.Development(
                matureHeightTime: "3-5 years",
                growthSpeed: 3,
                propagationMethods: ["Stem cuttings", "Air layering", "Seed"],
                cycle: "Perennial"
            ),
            conditions: PlantDetails.Conditions(
                climatic: PlantDetails.Conditions.Climatic(
                    hardinessZone: [10, 11, 12],
                    minTemperature: 10.0,
                    temperatureRange: PlantDetails.Conditions.RangeD(lower: 18.0, upper: 30.0),
                    idealTemperatureRange: PlantDetails.Conditions.RangeD(lower: 20.0, upper: 25.0),
                    humidityRange: PlantDetails.Conditions.RangeI(lower: 60, upper: 80),
                    windResistance: "Low"
                ),
                soil: PlantDetails.Conditions.Soil(
                    phRange: [5.5, 7.0],
                    phLabel: "Slightly acidic to neutral",
                    types: ["Well-draining potting mix", "Peat-based soil", "Orchid bark mix"]
                ),
                light: PlantDetails.Conditions.Light(
                    amount: "6-8 hours per day",
                    type: "Bright indirect light"
                )
            ),
            toxicity: "Toxic to pets and humans if ingested. Contains calcium oxalate crystals that can cause irritation to mouth, throat, and digestive system.",
            careGuideWatering: "Water when the top 2-3 inches of soil feels dry. Monstera prefers consistently moist but not soggy soil. Reduce watering in winter months. Use room temperature water and ensure good drainage.",
            careGuideFertilizing: "Feed with a balanced liquid fertilizer every 2-4 weeks during the growing season (spring and summer). Use a diluted solution to avoid fertilizer burn. No feeding needed during winter dormancy.",
            careGuidePruning: "Prune to control size and shape. Remove yellow or damaged leaves. Cut back leggy stems to encourage bushier growth. Use clean, sharp scissors and cut just above a leaf node.",
            careGuideRepotting: "Repot every 2-3 years or when roots become pot-bound. Choose a pot 2-3 inches larger in diameter. Best done in spring or early summer. Use fresh, well-draining potting mix.",
            createdAt: Date(),
            updatedAt: Date()
        )
    }()
    
    static let snakePlant: PlantDetails = {
        let imageData = UIImage(named: "snake-plant")?.jpegData(compressionQuality: 0.8) ?? Data()
        
        return PlantDetails(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000002") ?? UUID(),
            plantImageData: imageData,
            commonName: "Snake Plant",
            scientificName: "Sansevieria trifasciata",
            plantDescription: "The Snake Plant, also known as Mother-in-Law's Tongue, is one of the most popular and hardy houseplants. It's known for its tall, upright leaves with distinctive patterns and its ability to thrive in low-light conditions with minimal care.",
            general: PlantDetails.General(
                habitat: "Tropical and subtropical regions",
                originCountries: ["West Africa", "Nigeria", "Congo"],
                environmentalBenefits: ["Air purification", "Oxygen production at night", "Low maintenance"]
            ),
            physical: PlantDetails.Physical(
                height: "0.5-1.5 meters (2-5 feet)",
                crownDiameter: "0.3-0.6 meters (1-2 feet)",
                form: "Upright, sword-like leaves in rosettes"
            ),
            development: PlantDetails.Development(
                matureHeightTime: "2-3 years",
                growthSpeed: 2,
                propagationMethods: ["Leaf cuttings", "Division", "Rhizome cuttings"],
                cycle: "Perennial"
            ),
            conditions: PlantDetails.Conditions(
                climatic: PlantDetails.Conditions.Climatic(
                    hardinessZone: [9, 10, 11],
                    minTemperature: 10.0,
                    temperatureRange: PlantDetails.Conditions.RangeD(lower: 15.0, upper: 30.0),
                    idealTemperatureRange: PlantDetails.Conditions.RangeD(lower: 18.0, upper: 27.0),
                    humidityRange: PlantDetails.Conditions.RangeI(lower: 30, upper: 70),
                    windResistance: "Moderate"
                ),
                soil: PlantDetails.Conditions.Soil(
                    phRange: [6.0, 7.5],
                    phLabel: "Neutral to slightly alkaline",
                    types: ["Well-draining cactus mix", "Sandy soil", "Succulent potting mix"]
                ),
                light: PlantDetails.Conditions.Light(
                    amount: "2-6 hours per day",
                    type: "Low to bright indirect light"
                )
            ),
            toxicity: "Toxic to pets if ingested. Contains saponins that can cause nausea, vomiting, and diarrhea in cats and dogs.",
            careGuideWatering: "Water sparingly, allowing soil to dry completely between waterings. Snake plants are drought-tolerant and prefer underwatering to overwatering. Water every 2-6 weeks depending on light and temperature.",
            careGuideFertilizing: "Feed with a balanced houseplant fertilizer once every 2-3 months during spring and summer. Use half-strength solution. No feeding needed in fall and winter.",
            careGuidePruning: "Remove dead or damaged leaves at the base. Cut off brown tips with clean scissors. Pruning is rarely needed as snake plants grow slowly and maintain their shape well.",
            careGuideRepotting: "Repot every 3-5 years or when the pot becomes crowded. Snake plants prefer to be slightly root-bound. Use a well-draining pot and cactus/succulent mix.",
            createdAt: Date(),
            updatedAt: Date()
        )
    }()
    
    static let fiddleLeafFig: PlantDetails = {
        let imageData = UIImage(named: "fiddle-leaf")?.jpegData(compressionQuality: 0.8) ?? Data()
        
        return PlantDetails(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000003") ?? UUID(),
            plantImageData: imageData,
            commonName: "Fiddle Leaf Fig",
            scientificName: "Ficus lyrata",
            plantDescription: "The Fiddle Leaf Fig is a stunning tropical plant known for its large, violin-shaped leaves and dramatic presence. It's become a popular statement piece in modern interior design, though it requires specific care to thrive indoors.",
            general: PlantDetails.General(
                habitat: "Tropical rainforests",
                originCountries: ["West Africa", "Cameroon", "Sierra Leone"],
                environmentalBenefits: ["Air purification", "Large leaf surface for oxygen production", "Visual impact"]
            ),
            physical: PlantDetails.Physical(
                height: "3-10 meters (10-30 feet) in nature, 1.5-3 meters (5-10 feet) indoors",
                crownDiameter: "1-3 meters (3-10 feet)",
                form: "Tree-like with large, glossy, fiddle-shaped leaves"
            ),
            development: PlantDetails.Development(
                matureHeightTime: "5-10 years",
                growthSpeed: 2,
                propagationMethods: ["Stem cuttings", "Air layering"],
                cycle: "Perennial"
            ),
            conditions: PlantDetails.Conditions(
                climatic: PlantDetails.Conditions.Climatic(
                    hardinessZone: [10, 11, 12],
                    minTemperature: 15.0,
                    temperatureRange: PlantDetails.Conditions.RangeD(lower: 18.0, upper: 30.0),
                    idealTemperatureRange: PlantDetails.Conditions.RangeD(lower: 20.0, upper: 25.0),
                    humidityRange: PlantDetails.Conditions.RangeI(lower: 50, upper: 80),
                    windResistance: "Low"
                ),
                soil: PlantDetails.Conditions.Soil(
                    phRange: [6.0, 7.0],
                    phLabel: "Slightly acidic to neutral",
                    types: ["Well-draining potting mix", "Peat-based soil", "Rich organic soil"]
                ),
                light: PlantDetails.Conditions.Light(
                    amount: "6-8 hours per day",
                    type: "Bright indirect light"
                )
            ),
            toxicity: "Toxic to pets if ingested. Contains ficin and psoralen which can cause skin irritation and digestive upset.",
            careGuideWatering: "Water when the top 2-3 inches of soil feels dry. Fiddle leaf figs prefer consistent moisture but not soggy soil. Use room temperature water and ensure good drainage. Reduce watering in winter.",
            careGuideFertilizing: "Feed with a balanced liquid fertilizer every 2-4 weeks during spring and summer. Use a diluted solution. No feeding needed during fall and winter dormancy.",
            careGuidePruning: "Prune to control height and shape. Remove dead or damaged leaves. Cut back leggy stems to encourage bushier growth. Best done in spring or early summer.",
            careGuideRepotting: "Repot every 2-3 years or when roots become pot-bound. Choose a pot 2-3 inches larger. Best done in spring. Use fresh, well-draining potting mix.",
            createdAt: Date(),
            updatedAt: Date()
        )
    }()
    
    static let peaceLily: PlantDetails = {
        let imageData = UIImage(named: "peace-lily")?.jpegData(compressionQuality: 0.8) ?? Data()
        
        return PlantDetails(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000004") ?? UUID(),
            plantImageData: imageData,
            commonName: "Peace Lily",
            scientificName: "Spathiphyllum wallisii",
            plantDescription: "The Peace Lily is a beautiful flowering plant known for its elegant white blooms and glossy green leaves. It's one of the best air-purifying plants and is relatively easy to care for, making it perfect for beginners.",
            general: PlantDetails.General(
                habitat: "Tropical rainforests",
                originCountries: ["Colombia", "Venezuela", "Central America"],
                environmentalBenefits: ["Air purification", "Humidity regulation", "Flowering beauty"]
            ),
            physical: PlantDetails.Physical(
                height: "0.3-1 meter (1-3 feet)",
                crownDiameter: "0.3-0.6 meters (1-2 feet)",
                form: "Clumping plant with large, glossy leaves and white flowers"
            ),
            development: PlantDetails.Development(
                matureHeightTime: "2-3 years",
                growthSpeed: 3,
                propagationMethods: ["Division", "Rhizome cuttings"],
                cycle: "Perennial"
            ),
            conditions: PlantDetails.Conditions(
                climatic: PlantDetails.Conditions.Climatic(
                    hardinessZone: [10, 11, 12],
                    minTemperature: 15.0,
                    temperatureRange: PlantDetails.Conditions.RangeD(lower: 18.0, upper: 30.0),
                    idealTemperatureRange: PlantDetails.Conditions.RangeD(lower: 20.0, upper: 25.0),
                    humidityRange: PlantDetails.Conditions.RangeI(lower: 50, upper: 80),
                    windResistance: "Low"
                ),
                soil: PlantDetails.Conditions.Soil(
                    phRange: [5.5, 6.5],
                    phLabel: "Slightly acidic",
                    types: ["Rich, well-draining potting mix", "Peat-based soil", "Organic-rich soil"]
                ),
                light: PlantDetails.Conditions.Light(
                    amount: "4-6 hours per day",
                    type: "Medium to bright indirect light"
                )
            ),
            toxicity: "Toxic to pets if ingested. Contains calcium oxalate crystals that can cause irritation to mouth, throat, and digestive system.",
            careGuideWatering: "Keep soil consistently moist but not soggy. Peace lilies will droop when they need water, making them easy to care for. Use room temperature water and ensure good drainage.",
            careGuideFertilizing: "Feed with a balanced liquid fertilizer every 2-4 weeks during spring and summer. Use a diluted solution. No feeding needed during fall and winter.",
            careGuidePruning: "Remove spent flowers and yellow leaves. Cut flower stems back to the base when blooms fade. Prune to maintain shape and remove damaged foliage.",
            careGuideRepotting: "Repot every 1-2 years or when roots become pot-bound. Choose a pot 1-2 inches larger. Best done in spring. Use fresh, rich potting mix.",
            createdAt: Date(),
            updatedAt: Date()
        )
    }()
    
    static let zzPlant: PlantDetails = {
        let imageData = UIImage(named: "zz-plant")?.jpegData(compressionQuality: 0.8) ?? Data()
        
        return PlantDetails(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000005") ?? UUID(),
            plantImageData: imageData,
            commonName: "ZZ Plant",
            scientificName: "Zamioculcas zamiifolia",
            plantDescription: "The ZZ Plant is an incredibly hardy and low-maintenance houseplant known for its glossy, dark green leaves and ability to thrive in almost any indoor condition. It's perfect for busy people or those new to plant care.",
            general: PlantDetails.General(
                habitat: "Tropical regions",
                originCountries: ["East Africa", "Kenya", "Tanzania"],
                environmentalBenefits: ["Air purification", "Drought tolerance", "Low maintenance"]
            ),
            physical: PlantDetails.Physical(
                height: "0.5-1 meter (2-3 feet)",
                crownDiameter: "0.3-0.6 meters (1-2 feet)",
                form: "Upright stems with glossy, pinnate leaves"
            ),
            development: PlantDetails.Development(
                matureHeightTime: "3-5 years",
                growthSpeed: 1,
                propagationMethods: ["Leaf cuttings", "Division", "Rhizome cuttings"],
                cycle: "Perennial"
            ),
            conditions: PlantDetails.Conditions(
                climatic: PlantDetails.Conditions.Climatic(
                    hardinessZone: [9, 10, 11],
                    minTemperature: 15.0,
                    temperatureRange: PlantDetails.Conditions.RangeD(lower: 16.0, upper: 30.0),
                    idealTemperatureRange: PlantDetails.Conditions.RangeD(lower: 18.0, upper: 26.0),
                    humidityRange: PlantDetails.Conditions.RangeI(lower: 30, upper: 70),
                    windResistance: "Moderate"
                ),
                soil: PlantDetails.Conditions.Soil(
                    phRange: [6.0, 7.0],
                    phLabel: "Neutral",
                    types: ["Well-draining potting mix", "Cactus/succulent mix", "Sandy soil"]
                ),
                light: PlantDetails.Conditions.Light(
                    amount: "2-8 hours per day",
                    type: "Low to bright indirect light"
                )
            ),
            toxicity: "Toxic to pets if ingested. Contains calcium oxalate crystals that can cause irritation to mouth, throat, and digestive system.",
            careGuideWatering: "Water sparingly, allowing soil to dry completely between waterings. ZZ plants store water in their rhizomes and prefer underwatering to overwatering. Water every 2-4 weeks.",
            careGuideFertilizing: "Feed with a balanced houseplant fertilizer once every 2-3 months during spring and summer. Use half-strength solution. No feeding needed in fall and winter.",
            careGuidePruning: "Remove yellow or damaged leaves at the base. ZZ plants grow slowly and rarely need pruning. Cut back leggy stems if needed to maintain shape.",
            careGuideRepotting: "Repot every 2-3 years or when the pot becomes crowded. ZZ plants prefer to be slightly root-bound. Use a well-draining pot and potting mix.",
            createdAt: Date(),
            updatedAt: Date()
        )
    }()
} 