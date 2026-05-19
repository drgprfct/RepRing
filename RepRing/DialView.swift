import SwiftUI

struct RepDial: View {
    @Binding var value: Int
    let range: ClosedRange<Int>
    let step: Int
    let title: String
    let caption: String
    let tint: Color

    private var progress: Double {
        let span = max(range.upperBound - range.lowerBound, 1)
        return Double(value - range.lowerBound) / Double(span)
    }

    var body: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)
            let radius = size * 0.39
            let center = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2)
            let knobAngle = Angle(degrees: 135 + (270 * progress))
            let knobPoint = CGPoint(x: center.x + cos(knobAngle.radians) * radius,
                                    y: center.y + sin(knobAngle.radians) * radius)

            ZStack {
                Arc(startAngle: .degrees(135), endAngle: .degrees(405))
                    .stroke(Color.secondary.opacity(0.18), style: StrokeStyle(lineWidth: 16, lineCap: .round))
                    .frame(width: size, height: size)
                    .position(center)

                Arc(startAngle: .degrees(135), endAngle: .degrees(135 + (270 * progress)))
                    .stroke(tint.gradient, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                    .frame(width: size, height: size)
                    .position(center)

                Circle()
                    .fill(tint)
                    .frame(width: 28, height: 28)
                    .shadow(radius: 8, y: 4)
                    .position(knobPoint)

                VStack(spacing: 4) {
                    Text(title)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text("\(value)")
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .monospacedDigit()
                    Text(caption)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.secondary)
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        updateValue(from: gesture.location, center: center)
                    }
            )
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(title) dial")
            .accessibilityValue("\(value) \(caption)")
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment: value = min(range.upperBound, value + step)
                case .decrement: value = max(range.lowerBound, value - step)
                @unknown default: break
                }
            }
        }
    }

    private func updateValue(from point: CGPoint, center: CGPoint) {
        let dx = point.x - center.x
        let dy = point.y - center.y
        var degrees = atan2(dy, dx) * 180 / .pi
        if degrees < 0 { degrees += 360 }
        if degrees < 135 { degrees += 360 }

        let clamped = min(max(degrees, 135), 405)
        let rawProgress = (clamped - 135) / 270
        let rawValue = Double(range.lowerBound) + rawProgress * Double(range.upperBound - range.lowerBound)
        let stepped = (rawValue / Double(step)).rounded() * Double(step)
        value = min(max(Int(stepped), range.lowerBound), range.upperBound)
    }
}

struct Arc: Shape {
    var startAngle: Angle
    var endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY),
                    radius: min(rect.width, rect.height) / 2 - 18,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false)
        return path
    }
}

struct ProgressRing: View {
    let progress: Double
    let lineWidth: CGFloat
    let tint: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(.secondary.opacity(0.16), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(tint.gradient, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.45, dampingFraction: 0.75), value: progress)
        }
    }
}
