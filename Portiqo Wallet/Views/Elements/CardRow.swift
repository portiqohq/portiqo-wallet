import SwiftUI

struct CardRow: View {
    var card: Keycard

    init(_ card: Keycard) {
        self.card = card
    }

    var body: some View {
        HStack {
            Image(systemName: "lanyardcard.fill")
                .font(.title)
            Spacer()
            Text(card.name)
                .font(.headline)
        }
        .foregroundStyle(.secondary)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

#Preview() {
    CardRow(Keycard(name: "Gym Fob"))
}
