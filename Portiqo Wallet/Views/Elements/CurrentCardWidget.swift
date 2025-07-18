import SwiftUI
import SwiftData

struct CurrentCardWidget: View {
    @Environment(\.dependencies) private var dependencies
    var connectionManager: ConnectionManager { dependencies.connectionManager }
    var currentCardID: UUID
    @Query private var allCards: [Keycard]

    var body: some View {
        VStack {
            // If card exists in the user's wallet
            HStack {
                if let card = allCards.first(where: { $0.id == currentCardID }) {
                    Image(systemName: "lanyardcard.fill")
                        .font(.largeTitle)
                    Spacer()
                    Text(card.name)
                        .font(.largeTitle)
                    // If a card is loaded, but it isn't in the wallet (has it been deleted?)
                } else {

                    Image(systemName: "questionmark.circle")
                        .font(.title)
                    Spacer()
                    Text("Unknown Card")
                        .font(.headline)
                }
            }
            Button("Unload Card") {
                Task {
                    await connectionManager.eraseKey()
                }
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

#Preview("Unknown Card") {
    CurrentCardWidget(currentCardID: UUID())
}
