import SwiftUI

struct CardDetailsView: View {
    var card: Keycard
    @Bindable var cardAttributes: KeycardAttributes

    init(_ card: Keycard) {
        self.card = card
        self.cardAttributes = KeycardAttributes(keycard: card)
    }

    var body: some View {
        VStack {
            TextField("", text: $cardAttributes.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
        }
        .onDisappear(perform: saveChanges)
    }

    /// Persist the changes the user has made here
    func saveChanges() {
        card.update(from: cardAttributes)
    }
}

#Preview {
    let card = Keycard(name: "Work Fob")
    CardDetailsView(card)
}
