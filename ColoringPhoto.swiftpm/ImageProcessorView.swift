import SwiftUI

struct ImageProcessorView: View {
    @State private var selectedImage: UIImage?
    @State private var processedImage: UIImage?
    @State private var navigateToDrawing = false // ✅ 화면 전환 상태 관리

    let contourDetector = ContourDetection() // 윤곽선 감지 클래스

    var body: some View {
        NavigationStack { // ✅ Navigation 추가
            VStack {
                if let image = processedImage {
                    Text("✅ 윤곽선 추출이 완료되었습니다.")
                        .font(.headline)
                        .foregroundColor(.green)

                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 600)

                    // ✅ 색칠하기 화면으로 이동하는 버튼
                    NavigationLink("🎨 색칠하기", value: image)
                                    .padding()
                                    .background(Color.purple)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                    
                    // 📌 새 사진 선택 버튼 추가
                    Button("📸 다른 사진 선택하기") {
                        selectedImage = nil
                        processedImage = nil
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)

                } else if let image = selectedImage {
                    Text("📷 원본 이미지")
                        .font(.headline)
                        .foregroundColor(.blue)

                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 600)

                    Button("🎨 윤곽선 추출") {
                        applyContourEffect()
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)

                    // 📌 새로운 사진을 선택할 수 있도록 버튼 추가
                    Button("📸 다른 사진 선택하기") {
                        selectedImage = nil
                        processedImage = nil
                    }
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                } else {
                    Text("📌 사진을 선택하세요!")
                        .foregroundColor(.gray)
                        .padding()

                    ImagePicker(selectedImage: $selectedImage)
                }
            }
            .navigationDestination(for: UIImage.self) { image in
                DrawingCanvasView(backgroundImage: image)
            }
        }
    }

    func applyContourEffect() {
        guard let image = selectedImage else {
            print("❌ [Error] selectedImage가 nil입니다. 사진을 선택해주세요.")
            return
        }

        print("✅ [Info] 선택한 이미지로 윤곽선 추출을 시작합니다.")

        contourDetector.detectContours(from: image) { result in
            DispatchQueue.main.async {
                if let cgImage = result {
                    print("✅ [Success] 윤곽선 추출 완료!")
                    processedImage = UIImage(cgImage: cgImage)
                    navigateToDrawing = true // ✅ 색칠 화면으로 이동
                } else {
                    print("❌ [Error] 윤곽선 추출에 실패했습니다.")
                }
            }
        }
    }
}

#Preview {
    ImageProcessorView()
}
