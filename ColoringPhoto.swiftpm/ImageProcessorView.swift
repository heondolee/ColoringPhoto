import SwiftUI

struct ImageProcessorView: View {
    @State private var selectedImage: UIImage?
    @State private var processedImage: UIImage?
    
    let contourDetector = ContourDetection() // 윤곽선 감지 클래스

    var body: some View {
        VStack {
            if let image = processedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
            } else if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                
                Button("윤곽선 추출") {
                    applyContourEffect()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                
            } else {
                Text("사진을 선택하세요!")
                    .foregroundColor(.gray)
                ImagePicker(selectedImage: $selectedImage)
                    .padding()
            }
        }
    }
    
    func applyContourEffect() {
        guard let image = selectedImage else { return }
        contourDetector.detectContours(from: image) { result in
            DispatchQueue.main.async {
                if let cgImage = result {
                    processedImage = UIImage(cgImage: cgImage)
                }
            }
        }
    }
}

#Preview {
    ImageProcessorView()
}
