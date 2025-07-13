import SwiftUI

struct CreateNewCardView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @State var attributes: KeycardAttributes
    var body: some View {
        VStack {
            TextField("", text: $attributes.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button(action: saveChanges) {
                Text("Import Keycard")
            }
        }
    }

    func saveChanges() {
        let card = Keycard(attributes: attributes)
        modelContext.insert(card)
        dismiss()
    }
}

    #Preview {
        CreateNewCardView(attributes: KeycardAttributes(name: "Cloned Card"))
    }
