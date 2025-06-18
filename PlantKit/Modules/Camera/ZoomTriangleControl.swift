import SwiftUI

struct ZoomWedgeControl: View {
    @Binding var zoomFactor: CGFloat
    let minZoom: CGFloat
    let maxZoom: CGFloat
    var onZoomChanged: ((CGFloat) -> Void)? = nil

    private let controlWidth: CGFloat = 180
    private let controlHeight: CGFloat = 40

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let percent = (zoomFactor - minZoom) / (maxZoom - minZoom)
            ZStack(alignment: .leading) {
                TriangleWedgeShape()
                    .fill(Color.gray.opacity(0.3))
                TriangleWedgeFillShape(percent: percent)
                    .fill(Color.green)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let x = min(max(value.location.x, 0), width)
                        let newPercent = x / width
                        let newZoom = minZoom + newPercent * (maxZoom - minZoom)
                        zoomFactor = newZoom
                        onZoomChanged?(zoomFactor)
                    }
            )
            .onTapGesture { location in
                let x = min(max(location.x, 0), width)
                let newPercent = x / width
                let newZoom = minZoom + newPercent * (maxZoom - minZoom)
                zoomFactor = newZoom
                onZoomChanged?(zoomFactor)
            }
        }
        .frame(width: controlWidth, height: controlHeight)
        .padding(.vertical, 8)
    }
}

struct TriangleWedgeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        // Tip at bottom left
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        // Top right
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        // Bottom right (base)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        // Back to tip
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct TriangleWedgeFillShape: Shape {
    var percent: CGFloat // 0...1
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let fillWidth = rect.width * percent
        let fillHeight = rect.height * percent
        // Tip at bottom left
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        // Top right (proportional)
        path.addLine(to: CGPoint(x: rect.minX + fillWidth, y: rect.maxY - fillHeight))
        // Bottom right (proportional)
        path.addLine(to: CGPoint(x: rect.minX + fillWidth, y: rect.maxY))
        // Back to tip
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct ZoomWedgeControl_Previews: PreviewProvider {
    static var previews: some View {
        ZoomWedgeControl(zoomFactor: .constant(2.0), minZoom: 1.0, maxZoom: 5.0)
            .background(Color.black)
            .previewLayout(.sizeThatFits)
    }
} 