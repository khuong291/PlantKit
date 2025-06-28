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
} 