import SwiftUI

struct ConfettiPiece: Identifiable {
    let id = UUID()
    let color: Color
    let x: CGFloat
    let size: CGFloat
    let rotationEnd: Double
    let duration: Double
    let delay: Double
    let shape: Int // 0=circle, 1=rect, 2=star
}

struct CelebrationView: View {
    @Binding var isActive: Bool
    @State private var pieces: [ConfettiPiece] = []
    @State private var animate = false

    private let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink, .mint, .cyan]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(pieces) { piece in
                    confettiShape(piece)
                        .frame(width: piece.size, height: piece.size)
                        .foregroundColor(piece.color)
                        .offset(
                            x: piece.x - geo.size.width / 2,
                            y: animate ? geo.size.height + 50 : -50
                        )
                        .rotationEffect(.degrees(animate ? piece.rotationEnd : 0))
                        .opacity(animate ? 0 : 1)
                        .animation(
                            .easeIn(duration: piece.duration).delay(piece.delay),
                            value: animate
                        )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .allowsHitTesting(false)
        .onChange(of: isActive) {
            if isActive { trigger() }
        }
    }

    @ViewBuilder
    private func confettiShape(_ piece: ConfettiPiece) -> some View {
        switch piece.shape {
        case 0: Circle()
        case 1: RoundedRectangle(cornerRadius: 2)
        default:
            Image(systemName: "star.fill")
                .resizable()
        }
    }

    private func trigger() {
        pieces = (0..<45).map { _ in
            ConfettiPiece(
                color: colors.randomElement()!,
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                size: CGFloat.random(in: 6...14),
                rotationEnd: Double.random(in: 180...720),
                duration: Double.random(in: 1.5...2.5),
                delay: Double.random(in: 0...0.6),
                shape: Int.random(in: 0...2)
            )
        }
        animate = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            animate = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            isActive = false
            pieces = []
            animate = false
        }
    }
}
