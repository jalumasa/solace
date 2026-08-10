import SwiftUI
import SolaceCore

/// Always-visible, network-independent crisis resources. Shown wherever the
/// AI chatbot or resource library appears — the chatbot offers general
/// support only and isn't equipped to handle an active crisis.
struct CrisisResourceBanner: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("If you're in crisis, help is available now", systemImage: "exclamationmark.heart.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.red)

            ForEach(CrisisSupport.contacts) { contact in
                VStack(alignment: .leading, spacing: 2) {
                    Text(contact.name)
                        .font(.footnote.weight(.medium))
                    Text(contact.detail)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        CrisisResourceBanner()
    }
}
