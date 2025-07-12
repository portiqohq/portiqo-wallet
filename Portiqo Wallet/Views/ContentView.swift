import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.connectionManager) private var connectionManager
    @Query private var keycards: [Keycard]

    var isKeyConnected: Bool { connectionManager.isKeyConnected }

    var body: some View {
        NavigationSplitView {
            VStack {
                CurrentCardWidget(currentCardID: connectionManager.currentCard)
                List {
                    ForEach(keycards) { card in
                        NavigationLink {
                            CardDetailsView(card)
                        } label: {
                            Text(card.name)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
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
            let newCard = Keycard(name: "New card")
            modelContext.insert(newCard)
        }
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
