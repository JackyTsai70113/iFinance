import SwiftUI

enum PonyReaction {
    case idle, happy, surprised, cheerful
}

struct PonyBuddyView: View {
    let transactionCount: Int
    let balance: Double
    var reaction: PonyReaction = .idle

    @State private var bounceOffset: CGFloat = 0
    @State private var eyeBlink = false
    @State private var currentMessage = ""
    @State private var showBubble = true
    @State private var cheekGlow = false
    @State private var tailWag = false
    @State private var jumpOffset: CGFloat = 0

    private var messages: [String] {
        // Reaction-specific messages first
        switch reaction {
        case .happy:
            return ["太棒了，賺到錢了！", "收入 GET！", "咴咴～好開心！"]
        case .surprised:
            return ["哇！花了不少耶！", "大筆支出！注意喔～", "噢噢...荷包在哭！"]
        case .cheerful:
            return ["記帳成功！", "又記了一筆，讚！", "+10 XP！"]
        case .idle:
            break
        }

        var pool = [
            "記帳是好習慣喔～",
            "今天也要好好記帳呀！",
            "小馬陪你一起！",
            "你好棒，繼續加油！",
            "每一筆都是進步～",
            "理財從記帳開始！",
            "嘿嘿，我在這陪你～",
            "存錢錢，買紅蘿蔔！",
            "你是最棒的記帳達人！",
            "小小記錄，大大改變！",
            "噠噠噠～小馬來了！",
            "咴咴～一起加油！",
        ]
        if transactionCount == 0 {
            pool.append(contentsOf: [
                "快來記第一筆吧～",
                "點右上角 + 開始記帳！",
                "空空的...快記一筆吧！",
            ])
        }
        if transactionCount > 5 {
            pool.append(contentsOf: [
                "哇，你好認真記帳！",
                "超棒的！繼續保持！",
                "記帳達人就是你！",
            ])
        }
        if balance > 0 {
            pool.append(contentsOf: [
                "結餘是正的，太棒了！",
                "存到錢了耶，好厲害！",
            ])
        }
        if balance < 0 {
            pool.append(contentsOf: [
                "花有點多...注意一下喔",
                "沒關係，慢慢調整～",
            ])
        }
        return pool
    }

    // Eye shape changes with reaction
    private var eyeHeight: CGFloat {
        if eyeBlink { return 2 }
        switch reaction {
        case .surprised: return 14
        case .happy: return 8
        default: return 12
        }
    }

    private var mouthWidth: CGFloat {
        switch reaction {
        case .surprised: return 10
        case .happy, .cheerful: return 12
        default: return 8
        }
    }

    private var mouthHeight: CGFloat {
        switch reaction {
        case .surprised: return 8
        case .happy, .cheerful: return 6
        default: return 4
        }
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            // Speech bubble
            if showBubble {
                Text(currentMessage)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(red: 0.45, green: 0.3, blue: 0.2))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(.systemBackground))
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                        }
                    )
                    .transition(.scale(scale: 0.5, anchor: .bottomTrailing).combined(with: .opacity))
            }

            // Pony character
            ZStack {
                // Tail
                PonyTailShape()
                    .fill(Color(red: 0.85, green: 0.55, blue: 0.25))
                    .frame(width: 18, height: 22)
                    .rotationEffect(.degrees(tailWag ? 15 : -15), anchor: .top)
                    .offset(x: -30, y: 18)

                // Body
                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.95, green: 0.75, blue: 0.5), Color(red: 0.85, green: 0.6, blue: 0.35)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 50, height: 40)
                    .offset(y: 14)

                // Legs
                HStack(spacing: 20) {
                    VStack(spacing: 0) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(red: 0.8, green: 0.55, blue: 0.3))
                            .frame(width: 8, height: 16)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(red: 0.35, green: 0.25, blue: 0.15))
                            .frame(width: 10, height: 4)
                    }
                    VStack(spacing: 0) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(red: 0.8, green: 0.55, blue: 0.3))
                            .frame(width: 8, height: 16)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(red: 0.35, green: 0.25, blue: 0.15))
                            .frame(width: 10, height: 4)
                    }
                }
                .offset(y: 40)

                // Head
                ZStack {
                    Ellipse()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.95, green: 0.78, blue: 0.55), Color(red: 0.88, green: 0.65, blue: 0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 36)

                    // Ears
                    HStack(spacing: 20) {
                        EarShape()
                            .fill(Color(red: 0.9, green: 0.7, blue: 0.45))
                            .frame(width: 10, height: 16)
                            .overlay(
                                EarShape()
                                    .fill(Color.pink.opacity(0.3))
                                    .frame(width: 6, height: 10)
                                    .offset(y: 2)
                            )
                            .rotationEffect(.degrees(-15))

                        EarShape()
                            .fill(Color(red: 0.9, green: 0.7, blue: 0.45))
                            .frame(width: 10, height: 16)
                            .overlay(
                                EarShape()
                                    .fill(Color.pink.opacity(0.3))
                                    .frame(width: 6, height: 10)
                                    .offset(y: 2)
                            )
                            .rotationEffect(.degrees(15))
                    }
                    .offset(y: -18)

                    // Mane
                    ManeShape()
                        .fill(Color(red: 0.85, green: 0.55, blue: 0.25))
                        .frame(width: 22, height: 14)
                        .offset(x: 2, y: -18)

                    // Eyes
                    HStack(spacing: 10) {
                        ZStack {
                            Ellipse()
                                .fill(.white)
                                .frame(width: 11, height: eyeHeight)
                            if reaction == .surprised {
                                Circle()
                                    .fill(Color(red: 0.2, green: 0.15, blue: 0.1))
                                    .frame(width: 7, height: 7)
                                    .opacity(eyeBlink ? 0 : 1)
                            } else {
                                Circle()
                                    .fill(Color(red: 0.2, green: 0.15, blue: 0.1))
                                    .frame(width: 6, height: 6)
                                    .offset(y: 1)
                                    .opacity(eyeBlink ? 0 : 1)
                            }
                            Circle()
                                .fill(.white)
                                .frame(width: 2.5, height: 2.5)
                                .offset(x: -1, y: -1)
                                .opacity(eyeBlink ? 0 : 1)
                        }

                        ZStack {
                            Ellipse()
                                .fill(.white)
                                .frame(width: 11, height: eyeHeight)
                            if reaction == .surprised {
                                Circle()
                                    .fill(Color(red: 0.2, green: 0.15, blue: 0.1))
                                    .frame(width: 7, height: 7)
                                    .opacity(eyeBlink ? 0 : 1)
                            } else {
                                Circle()
                                    .fill(Color(red: 0.2, green: 0.15, blue: 0.1))
                                    .frame(width: 6, height: 6)
                                    .offset(y: 1)
                                    .opacity(eyeBlink ? 0 : 1)
                            }
                            Circle()
                                .fill(.white)
                                .frame(width: 2.5, height: 2.5)
                                .offset(x: -1, y: -1)
                                .opacity(eyeBlink ? 0 : 1)
                        }
                    }
                    .offset(y: -1)

                    // Snout
                    Ellipse()
                        .fill(Color(red: 0.97, green: 0.85, blue: 0.7))
                        .frame(width: 18, height: 12)
                        .offset(y: 10)

                    // Nostrils
                    HStack(spacing: 5) {
                        Ellipse()
                            .fill(Color(red: 0.7, green: 0.5, blue: 0.35))
                            .frame(width: 3, height: 2.5)
                        Ellipse()
                            .fill(Color(red: 0.7, green: 0.5, blue: 0.35))
                            .frame(width: 3, height: 2.5)
                    }
                    .offset(y: 9)

                    // Mouth - changes with reaction
                    if reaction == .surprised {
                        Ellipse()
                            .stroke(Color(red: 0.65, green: 0.45, blue: 0.3), lineWidth: 1.5)
                            .frame(width: mouthWidth, height: mouthHeight)
                            .offset(y: 15)
                    } else {
                        MouthShape()
                            .stroke(Color(red: 0.65, green: 0.45, blue: 0.3), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                            .frame(width: mouthWidth, height: mouthHeight)
                            .offset(y: 14)
                    }

                    // Cheeks
                    HStack(spacing: 22) {
                        Circle()
                            .fill(Color.pink.opacity(cheekGlow ? 0.45 : 0.2))
                            .frame(width: 7, height: 7)
                        Circle()
                            .fill(Color.pink.opacity(cheekGlow ? 0.45 : 0.2))
                            .frame(width: 7, height: 7)
                    }
                    .offset(y: 6)

                    // Stars when happy/cheerful
                    if reaction == .happy || reaction == .cheerful {
                        Image(systemName: "sparkle")
                            .font(.system(size: 8))
                            .foregroundColor(.yellow)
                            .offset(x: 22, y: -16)
                        Image(systemName: "sparkle")
                            .font(.system(size: 6))
                            .foregroundColor(.yellow)
                            .offset(x: -20, y: -12)
                    }
                }
                .offset(y: -12)
            }
            .frame(width: 70, height: 75)
            .offset(y: bounceOffset + jumpOffset)
        }
        .onAppear {
            currentMessage = messages.randomElement() ?? "咴咴～"
            startAnimations()
        }
        .onChange(of: reaction) {
            if reaction != .idle {
                // Jump animation
                withAnimation(.easeOut(duration: 0.2)) {
                    jumpOffset = -15
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.easeIn(duration: 0.2)) {
                        jumpOffset = 0
                    }
                }
                // Show reaction message
                withAnimation(.easeOut(duration: 0.15)) {
                    showBubble = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    currentMessage = messages.randomElement() ?? "咴咴～"
                    withAnimation(.easeOut(duration: 0.3)) {
                        showBubble = true
                    }
                }
            }
        }
    }

    private func startAnimations() {
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            bounceOffset = -5
        }
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            cheekGlow = true
        }
        withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
            tailWag = true
        }
        blinkLoop()
        messageLoop()
    }

    private func blinkLoop() {
        let delay = Double.random(in: 2.0...4.5)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.easeInOut(duration: 0.1)) {
                eyeBlink = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    eyeBlink = false
                }
                blinkLoop()
            }
        }
    }

    private func messageLoop() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            withAnimation(.easeOut(duration: 0.2)) {
                showBubble = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                currentMessage = messages.randomElement() ?? "咴咴～"
                withAnimation(.easeOut(duration: 0.3)) {
                    showBubble = true
                }
                messageLoop()
            }
        }
    }
}

// MARK: - Custom Shapes

struct MouthShape: Shape {
    func path(in rect: CGRect) -> Path {
        guard rect.width > 0, rect.height > 0 else { return Path() }
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addQuadCurve(
            to: CGPoint(x: rect.width, y: 0),
            control: CGPoint(x: rect.midX, y: rect.height)
        )
        return path
    }
}

struct EarShape: Shape {
    func path(in rect: CGRect) -> Path {
        guard rect.width > 0, rect.height > 0 else { return Path() }
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: 0))
        path.addQuadCurve(
            to: CGPoint(x: 0, y: rect.height),
            control: CGPoint(x: -rect.width * 0.1, y: rect.height * 0.3)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.width, y: rect.height),
            control: CGPoint(x: rect.midX, y: rect.height * 1.1)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.midX, y: 0),
            control: CGPoint(x: rect.width * 1.1, y: rect.height * 0.3)
        )
        return path
    }
}

struct ManeShape: Shape {
    func path(in rect: CGRect) -> Path {
        guard rect.width > 0, rect.height > 0 else { return Path() }
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height))
        path.addCurve(
            to: CGPoint(x: rect.width * 0.35, y: 0),
            control1: CGPoint(x: rect.width * 0.05, y: rect.height * 0.4),
            control2: CGPoint(x: rect.width * 0.2, y: 0)
        )
        path.addCurve(
            to: CGPoint(x: rect.width * 0.7, y: rect.height * 0.3),
            control1: CGPoint(x: rect.width * 0.5, y: 0),
            control2: CGPoint(x: rect.width * 0.6, y: rect.height * 0.15)
        )
        path.addCurve(
            to: CGPoint(x: rect.width, y: rect.height),
            control1: CGPoint(x: rect.width * 0.8, y: rect.height * 0.45),
            control2: CGPoint(x: rect.width * 0.95, y: rect.height * 0.7)
        )
        path.closeSubpath()
        return path
    }
}

struct PonyTailShape: Shape {
    func path(in rect: CGRect) -> Path {
        guard rect.width > 0, rect.height > 0 else { return Path() }
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: 0))
        path.addCurve(
            to: CGPoint(x: rect.width * 0.2, y: rect.height),
            control1: CGPoint(x: 0, y: rect.height * 0.3),
            control2: CGPoint(x: rect.width * 0.4, y: rect.height * 0.8)
        )
        path.addCurve(
            to: CGPoint(x: rect.midX, y: 0),
            control1: CGPoint(x: rect.width * 0.6, y: rect.height * 0.7),
            control2: CGPoint(x: rect.width, y: rect.height * 0.2)
        )
        return path
    }
}
