import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.connectionManager) private var connectionManager
    @Query private var keycards: [Keycard]
    @State var isShowingCloneCardSheet: Bool = false

    var isKeyConnected: Bool { connectionManager.isKeyConnected }
    // Cards that aren't loaded onto Portiqo Key
    var inactiveKeycards: [Keycard] {
        keycards
            .filter { $0.id != connectionManager.currentCard }
            .sorted { $0.name < $1.name }
    }

    var body: some View {
        NavigationSplitView {
            switch isKeyConnected {
            case true:
                if let currentCardID = connectionManager.currentCard {
                    CurrentCardWidget(currentCardID: currentCardID)
                }
            case false:
                NoConnectionWidget()
            }
            List {
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
            .sheet(isPresented: $isShowingCloneCardSheet) { CloneCardView() }
            .scrollContentBackground(.hidden)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    ConnectionStatusIcon(isConnected: isKeyConnected)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: { isShowingCloneCardSheet.toggle() }) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
    }

    private func selectCard(_ card: Keycard) async {
        if isKeyConnected {
            await connectionManager.sendCard(card)
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
