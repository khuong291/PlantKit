import SwiftUI

struct ScanResultScreen: View {
    @EnvironmentObject var identifierManager: IdentifierManager
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Plant.scannedAt, ascending: false)],
        animation: .default)
    private var plants: FetchedResults<Plant>
    
    var body: some View {
        ZStack {
            Color.appScreenBackgroundColor
                .edgesIgnoringSafeArea(.all)
            if let lastPlant = plants.first {
                PlantDetailsScreen(
                    plantDetails: identifierManager.lastPlantDetails,
                    capturedImage: lastPlant.imageData.flatMap(UIImage.init),
                    onSwitchTab: { _ in }
                )
            } else {
                Text("No plant found")
                    .foregroundColor(.red)
                    .font(.title)
            }
        }
    }
}

#Preview {
    ScanResultScreen()
        .environmentObject(IdentifierManager())
        .environment(\.managedObjectContext, CoreDataManager.shared.viewContext)
}
