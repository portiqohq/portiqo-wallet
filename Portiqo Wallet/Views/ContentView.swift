import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.connectionManager) private var connectionManager
    @Query private var keycards: [Keycard]

    var isKeyConnected: Bool { connectionManager.isKeyConnected }
    // Cards that aren't loaded onto Portiqo Key
    var inactiveKeycards: [Keycard] {
        keycards
            .filter { $0.id != connectionManager.currentCard }
            .sorted { $0.name < $1.name }
    }

    var body: some View {
        NavigationSplitView {
            List {
                if let currentCardID = connectionManager.currentCard {
                    CurrentCardWidget(currentCardID: currentCardID)
                }
                ForEach(inactiveKeycards) { card in
                    Button {
                        Task {
                            await selectCard(card)
                        }
                    } label: {
                        CardRow(card)
                    }
                    .listRowSeparator(.hidden)
                }
                .onDelete(perform: deleteItems)
            }
            .scrollContentBackground(.hidden)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    ConnectionStatusIcon(isConnected: isKeyConnected)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addCard) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
    }

    private func addCard() {
        withAnimation {
            let newCard = Keycard(name: "New card \(Int.random(in: 1...99))")
            modelContext.insert(newCard)
        }
    }

    private func selectCard(_ card: Keycard) async {
        await connectionManager.sendCard(card)
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(keycards[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Keycard.self, inMemory: true)
}
