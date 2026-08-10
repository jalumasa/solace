import SwiftUI
import SolaceCore

struct ResourceDetailView: View {
    let resource: ResourceItem

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(resource.category.displayName)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)

                Text(resource.title)
                    .font(.title2.bold())

                Text(resource.body)
                    .font(.body)

                if !resource.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(resource.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.accentColor.opacity(0.15))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(resource.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
