import SwiftUI

/// Presents crisis resources in a sheet. Reused wherever a persistent SOS
/// entry point needs to surface them without duplicating
/// `CrisisResourceBanner`'s content.
struct CrisisSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                CrisisResourceBanner()
            }
            .navigationTitle("Crisis Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

/// A persistent, always-reachable SOS toolbar button that presents
/// `CrisisSheet`. The chatbot and other tools offer general support only —
/// this stays one tap away everywhere it's added.
struct SOSToolbarButton: View {
    @State private var isPresented = false

    var body: some View {
        Button {
            isPresented = true
        } label: {
            Image(systemName: "cross.case.fill")
        }
        .tint(.red)
        .sheet(isPresented: $isPresented) {
            CrisisSheet()
        }
    }
}
