import SwiftUI
import Vision

class ContourDetection {
    func detectContours(from image: UIImage, completion: @escaping @MainActor (CGImage?) -> Void) {
        guard let cgImage = image.cgImage else {
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let request = VNDetectContoursRequest { request, error in
                guard let results = request.results as? [VNContoursObservation], let firstResult = results.first else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }

                let size = CGSize(width: CGFloat(cgImage.width), height: CGFloat(cgImage.height))
                let renderer = UIGraphicsImageRenderer(size: size)
                let outputImage = renderer.image { ctx in
                    let context = ctx.cgContext
                    context.setStrokeColor(UIColor.black.cgColor)
                    context.setLineWidth(2.0)

                    func drawContours(_ contour: VNContour) {
                        let points = contour.normalizedPoints
                        if let firstPoint = points.first {
                            context.beginPath()
                            context.move(to: CGPoint(
                                x: CGFloat(firstPoint.x) * size.width,
                                y: (1 - CGFloat(firstPoint.y)) * size.height
                            ))
                            for point in points.dropFirst() {
                                context.addLine(to: CGPoint(
                                    x: CGFloat(point.x) * size.width,
                                    y: (1 - CGFloat(point.y)) * size.height
                                ))
                            }
                            context.closePath()
                            context.strokePath()
                        }
                    }

                    // 1️⃣ 외곽선 먼저 그리기
                    for contour in firstResult.topLevelContours {
                        drawContours(contour)
                    }

                    // 2️⃣ 내부 윤곽선도 포함
                    for index in 0..<firstResult.contourCount {
                        if let innerContour = try? firstResult.contour(at: index) {
                            drawContours(innerContour)
                        }
                    }
                }

                DispatchQueue.main.async {
                    completion(outputImage.cgImage)
                }
            }

            request.revision = 1
            request.contrastAdjustment = 1.0
            request.detectsDarkOnLight = true

            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? requestHandler.perform([request])
        }
    }
}
