import SwiftUI

struct Cell: Shape {
    static let animationDuration = 0.5
    static let animation = Animation.easeOut(duration: Cell.animationDuration)
    
    let player: TicTacToe.Player?
    let lineWidth: Double
    let isMatching: Bool
    
    var animationCompletion: Double
    
    var animatableData: Double {
        get { animationCompletion }
        
        set { animationCompletion = newValue }
    }
    
    var body: some View {
        self.trim(from: 0, to: animationCompletion)
            .stroke(style: StrokeStyle(lineWidth: lineWidth,
                                       lineCap: .round))
            .foregroundColor(foregroundColor)
            .animation(.default, value: isMatching)
    }
    
    private var foregroundColor: Color? {
        guard !isMatching else { return .green }
        switch player {
        case .x:
            return .red
        case .o:
            return .blue
        case nil:
            return nil
        }
    }
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            guard let player = player else { return }
            let rect = rect.insetBy(dx: 0.2 * rect.width,
                                    dy: 0.2 * rect.height)
            switch player {
            case .x:
                let upperLeft = CGPoint(x: rect.minX,
                                        y: rect.minY)
                let lowerRight = CGPoint(x: rect.maxX,
                                         y: rect.maxY)
                path.move(to: upperLeft)
                path.addLine(to: lowerRight)
                let upperRight = CGPoint(x: rect.maxX,
                                         y: rect.minY)
                let lowerLeft = CGPoint(x: rect.minX,
                                        y: rect.maxY)
                path.move(to: upperRight)
                path.addLine(to: lowerLeft)
            case .o:
                path.addArc(center: CGPoint(x: rect.midX,
                                            y: rect.midY),
                            radius: rect.width / 2,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360),
                            clockwise: false)
            }
        }
    }
}
