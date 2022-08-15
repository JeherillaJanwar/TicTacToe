import SwiftUI

extension Path {
    mutating func addHLine(width: CGFloat) {
        guard let currentPoint = currentPoint else { return }
        addLine(to: CGPoint(x: currentPoint.x + width,
                            y: currentPoint.y))
    }
    
    mutating func addVLine(height: CGFloat) {
        guard let currentPoint = currentPoint else { return }
        addLine(to: CGPoint(x: currentPoint.x,
                            y: currentPoint.y + height))
    }
}


struct GridLines: Shape {
    let lineWidth: Double
    var animationCompletion: Double
    var animatableData: Double {
        get { animationCompletion }
        set { animationCompletion = newValue }
    }
    
    var body: some View {
        self.trim(from: 0, to: animationCompletion)
            .stroke(style: StrokeStyle(lineWidth: lineWidth,
                                       lineCap: .round))
            .animation(.linear(duration: 1),
                       value: animationCompletion)
    }
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            let cellAndLineWidth = (rect.width + lineWidth) / 3
            for column in 1...2 {
                path.move(to: CGPoint(x: rect.minX + cellAndLineWidth * Double(column) - lineWidth / 2,
                                      y: rect.minY))
                path.addVLine(height: rect.height)
            }
            for row in 1...2 {
                path.move(to: CGPoint(x: rect.minX,
                                      y: rect.minY + cellAndLineWidth * Double(row) - lineWidth / 2))
                path.addHLine(width: rect.width)
            }
        }
    }
}
