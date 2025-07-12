import SwiftUI
import SwiftData

struct CurrentCardWidget: View {
    var currentCardID: UUID?
    @Query private var allCards: [Keycard]

    var body: some View {
        if let currentCardID = currentCardID {
            // If card exists in the user's wallet
            if let card = allCards.first(where: { $0.id == currentCardID }) {
                Label(card.name, systemImage: "keycard.fill")
            // If a card is loaded, but it isn't in the wallet (has it been deleted?)
            } else {
                Label("Unknown Card", systemImage: "questionmark.circle.fill")
            }
            // No card currently loaded
        } else {
            Label("No Card", systemImage: "bolt.fill")
            
        }
    }
}

#Preview("No card") {
    CurrentCardWidget()
}
