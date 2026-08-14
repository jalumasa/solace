import SwiftUI

/// A calm, goal-free sand-raking canvas. Dragging draws a multi-line "rake"
/// pattern; there's no way to do it wrong, and Clear just starts fresh.
struct ZenGardenView: View {
    @State private var strokes: [[CGPoint]] = []
    @State private var currentStroke: [CGPoint] = []

    private let rakeLineCount = 5
    private let rakeSpacing: CGFloat = 3
    private let rakeColor = Color(red: 0.62, green: 0.52, blue: 0.36)

    var body: some View {
        VStack(spacing: Theme.Spacing.large) {
            Text("Drag your finger to rake the sand. There's no pattern to get right.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            ZStack {
                RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.93, green: 0.85, blue: 0.68),
                                Color(red: 0.87, green: 0.77, blue: 0.56)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                Canvas { context, _ in
                    for stroke in strokes + [currentStroke] {
                        drawRake(stroke, in: &context)
                    }
                }
            }
            .frame(height: 380)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
            .padding(.horizontal)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        currentStroke.append(value.location)
                    }
                    .onEnded { _ in
                        if currentStroke.count > 1 {
                            strokes.append(currentStroke)
                        }
                        currentStroke = []
                    }
            )

            Button("Clear") {
                withAnimation { strokes.removeAll() }
            }
            .buttonStyle(.glass)

            Spacer()
        }
        .padding(.top)
        .navigationTitle("Zen Garden")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func drawRake(_ points: [CGPoint], in context: inout GraphicsContext) {
        guard points.count > 1 else { return }
        for lineIndex in 0..<rakeLineCount {
            let offset = CGFloat(lineIndex - rakeLineCount / 2) * rakeSpacing
            var path = Path()
            for (index, _) in points.enumerated() {
                let point = perpendicularOffset(points: points, index: index, offset: offset)
                if index == 0 {
                    path.move(to: point)
                } else {
                    path.addLine(to: point)
                }
            }
            context.stroke(path, with: .color(rakeColor.opacity(0.5)), lineWidth: 1.5)
        }
    }

    private func perpendicularOffset(points: [CGPoint], index: Int, offset: CGFloat) -> CGPoint {
        let point = points[index]
        let neighborIndex = index == points.count - 1 ? index - 1 : index + 1
        let neighbor = points[neighborIndex]
        let dx = neighbor.x - point.x
        let dy = neighbor.y - point.y
        let length = (dx * dx + dy * dy).squareRoot()
        guard length > 0 else { return point }
        let normalX = -dy / length
        let normalY = dx / length
        return CGPoint(x: point.x + normalX * offset, y: point.y + normalY * offset)
    }
}
