import SwiftUI
import PhotosUI
import UIKit

struct ImagePicker: View {
    @Binding var selectedImage: UIImage? // ImageProcessorView에서 사용할 바인딩 변수
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        PhotosPicker("사진 선택", selection: $selectedItem, matching: .images)
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        selectedImage = UIImage(data: data)
                    }
                }
            }
    }
}
