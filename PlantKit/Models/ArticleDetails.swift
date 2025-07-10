import Foundation
import UIKit

struct ArticleParagraph: Hashable {
    let title: String?
    let body: String
}

struct ArticleDetails: Identifiable, Equatable, Hashable {
    let id = UUID()
    let title: String
    let category: String
    let imageName: String
    let readingMinutes: Int
    let content: [ArticleParagraph]
    let author: String
    let publishDate: String
    
    static func == (lhs: ArticleDetails, rhs: ArticleDetails) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static let sampleArticles: [ArticleDetails] = [
        ArticleDetails(
            title: "8 Plants to Avoid Growing Next to Tomatoes for a Healthy Harvest",
            category: "Companion Planting",
            imageName: "article1",
            readingMinutes: 5,
            content: [
                ArticleParagraph(title: nil, body: "Companion planting is a gardening technique that involves growing different plants together for mutual benefits. However, some plants can actually harm each other when grown in close proximity. Tomatoes, one of the most popular garden vegetables, are particularly sensitive to certain plant neighbors."),
                ArticleParagraph(title: "Why Companion Planting Matters for Tomatoes", body: "Tomatoes are heavy feeders that require specific nutrients and growing conditions. When planted near incompatible species, they can experience reduced growth and yield, increased susceptibility to pests and diseases, competition for essential nutrients, and allelopathic effects (chemical inhibition)."),
                ArticleParagraph(title: "8 Plants to Avoid Near Tomatoes", body: "1. Corn - Both are heavy feeders and will compete for nutrients\n2. Potatoes - They share the same family (Solanaceae) and are susceptible to the same diseases\n3. Fennel - Produces chemicals that inhibit tomato growth\n4. Walnuts - Release juglone, a toxic compound that affects tomatoes\n5. Dill - Can attract tomato hornworms and compete for space\n6. Cabbage Family - Includes broccoli, cauliflower, and Brussels sprouts\n7. Eggplant - Same family as tomatoes, sharing disease vulnerabilities\n8. Peppers - Can compete for nutrients and space"),
                ArticleParagraph(title: "Best Companion Plants for Tomatoes", body: "Instead, consider planting these beneficial neighbors: Basil (repels pests and improves flavor), Marigolds (deter nematodes and other pests), Garlic (natural pest repellent), Onions (help deter common tomato pests), Nasturtiums (attract beneficial insects)."),
                ArticleParagraph(title: "Planning Your Garden Layout", body: "When planning your tomato garden, consider spacing requirements (3-4 feet between tomato plants), sun exposure needs, water requirements, and growth habits and timing. By avoiding these problematic plant combinations, you'll give your tomatoes the best chance for a healthy, productive growing season.")
            ],
            author: "Garden Expert Team",
            publishDate: "March 15, 2024"
        ),
        ArticleDetails(
            title: "Transform Your Garden with Old Cardboard Boxes: Here's How",
            category: "Garden Hacks",
            imageName: "article2",
            readingMinutes: 3,
            content: [
                ArticleParagraph(title: nil, body: "Don't throw away those cardboard boxes! They can be incredibly useful in your garden for weed control, soil improvement, and even creating new growing spaces. Here's how to put them to work."),
                ArticleParagraph(title: "Weed Control with Cardboard", body: "Cardboard is an excellent natural weed barrier: Lay flattened boxes between garden rows, cover with mulch for a long-lasting weed barrier, and the cardboard will decompose over time, adding organic matter."),
                ArticleParagraph(title: "Creating New Garden Beds", body: "Use cardboard to establish new growing areas: Clear the area of large debris, lay down overlapping cardboard sheets, add 4-6 inches of soil or compost, plant directly into the new bed, and the cardboard will suppress grass and weeds below."),
                ArticleParagraph(title: "Composting with Cardboard", body: "Cardboard is a great 'brown' material for your compost: Shred boxes into small pieces, mix with green materials (kitchen scraps, grass clippings), maintain proper moisture levels, and turn regularly for faster decomposition."),
                ArticleParagraph(title: "Seed Starting Trays", body: "Create biodegradable seed starting containers: Cut cardboard into strips, form into small pots or trays, fill with potting mix, plant seeds directly, and transplant entire container into garden."),
                ArticleParagraph(title: "Tips for Success", body: "Use plain cardboard (avoid glossy or colored boxes), remove all tape and labels, wet cardboard before using for better decomposition, and layer with other organic materials for best results. This simple garden hack can save you money while improving your soil and reducing waste!")
            ],
            author: "Sustainable Gardening",
            publishDate: "March 10, 2024"
        ),
        ArticleDetails(
            title: "Baking Soda in the Garden: When It Works and When to Avoid It",
            category: "Natural Remedies",
            imageName: "article3",
            readingMinutes: 4,
            content: [
                ArticleParagraph(title: nil, body: "Baking soda (sodium bicarbonate) has been used as a natural garden remedy for decades. While it can be effective for certain problems, it's not a cure-all and can sometimes do more harm than good. Here's what you need to know."),
                ArticleParagraph(title: "When Baking Soda Works", body: "Fungal Disease Control: Baking soda can help control powdery mildew and other fungal diseases. Mix 1 tablespoon baking soda with 1 gallon water, add 1 teaspoon liquid soap as a spreader, spray affected plants weekly, best applied in early morning or evening."),
                ArticleParagraph(title: "Soil pH Adjustment", body: "For slightly acidic soils that need sweetening: Apply 1 cup per 100 square feet, work into soil before planting, test soil pH after 2-3 weeks, reapply if needed."),
                ArticleParagraph(title: "Pest Deterrent", body: "Can help deter certain pests: Sprinkle around plants to deter ants, mix with flour to control cabbage worms, combine with other natural repellents."),
                ArticleParagraph(title: "When to Avoid Baking Soda", body: "Alkaline Soils: Don't use if your soil is already alkaline (pH above 7.0). Can make soil too alkaline for most plants, may cause nutrient deficiencies, test soil pH before applying. Sensitive Plants: Some plants are particularly sensitive, such as ferns, blueberries, and certain vegetables like potatoes. Overuse Problems: Too much baking soda can build up sodium in soil, harm beneficial soil organisms, create nutrient imbalances, and damage plant roots."),
                ArticleParagraph(title: "Alternative Natural Remedies", body: "Consider these alternatives: Neem oil for pest control, copper fungicides for fungal diseases, compost for soil improvement, beneficial insects for pest management."),
                ArticleParagraph(title: "Best Practices", body: "Always test on a small area first, use sparingly and monitor results, combine with other organic methods, and maintain proper plant care practices. Remember, baking soda is a tool, not a miracle cure. Use it wisely as part of an integrated garden management approach.")
            ],
            author: "Organic Gardening Expert",
            publishDate: "March 12, 2024"
        )
    ]
} 