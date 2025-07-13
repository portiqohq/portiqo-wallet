import SwiftUI
import SwiftData

struct NoConnectionWidget: View {
    var body: some View {
        VStack {
            Text("No Portiqo Key Detected")
                .font(.title)
            Text("Make sure it's on and nearby")
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
    NoConnectionWidget()
}
