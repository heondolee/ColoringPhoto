import SwiftUI

struct DrawingCanvasView: View {
    let backgroundImage: UIImage // ✅ 전달받은 윤곽선 이미지
    @State private var drawingPaths: [Path] = [] // 저장된 그리기 경로
    @State private var currentPath = Path() // 현재 그리고 있는 경로
    @State private var selectedColor: Color = .black // 선택한 색상
    @State private var brushSize: CGFloat = 5.0 // 브러쉬 크기

    var body: some View {
        VStack {
            // 🖌️ 색상 팔레트 추가
            HStack {
                ForEach([Color.red, Color.blue, Color.green, Color.yellow, Color.orange, Color.purple], id: \.self) { color in
                    Circle()
                        .fill(color)
                        .frame(width: 30, height: 30)
                        .overlay(Circle().stroke(Color.white, lineWidth: selectedColor == color ? 3 : 0))
                        .onTapGesture {
                            selectedColor = color
                        }
                }
            }
            .padding()

            // 🖌️ 브러쉬 크기 조절 슬라이더
            Slider(value: $brushSize, in: 1...20, step: 1) {
                Text("Brush Size")
            }
            .padding()

            // 🎨 캔버스 + 배경 이미지 (윤곽선)
            ZStack {
                Image(uiImage: backgroundImage) // ✅ 윤곽선 이미지 표시
                    .resizable()
                    .scaledToFit()
                    .frame(height: 400)
                
                Canvas { context, size in
                    for path in drawingPaths {
                        context.stroke(path, with: .color(selectedColor), lineWidth: brushSize)
                    }
                    context.stroke(currentPath, with: .color(selectedColor), lineWidth: brushSize)
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let point = value.location
                            if currentPath.isEmpty {
                                currentPath.move(to: point)
                            } else {
                                currentPath.addLine(to: point)
                            }
                        }
                        .onEnded { _ in
                            drawingPaths.append(currentPath)
                            currentPath = Path()
                        }
                )
                .background(Color.clear)
                .frame(height: 400)
            }
            .border(Color.gray, width: 1)

            // 🧹 지우기 버튼
            Button("🧹 지우기") {
                drawingPaths.removeAll()
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}

#Preview {
    DrawingCanvasView(backgroundImage: UIImage(named: "sample") ?? UIImage())
}
