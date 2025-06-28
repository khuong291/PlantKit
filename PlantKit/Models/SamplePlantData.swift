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
    
    // MARK: - Outdoor Plants
    
    static let hydrangea: PlantDetails = {
        let imageData = UIImage(named: "hydrangea")?.jpegData(compressionQuality: 0.8) ?? Data()
        
        return PlantDetails(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000006") ?? UUID(),
            plantImageData: imageData,
            commonName: "Hydrangea",
            scientificName: "Hydrangea macrophylla",
            plantDescription: "Hydrangeas are beloved flowering shrubs known for their large, showy flower clusters that can change color based on soil pH. They're perfect for adding dramatic color to gardens and are popular for both landscaping and cut flower arrangements.",
            general: PlantDetails.General(
                habitat: "Woodland areas and gardens",
                originCountries: ["Japan", "China", "Korea"],
                environmentalBenefits: ["Pollinator attraction", "Erosion control", "Garden beauty"]
            ),
            physical: PlantDetails.Physical(
                height: "1-3 meters (3-10 feet)",
                crownDiameter: "1-2.5 meters (3-8 feet)",
                form: "Deciduous shrub with large, rounded flower clusters"
            ),
            development: PlantDetails.Development(
                matureHeightTime: "3-5 years",
                growthSpeed: 3,
                propagationMethods: ["Stem cuttings", "Division", "Layering"],
                cycle: "Perennial"
            ),
            conditions: PlantDetails.Conditions(
                climatic: PlantDetails.Conditions.Climatic(
                    hardinessZone: [5, 6, 7, 8, 9],
                    minTemperature: -20.0,
                    temperatureRange: PlantDetails.Conditions.RangeD(lower: 15.0, upper: 30.0),
                    idealTemperatureRange: PlantDetails.Conditions.RangeD(lower: 18.0, upper: 25.0),
                    humidityRange: PlantDetails.Conditions.RangeI(lower: 40, upper: 70),
                    windResistance: "Moderate"
                ),
                soil: PlantDetails.Conditions.Soil(
                    phRange: [5.5, 6.5],
                    phLabel: "Slightly acidic",
                    types: ["Rich, well-draining soil", "Loamy soil", "Organic-rich soil"]
                ),
                light: PlantDetails.Conditions.Light(
                    amount: "4-6 hours per day",
                    type: "Partial shade to full sun"
                )
            ),
            toxicity: "Toxic to pets if ingested. Contains cyanogenic glycosides that can cause vomiting, diarrhea, and lethargy in dogs and cats.",
            careGuideWatering: "Keep soil consistently moist, especially during hot weather. Water deeply 2-3 times per week. Avoid overhead watering to prevent fungal diseases. Mulch around the base to retain moisture.",
            careGuideFertilizing: "Feed with a balanced fertilizer in early spring and again in mid-summer. Use a fertilizer formulated for acid-loving plants. Avoid high-nitrogen fertilizers which can reduce flowering.",
            careGuidePruning: "Prune in late winter or early spring before new growth begins. Remove dead wood and old flower heads. Cut back stems by one-third to encourage new growth and better flowering.",
            careGuideRepotting: "For container-grown hydrangeas, repot every 2-3 years in spring. Choose a pot 2-3 inches larger with good drainage. Use acidic potting mix.",
            createdAt: Date(),
            updatedAt: Date()
        )
    }()
    
    static let japaneseMaple: PlantDetails = {
        let imageData = UIImage(named: "japanese-maple")?.jpegData(compressionQuality: 0.8) ?? Data()
        
        return PlantDetails(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000007") ?? UUID(),
            plantImageData: imageData,
            commonName: "Japanese Maple",
            scientificName: "Acer palmatum",
            plantDescription: "Japanese Maples are elegant, slow-growing trees known for their delicate, lacy leaves and stunning fall colors. They're prized for their ornamental value and are perfect for adding structure and beauty to gardens.",
            general: PlantDetails.General(
                habitat: "Mountainous regions and forests",
                originCountries: ["Japan", "Korea", "China"],
                environmentalBenefits: ["Shade provision", "Wildlife habitat", "Seasonal interest"]
            ),
            physical: PlantDetails.Physical(
                height: "3-8 meters (10-25 feet)",
                crownDiameter: "3-6 meters (10-20 feet)",
                form: "Small deciduous tree with delicate, palmate leaves"
            ),
            development: PlantDetails.Development(
                matureHeightTime: "10-20 years",
                growthSpeed: 1,
                propagationMethods: ["Seed", "Grafting", "Cuttings"],
                cycle: "Perennial"
            ),
            conditions: PlantDetails.Conditions(
                climatic: PlantDetails.Conditions.Climatic(
                    hardinessZone: [5, 6, 7, 8],
                    minTemperature: -25.0,
                    temperatureRange: PlantDetails.Conditions.RangeD(lower: 10.0, upper: 30.0),
                    idealTemperatureRange: PlantDetails.Conditions.RangeD(lower: 15.0, upper: 25.0),
                    humidityRange: PlantDetails.Conditions.RangeI(lower: 40, upper: 70),
                    windResistance: "Low"
                ),
                soil: PlantDetails.Conditions.Soil(
                    phRange: [5.5, 6.5],
                    phLabel: "Slightly acidic",
                    types: ["Well-draining, rich soil", "Loamy soil", "Organic-rich soil"]
                ),
                light: PlantDetails.Conditions.Light(
                    amount: "4-6 hours per day",
                    type: "Partial shade to filtered sun"
                )
            ),
            toxicity: "Generally non-toxic to pets, but leaves may cause mild gastrointestinal upset if ingested in large quantities.",
            careGuideWatering: "Water regularly, especially during dry periods. Keep soil consistently moist but not soggy. Water deeply and less frequently rather than shallow, frequent watering. Mulch to retain moisture.",
            careGuideFertilizing: "Feed with a balanced, slow-release fertilizer in early spring. Avoid high-nitrogen fertilizers which can cause excessive growth. Use organic fertilizers for best results.",
            careGuidePruning: "Prune in late winter or early spring when dormant. Remove dead, damaged, or crossing branches. Light pruning to maintain shape. Avoid heavy pruning which can stress the tree.",
            careGuideRepotting: "For container-grown specimens, repot every 3-5 years in early spring. Choose a pot 2-3 inches larger. Use well-draining, acidic potting mix.",
            createdAt: Date(),
            updatedAt: Date()
        )
    }()
    
    static let lavender: PlantDetails = {
        let imageData = UIImage(named: "lavender")?.jpegData(compressionQuality: 0.8) ?? Data()
        
        return PlantDetails(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000008") ?? UUID(),
            plantImageData: imageData,
            commonName: "Lavender",
            scientificName: "Lavandula angustifolia",
            plantDescription: "Lavender is a fragrant, drought-tolerant herb known for its beautiful purple flowers and calming scent. It's popular for gardens, aromatherapy, and culinary uses, and attracts beneficial pollinators.",
            general: PlantDetails.General(
                habitat: "Mediterranean regions and rocky hillsides",
                originCountries: ["Mediterranean", "France", "Spain"],
                environmentalBenefits: ["Pollinator attraction", "Drought tolerance", "Aromatic properties"]
            ),
            physical: PlantDetails.Physical(
                height: "0.3-0.6 meters (1-2 feet)",
                crownDiameter: "0.3-0.6 meters (1-2 feet)",
                form: "Compact shrub with aromatic, gray-green foliage and purple flowers"
            ),
            development: PlantDetails.Development(
                matureHeightTime: "2-3 years",
                growthSpeed: 2,
                propagationMethods: ["Stem cuttings", "Seed", "Division"],
                cycle: "Perennial"
            ),
            conditions: PlantDetails.Conditions(
                climatic: PlantDetails.Conditions.Climatic(
                    hardinessZone: [5, 6, 7, 8, 9],
                    minTemperature: -15.0,
                    temperatureRange: PlantDetails.Conditions.RangeD(lower: 15.0, upper: 30.0),
                    idealTemperatureRange: PlantDetails.Conditions.RangeD(lower: 18.0, upper: 25.0),
                    humidityRange: PlantDetails.Conditions.RangeI(lower: 30, upper: 60),
                    windResistance: "High"
                ),
                soil: PlantDetails.Conditions.Soil(
                    phRange: [6.5, 7.5],
                    phLabel: "Neutral to slightly alkaline",
                    types: ["Well-draining, sandy soil", "Rocky soil", "Poor soil"]
                ),
                light: PlantDetails.Conditions.Light(
                    amount: "6-8 hours per day",
                    type: "Full sun"
                )
            ),
            toxicity: "Generally safe for pets, but essential oils can be toxic if ingested in large quantities. Monitor pets around lavender plants.",
            careGuideWatering: "Water sparingly once established. Allow soil to dry between waterings. Overwatering can cause root rot. Water deeply but infrequently during dry periods.",
            careGuideFertilizing: "Light feeding with a balanced fertilizer in early spring. Avoid high-nitrogen fertilizers which can reduce flowering. Use organic fertilizers sparingly.",
            careGuidePruning: "Prune after flowering to maintain shape and encourage new growth. Cut back by one-third in early spring. Remove spent flower stalks to encourage reblooming.",
            careGuideRepotting: "For container-grown lavender, repot every 2-3 years in spring. Choose a pot with excellent drainage. Use sandy, well-draining potting mix.",
            createdAt: Date(),
            updatedAt: Date()
        )
    }()
    
    static let roseBush: PlantDetails = {
        let imageData = UIImage(named: "rose-bush")?.jpegData(compressionQuality: 0.8) ?? Data()
        
        return PlantDetails(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000009") ?? UUID(),
            plantImageData: imageData,
            commonName: "Rose Bush",
            scientificName: "Rosa spp.",
            plantDescription: "Rose bushes are classic garden plants known for their beautiful, fragrant flowers and thorny stems. They come in many varieties and colors, making them versatile additions to any garden landscape.",
            general: PlantDetails.General(
                habitat: "Temperate regions and gardens",
                originCountries: ["Asia", "Europe", "North America"],
                environmentalBenefits: ["Pollinator attraction", "Cut flower production", "Garden beauty"]
            ),
            physical: PlantDetails.Physical(
                height: "0.6-2 meters (2-6 feet)",
                crownDiameter: "0.6-1.5 meters (2-5 feet)",
                form: "Deciduous shrub with thorny stems and fragrant flowers"
            ),
            development: PlantDetails.Development(
                matureHeightTime: "2-4 years",
                growthSpeed: 3,
                propagationMethods: ["Stem cuttings", "Grafting", "Seed"],
                cycle: "Perennial"
            ),
            conditions: PlantDetails.Conditions(
                climatic: PlantDetails.Conditions.Climatic(
                    hardinessZone: [3, 4, 5, 6, 7, 8, 9],
                    minTemperature: -35.0,
                    temperatureRange: PlantDetails.Conditions.RangeD(lower: 15.0, upper: 30.0),
                    idealTemperatureRange: PlantDetails.Conditions.RangeD(lower: 18.0, upper: 25.0),
                    humidityRange: PlantDetails.Conditions.RangeI(lower: 40, upper: 70),
                    windResistance: "Moderate"
                ),
                soil: PlantDetails.Conditions.Soil(
                    phRange: [6.0, 7.0],
                    phLabel: "Slightly acidic to neutral",
                    types: ["Rich, well-draining soil", "Loamy soil", "Organic-rich soil"]
                ),
                light: PlantDetails.Conditions.Light(
                    amount: "6-8 hours per day",
                    type: "Full sun"
                )
            ),
            toxicity: "Generally safe for pets, but thorns can cause physical injury. Some rose varieties may cause mild gastrointestinal upset if ingested.",
            careGuideWatering: "Water deeply 2-3 times per week, especially during dry periods. Water at the base to avoid wetting foliage. Mulch to retain moisture and prevent weeds.",
            careGuideFertilizing: "Feed with rose-specific fertilizer in early spring and after first bloom. Use balanced fertilizer every 4-6 weeks during growing season. Stop fertilizing 6 weeks before first frost.",
            careGuidePruning: "Prune in late winter or early spring before new growth begins. Remove dead, damaged, or crossing branches. Cut back by one-third to encourage new growth and better flowering.",
            careGuideRepotting: "For container-grown roses, repot every 2-3 years in early spring. Choose a pot 2-3 inches larger with good drainage. Use rich, well-draining potting mix.",
            createdAt: Date(),
            updatedAt: Date()
        )
    }()
    
    static let boxwood: PlantDetails = {
        let imageData = UIImage(named: "boxwood")?.jpegData(compressionQuality: 0.8) ?? Data()
        
        return PlantDetails(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000010") ?? UUID(),
            plantImageData: imageData,
            commonName: "Boxwood",
            scientificName: "Buxus sempervirens",
            plantDescription: "Boxwood is a versatile evergreen shrub known for its dense, compact growth and ability to be shaped into formal hedges and topiaries. It's a classic choice for landscape design and garden structure.",
            general: PlantDetails.General(
                habitat: "Woodlands and gardens",
                originCountries: ["Europe", "Asia", "Africa"],
                environmentalBenefits: ["Year-round greenery", "Wind protection", "Privacy screening"]
            ),
            physical: PlantDetails.Physical(
                height: "1-6 meters (3-20 feet)",
                crownDiameter: "1-4 meters (3-12 feet)",
                form: "Evergreen shrub with dense, small leaves and compact growth"
            ),
            development: PlantDetails.Development(
                matureHeightTime: "5-10 years",
                growthSpeed: 1,
                propagationMethods: ["Stem cuttings", "Layering", "Seed"],
                cycle: "Perennial"
            ),
            conditions: PlantDetails.Conditions(
                climatic: PlantDetails.Conditions.Climatic(
                    hardinessZone: [5, 6, 7, 8, 9],
                    minTemperature: -20.0,
                    temperatureRange: PlantDetails.Conditions.RangeD(lower: 10.0, upper: 30.0),
                    idealTemperatureRange: PlantDetails.Conditions.RangeD(lower: 15.0, upper: 25.0),
                    humidityRange: PlantDetails.Conditions.RangeI(lower: 40, upper: 70),
                    windResistance: "High"
                ),
                soil: PlantDetails.Conditions.Soil(
                    phRange: [6.0, 7.5],
                    phLabel: "Neutral to slightly alkaline",
                    types: ["Well-draining, loamy soil", "Rich garden soil", "Organic-rich soil"]
                ),
                light: PlantDetails.Conditions.Light(
                    amount: "4-6 hours per day",
                    type: "Partial shade to full sun"
                )
            ),
            toxicity: "Toxic to pets if ingested. Contains alkaloids that can cause vomiting, diarrhea, and neurological symptoms in dogs and cats.",
            careGuideWatering: "Water regularly, especially during dry periods and when newly planted. Keep soil consistently moist but not soggy. Mulch to retain moisture and regulate soil temperature.",
            careGuideFertilizing: "Feed with a balanced fertilizer in early spring and again in mid-summer. Use slow-release fertilizer for best results. Avoid high-nitrogen fertilizers which can cause excessive growth.",
            careGuidePruning: "Prune in late winter or early spring before new growth begins. Can be pruned throughout growing season to maintain shape. Remove dead or damaged branches as needed.",
            careGuideRepotting: "For container-grown boxwood, repot every 3-5 years in early spring. Choose a pot 2-3 inches larger with good drainage. Use well-draining, rich potting mix.",
            createdAt: Date(),
            updatedAt: Date()
        )
    }()
} 